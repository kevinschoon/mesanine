PWD := $(shell pwd)
TARGET := $(PWD)/target
MOBY := $(PWD)/tools/moby/moby
LINUXKIT := $(PWD)/tools/linuxkit/bin/linuxkit
PACKAGES := $(shell find ./pkg -mindepth 1 -maxdepth 1 -type d -printf "%f\n" |sort)
METADATA := $(shell go run ./util/metadata/metadata.go ./config)
GIT_HASH := $(shell git rev-parse HEAD)
AWS_PROFILE := mesanine
AWS_REGION := eu-west-2
AWS_BUCKET := mesanine-ami
IGLDFLAGS= -X github.com/coreos/ignition/internal/version.Raw=mesanine \
					 -X github.com/coreos/ignition/internal/platform.Raw=linuxkit \
					 -extldflags \"-fno-PIC -static\"

# TODO
GAFFER_SRC := /home/kevin/repos/github.com/mesanine/gaffer

OEM := "qemu"
ifeq ($(MAKECMDGOALS),push-aws-master)
OEM := "ec2"
endif
ifeq ($(MAKECMDGOALS),push-aws-agent)
OEM := "ec2"
endif

.PHONY: \
	all \
	clean \
	docker \
	ignition \
	run \
	run-cmd \
	push-aws \
	packages \
	write-oem \
	submodules

all: packages

packages: ignition
	@echo "Building packages $(PACKAGES)"
	for i in $(PACKAGES); do \
		docker build -t "mesanine/$$i" "pkg/$$i" || exit 1; \
	done

clean:
	rm -rf $(TARGET)/**

ignition:
	docker build -t mesanine/ignition-bin -f tools/Dockerfile.ignition tools

write-oem:
	echo -n ${OEM} > $(TARGET)/oem

submodules:
	git submodule foreach sync
	cd ./tools/linuxkit && make ./bin/linuxkit
	cd ./tools/moby && make
	#git submodule foreach git pull

$(TARGET)/mesanine.ign:
	terraform apply

$(TARGET)/mesanine: write-oem packages
	$(MOBY) build -output kernel+initrd -dir $(TARGET) mesanine.yml
	touch $(TARGET)/mesanine

$(TARGET)/mesanine.tar: write-oem packages
	$(MOBY) build -output tar -o $(TARGET)/mesanine.tar mesanine.yml

$(TARGET)/mesanine.raw: write-oem packages
	$(MOBY) build -output raw -dir $(TARGET) mesanine.yml

$(TARGET)/fs: $(TARGET)/mesanine.tar
	mkdir $(TARGET)/fs 2>/dev/null || true
	tar -C $(TARGET)/fs -xf $(TARGET)/mesanine.tar

docker: $(TARGET)/fs
	echo -e "FROM scratch\nCOPY fs/ /" > $(TARGET)/Dockerfile
	docker build -t mesanine/mesanine:latest $(TARGET)

run: $(TARGET)/mesanine ignition $(TARGET)/mesanine.ign run-cmd

run-cmd:
	$(LINUXKIT) run qemu -mem 8000 -publish "2181:2181" -publish "2222:22" -publish "2379:2379" -publish "5050:5050" -publish "8080:8080" -publish "9090:9090" -publish "10000:10000" -extra="-fw_cfg name=opt/com.coreos/config,file=$(TARGET)/mesanine.ign" -kernel $(TARGET)/mesanine

push-aws: $(TARGET)/mesanine.raw
	AWS_PROFILE=$(AWS_PROFILE) AWS_REGION=$(AWS_REGION) linuxkit -v push aws -bucket $(AWS_BUCKET) -img-name mesanine-$(GIT_HASH) -timeout 1200 $(TARGET)/mesanine.raw
