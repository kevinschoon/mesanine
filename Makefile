PACKAGES := $(shell find ./packages/* -maxdepth 1 -type d |sed 's/\.\/packages\///')
PWD := $(shell pwd)

IMAGE := mesanine-builder
HOME := /home/builder

DOCKER := docker run --rm -ti
MOUNTS := \
-v $(PWD):$(HOME)/target \
-v $(PWD)/.packages:$(HOME)/packages/packages \
-v $(PWD)/.abuild:$(HOME)/.abuild \
-v $(PWD)/.apk-cache:/var/cache/apk \


.PHONY: all
all: docker packages

.PHONY: clean
clean: clean-packages clean-iso

.PHONY: clean-packages
clean-packages:
	rm -Rf .packages/*

.PHONY: clean-iso
clean-iso:
	rm -Rf iso/mesanine.apkovl.tar.gz iso/mesanine.iso iso/mesanine-*.iso iso/isotmp.mesanine/

.PHONY: docker
docker:
	docker build -t $(IMAGE) .

.PHONY: packages
packages:
	@echo "Building packages $(PACKAGES)"
	for i in $(PACKAGES); do \
		$(DOCKER) $(MOUNTS) -w $(HOME)/target/packages/$$i $(IMAGE) \
		abuild -r; \
	done

.PHONY: iso
iso:
	# TODO Need to change permissions in etc/ before compressing into tar
	$(DOCKER) $(MOUNTS) -w $(HOME)/target $(IMAGE) tar czf iso/mesanine.apkovl.tar.gz -C iso/ovl .
	$(DOCKER) $(MOUNTS) $(IMAGE) sudo apk update
	$(DOCKER) $(MOUNTS) -w $(HOME)/target/iso $(IMAGE) \
		fakeroot make PROFILE=mesanine iso
