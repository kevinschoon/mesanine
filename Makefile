PWD := $(shell pwd)
MOBY := $(shell which moby)
TARGET := $(PWD)/target
PACKAGES := $(shell find ./pkg -mindepth 1 -maxdepth 1 -type d -printf "%f\n")

.PHONY: all
all: packages

.PHONY: packages
packages:
	@echo "Building packages $(PACKAGES)"
	for i in $(PACKAGES); do \
		docker build -t "mesanine/$$i" "pkg/$$i" ; \
	done

.PHONY: qemu
qemu:
	if [ ! -d $(TARGET)/qemu ] ; then mkdir -p $(TARGET)/qemu ; fi
	moby -v build -disable-content-trust=true -output iso-bios mesanine.yml
	mv -v mesanine.iso $(TARGET)/mesanine.iso

.PHONY: aws
aws:
	if [ ! -d $(TARGET)/aws ] ; then mkdir -p $(TARGET)/aws ; fi
	moby build -disable-content-true true -output raw mesanine.yml
	mv -v mesanine.raw $(TARGET)/aws/

.PHONY: clean
clean:
	rm -rf $(TARGET)/**

.PHONY: run-qemu
run-qemu:
	linuxkit run qemu -mem 4092 -publish "5050:5050" -publish "10000:10000" -iso target/mesanine.iso
