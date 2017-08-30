FROM alpine:3.6

RUN apk add --no-cache \
  bash \
  coreutils \
  curl \
  fts \
  libstdc++ \
  openssl \
  subversion \
  tar 

FROM quay.io/vektorcloud/mesos AS mesos

COPY --from=quay.io/vektorcloud/mesos /usr/local /usr/local
COPY --from=quay.io/vektorcloud/mesos /usr/bin/docker* /usr/bin/

COPY discover-ip /sbin/

LABEL org.mobyproject.config='{"pid": "host", "net": "host", "binds": ["/var/run:/var/run"], "mounts": [{"type": "cgroup", "options": ["rw", "nosuid", "noexec", "nodev", "relatime"]}], "capabilities": ["all"]}'

CMD ["mesos-agent", "--ip_discovery_command=/sbin/discover-ip", "--work_dir=/var/run/mesos"]
