PACKAGES := $(shell find ./packages/* -maxdepth 1 -type d |sed 's/\.\/packages\///')
PWD := $(shell pwd)

IMAGE := mesanine-builder
HOME := /home/builder

DOCKER := docker run --rm -ti
MOUNTS := \
-v $(PWD):$(HOME)/target \
-v $(PWD)/.packages:$(HOME)/packages/packages \
-v $(PWD)/.abuild:$(HOME)/.abuild \


.PHONY: all
all: docker packages mkinitfs iso

.PHONY: clean
clean:
	cd mkinitfs \
		&& make clean \
		&& cd ../iso \
		&& make clean

.PHONY: clean-packages
clean-packages:
	rm -Rf .packages/*

.PHONY: docker
docker:
	docker build -t $(IMAGE) .

.PHONY: packages
packages:
	@echo "Building packages $(PACKAGES)"
	for i in $(PACKAGES); do \
		$(DOCKER) $(MOUNTS) -w $(HOME)/target/packages/$$i $(IMAGE) \
		abuild -r ; \
	done

.PHONY: mkinitfs
mkinitfs:
	$(DOCKER) $(MOUNTS) -w $(HOME)/target/mkinitfs $(IMAGE) make

.PHONY: iso
iso:
	@echo $(DOCKER) $(MOUNTS) -w $(HOME)/target/iso $(IMAGE) "sudo apk add ../.packages/x86_64/ignition-*.apk && fakeroot make iso"

