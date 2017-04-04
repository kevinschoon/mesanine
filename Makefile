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
all: docker packages

.PHONY: clean
clean:
	rm -Rf .packages/*

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
	cd iso && \
			tar czf mesanine.apkovl.tar.gz -C ovl .
	$(DOCKER) $(MOUNTS) -w $(HOME)/target/iso $(IMAGE) \
		fakeroot make PROFILE=mesanine iso
