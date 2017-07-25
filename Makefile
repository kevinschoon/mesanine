PWD := $(shell pwd)
MOBY := $(shell which moby) 
TARGET := $(PWD)/target
PACKAGES := $(shell find ./pkg -mindepth 1 -maxdepth 1 -type d -printf "%f\n")
METADATA := $(shell go run ./util/metadata/metadata.go ./config)
GIT_HASH := $(shell git rev-parse HEAD)
IMAGE_SIZE := 384M
AWS_PROFILE := vektor
AWS_REGION := us-east-1
AWS_BUCKET := mesanine
CMD_LINE := console=ttyS0 console=tty0 page_poison=1 gaffer=debug

.PHONY: all
all: packages

.PHONY: packages
packages:
	@echo "Building packages $(PACKAGES)"
	for i in $(PACKAGES); do \
		docker build -t "mesanine/$$i" "pkg/$$i" || exit 1; \
	done

.PHONY: clean
clean:
	rm -rf $(TARGET)/**

target/mesanine-cmdline target/mesanine-initrd.img target/mesanine-kernel: packages
	moby -v build -disable-content-trust=true -output kernel+initrd mesanine.yml
	mv -v mesanine-cmdline mesanine-initrd.img mesanine-kernel $(TARGET)/

target/mesanine.raw: packages
	moby -v build -disable-content-trust=true -output raw -size $(IMAGE_SIZE) mesanine.yml
	mv -v mesanine.raw $(TARGET)/mesanine.raw

target/mesanine.tar: packages
	moby -v build -disable-content-trust=true -output tar -o target/mesanine.tar mesanine.yml

target/fs: target/mesanine.tar
	mkdir target/fs || true
	tar -C target/fs -xvf target/mesanine.tar || true # Cannot handle hardlinks

.PHONY: run
run: target/mesanine-kernel
	#linuxkit run qemu -mem 4092 -publish "2181:2181" -publish "2222:22" -publish "5050:5050" -publish "5051:5051" --publish "8080:8080" -publish "10000:10000" -data '$(METADATA)' -disk=file=./target/mesanine.qcow,size=2G,format=qcow2 -kernel target/mesanine
	/usr/bin/qemu-system-x86_64 -device virtio-rng-pci -smp 1 -m 4092 -enable-kvm -machine q35,accel=kvm:tcg -drive file=./target/mesanine.qcow,format=qcow2,index=0,media=disk -cdrom target/mesanine-state/data.iso -kernel target/mesanine-kernel -initrd target/mesanine-initrd.img -append '$(CMD_LINE)' -net user,hostfwd=tcp::2181-:2181,hostfwd=tcp::2222-:22,hostfwd=tcp::5050-:5050,hostfwd=tcp::5051-:5051,hostfwd=tcp::8080-:8080,hostfwd=tcp::10000-:10000,guestfwd=tcp:10.0.2.100:8086-tcp:127.0.0.1:8086,guestfwd=tcp:10.0.2.100:9200-tcp:127.0.0.1:9200 -net nic -nographic

.PHONY: push-aws
push-aws: target/mesanine.raw
	AWS_PROFILE=$(AWS_PROFILE) AWS_REGION=$(AWS_REGION) linuxkit -v push aws -bucket $(AWS_BUCKET) -img-name mesanine-$(GIT_HASH) -timeout 1200 target/mesanine.raw
