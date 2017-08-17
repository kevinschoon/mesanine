TARGET := ./target
MOBY := ./tools/linuxkit/bin/moby
LINUXKIT := ./tools/linuxkit/bin/linuxkit
PACKAGES := $(shell find ./pkg -mindepth 1 -maxdepth 1 -type d -printf "%f\n" |sort)
METADATA := $(shell go run ./util/metadata/metadata.go ./config)
GIT_HASH := $(shell git rev-parse HEAD)
IMAGE_SIZE := 384M
AWS_PROFILE := vektor
AWS_REGION := us-east-1
AWS_BUCKET := mesanine

OEM := "qemu"
ifeq ($(MAKECMDGOALS),push-aws-master)
OEM := "ec2"
endif
ifeq ($(MAKECMDGOALS),push-aws-agent)
OEM := "ec2"
endif


.PHONY: \
	all \
	agent-kernel \
	clean \
	docker \
	ignition \
	master-kernel \
	run-agent \
	run-agent-cmd \
	run-master \
	run-master-cmd \
	push-aws \
	packages \
	write-oem

all: packages

packages:
	@echo "Building packages $(PACKAGES)"
	for i in $(PACKAGES); do \
		docker build -t "mesanine/$$i" "pkg/$$i" || exit 1; \
	done

clean:
	rm -rf $(TARGET)/**

ignition:
	terraform apply

write-oem:
	echo -n ${OEM} > $(TARGET)/oem

$(TARGET)/master.qcow2:
	qemu-img create -o size=1024M -f qcow2 $(TARGET)/master.qcow2

$(TARGET)/agent.qcow2:
	qemu-img create -o size=1024M -f qcow2 $(TARGET)/agent.qcow2

$(TARGET)/master.tar: packages write-oem
	$(MOBY) build -output tar -o $(TARGET)/master.tar master.yml

$(TARGET)/agent.tar: packages write-oem
	$(MOBY) build -output tar -o $(TARGET)/agent.tar agent.yml

$(TARGET)/master.raw: packages write-oem
	$(MOBY) build -output raw -dir $(TARGET) master.yml

$(TARGET)/agent.raw: packages write-oem
	$(MOBY) build -output raw -dir $(TARGET) agent.yml

master-kernel: packages write-oem
	$(MOBY) build -output kernel+initrd -dir $(TARGET) master.yml

agent-kernel: packages write-oem
	$(MOBY) build -output kernel+initrd -dir $(TARGET) agent.yml

$(TARGET)/master-fs: $(TARGET)/master.tar
	mkdir $(TARGET)/master-fs 2>/dev/null || true
	tar -C $(TARGET)/master-fs -xf $(TARGET)/master.tar

$(TARGET)/agent-fs: $(TARGET)/agent.tar
	mkdir $(TARGET)/agent-fs 2>/dev/null || true
	tar -C $(TARGET)/agent-fs -xf $(TARGET)/agent.tar

docker: $(TARGET)/master-fs $(TARGET)/agent-fs
	echo -e "FROM scratch\nCOPY master-fs/ /" > $(TARGET)/Dockerfile
	docker build -t mesanine/mesanine:master $(TARGET)
	echo -e "FROM scratch\nCOPY agent-fs/ /" > $(TARGET)/Dockerfile
	docker build -t mesanine/mesanine:agent $(TARGET)

run-master: master-kernel ignition run-master-cmd

run-agent: agent-kernel ignition run-agent-cmd

run-master-cmd:
	$(LINUXKIT) run qemu -mem 8000 -publish "2181:2181" -publish "2222:22" -publish "2379:2379" -publish "5050:5050" -publish "8080:8080" -publish "9090:9090" -publish "10000:10000" -extra="-fw_cfg name=opt/com.coreos/config,file=$(TARGET)/master.ign" -disk=file=$(TARGET)/master.qcow,size=2G,format=qcow2 -kernel $(TARGET)/master

run-agent-cmd:
	$(LINUXKIT) run qemu -mem 4092 -publish "2222:22" -publish "5051:5051" -publish "9090:9090" -publish "10000:10000" -extra="-fw_cfg name=opt/com.coreos/config,file=$(TARGET)/agent.ign" -disk=file=$(TARGET)/agent.qcow,size=2G,format=qcow2 -kernel $(TARGET)/agent

push-aws-agent: $(TARGET)/agent.raw
	AWS_PROFILE=$(AWS_PROFILE) AWS_REGION=$(AWS_REGION) linuxkit -v push aws -bucket $(AWS_BUCKET) -img-name mesanine-agent-$(GIT_HASH) -timeout 1200 $(TARGET)/agent.raw

push-aws-master: $(TARGET)/master.raw
	AWS_PROFILE=$(AWS_PROFILE) AWS_REGION=$(AWS_REGION) linuxkit -v push aws -bucket $(AWS_BUCKET) -img-name mesanine-master-$(GIT_HASH) -timeout 1200 $(TARGET)/master.raw
