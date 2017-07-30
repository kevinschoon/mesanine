PWD := $(shell pwd)
MOBY := $(shell which moby) 
LINUXKIT := $(shell which linuxkit)
TARGET := ./target
PACKAGES := $(shell find ./pkg -mindepth 1 -maxdepth 1 -type d -printf "%f\n")
METADATA := $(shell go run ./util/metadata/metadata.go ./config)
GIT_HASH := $(shell git rev-parse HEAD)
IMAGE_SIZE := 384M
AWS_PROFILE := vektor
AWS_REGION := us-east-1
AWS_BUCKET := mesanine
CMD_LINE := console=ttyS0 console=tty0 page_poison=1 


.PHONY: all clean run run-now packages push-aws

all: packages

packages:
	@echo "Building packages $(PACKAGES)"
	for i in $(PACKAGES); do \
		docker build -t "mesanine/$$i" "pkg/$$i" || exit 1; \
	done

clean:
	rm -rf $(TARGET)/**

$(TARGET)/mesanine-cmdline $(TARGET)/mesanine-initrd.img $(TARGET)/mesanine-kernel: packages
	$(MOBY) build -disable-content-trust=true -output kernel+initrd mesanine.yml
	mv -v mesanine-cmdline mesanine-initrd.img mesanine-kernel $(TARGET)/

$(TARGET)/mesanine.qcow2:
	qemu-img create -o size=1024M -f qcow2 $(TARGET)/mesanine.qcow2

$(TARGET)/config.ign:
	go run util/metadata/metadata.go ./config >$(TARGET)/config.ign

$(TARGET)/mesanine.raw: packages
	$(MOBY) -v build -disable-content-trust=true -output raw -size $(IMAGE_SIZE) mesanine.yml
	mv -v mesanine.raw $(TARGET)/mesanine.raw

$(TARGET)/mesanine.tar: packages
	$(MOBY) -v build -disable-content-trust=true -output tar -o $(TARGET)/mesanine.tar mesanine.yml

$(TARGET)/fs: $(TARGET)/mesanine.tar
	mkdir $(TARGET)/fs || true
	tar -C $(TARGET)/fs -xvf $(TARGET)/mesanine.tar || true # Cannot handle hardlinks

#	@echo $(LINUXKIT) metadata create $(TARGET)/metadata.iso '$(shell go run util/metadata/metadata.go ./config)'

run: $(TARGET)/mesanine-cmdline $(TARGET)/mesanine.qcow2 $(TARGET)/config.ign run-cmd

run-cmd:
	/usr/bin/qemu-system-x86_64 -device virtio-rng-pci -smp 1 -m 4092 -enable-kvm -machine q35,accel=kvm:tcg -drive file=$(TARGET)/mesanine.qcow2,format=qcow2,index=0,media=disk -fw_cfg  name=opt/com.coreos/config,file=$(TARGET)/config.ign -kernel $(TARGET)/mesanine-kernel -initrd $(TARGET)/mesanine-initrd.img -append '$(CMD_LINE)' -net user,hostfwd=tcp::2181-:2181,hostfwd=tcp::2222-:22,hostfwd=tcp::5050-:5050,hostfwd=tcp::5051-:5051,hostfwd=tcp::8080-:8080,hostfwd=tcp::9090-:9090,hostfwd=tcp::10000-:10000 -net nic -nographic

#,guestfwd=tcp:10.0.2.100:8086-tcp:127.0.0.1:8086

push-aws: $(TARGET)/mesanine.raw
	AWS_PROFILE=$(AWS_PROFILE) AWS_REGION=$(AWS_REGION) linuxkit -v push aws -bucket $(AWS_BUCKET) -img-name mesanine-$(GIT_HASH) -timeout 1200 $(TARGET)/mesanine.raw
