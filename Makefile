PWD := $(shell pwd)
MOBY := $(shell which moby) 
TARGET := $(PWD)/target
PACKAGES := $(shell find ./pkg -mindepth 1 -maxdepth 1 -type d -printf "%f\n")
METADATA := $(shell go run ./util/metadata/metadata.go)
GIT_HASH := $(shell git rev-parse HEAD)
IMAGE_SIZE := 384M
AWS_PROFILE := vektor
AWS_REGION := us-east-1
AWS_BUCKET := mesanine

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
	linuxkit run qemu -mem 4092 -publish "2222:22" -publish "5050:5050" -publish "5051:5051" -publish "9090:9090" -publish "10000:10000" -data '$(METADATA)' -disk=file=./target/mesanine.qcow,size=2G,format=qcow2 -kernel target/mesanine

.PHONY: push-aws
push-aws: target/mesanine.raw
	AWS_PROFILE=$(AWS_PROFILE) AWS_REGION=$(AWS_REGION) linuxkit -v push aws -bucket $(AWS_BUCKET) -img-name mesanine-$(GIT_HASH) -timeout 1200 target/mesanine.raw
