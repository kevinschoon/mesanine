PWD := $(shell pwd)
MOBY := $(shell which moby)
TARGET := "./target"
PACKAGES := $(shell find ./pkg -maxdepth 1 -type d |sed 's/\.\/pkg\///')
IMAGES := $(TARGET)/mesanine-bzImage $(TARGET)/mesanine-initrd.img $(TARGET)/mesanine-cmdline

.PHONY: all
all: packages $(IMAGES)

.PHONY: clean
	rm -rf $(TARGET)/**

$(IMAGES):
	moby build mesanine.yml
	mv -v mesanine-* $(TARGET)

.PHONY: packages
packages:
	@echo "Building packages $(PACKAGES)"
	for i in $(PACKAGES); do \
		docker build -t mesanine/$$i pkg/$$i ; \
	done
