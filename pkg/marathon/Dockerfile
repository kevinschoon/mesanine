FROM quay.io/vektorcloud/marathon

RUN apk add --no-cache grep

ENV LIBPROCESS_IP=127.0.0.1
ENV MESOS_NATIVE_JAVA_LIBRARY=/usr/lib/libmesos-1.3.0.so
ENV MARATHON_MASTER=zk://127.0.0.1:2181/mesos
ENV MARATHON_ZK=zk://127.0.0.1:2181/marathon

LABEL org.mobyproject.config='{"pid": "host", "binds": ["/etc/resolv.conf:/etc/resolv.conf", "/var/lib/docker:/var/lib/docker", "/lib/modules:/lib/modules", "/var/run:/var/run"], "mounts": [{"type": "cgroup", "options": ["rw", "nosuid", "noexec", "nodev", "relatime"]}], "capabilities": ["all"]}'

ADD start /opt/marathon/bin/
