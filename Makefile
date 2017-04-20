PWD := $(shell pwd)
MOBY := $(shell which moby)
TARGET := "./target"

.PHONY: all

.PHONY: clean
	@rm -rf $(TARGET)/**

$(TARGET)/mesanine-bzImage $(TARGET)/mesanine-initrd.img $(TARGET)/mesanine-cmdline: all
	@moby build mesanine.yml
	@mv -v mesanine-* $(TARGET)
