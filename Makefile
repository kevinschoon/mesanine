PWD := $(shell pwd)
MOBY := $(shell which moby)
TARGET := "./target"
PACKAGES := $(shell find ./pkg -mindepth 1 -maxdepth 1 -type d -printf "%f\n")
IMAGES := $(TARGET)/mesanine-bzImage $(TARGET)/mesanine-initrd.img $(TARGET)/mesanine-cmdline

.PHONY: all
all: build

.PHONY: build
build:
	@echo "Building packages $(PACKAGES)"
	for i in $(PACKAGES); do \
		docker build -t mesanine/$$i pkg/$$i ; \
	done
	moby build mesanine.yml
	mv -v mesanine-* $(TARGET)

.PHONY: clean
	rm -rf $(TARGET)/**

