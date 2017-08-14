FROM mesanine/base AS base

RUN add-pkgs \
  bash \
  coreutils \
  curl \
  fts \
  libstdc++ \
  openssl \
  subversion \
  tar 

FROM quay.io/vektorcloud/mesos AS mesos

FROM scratch

COPY --from=base /base/ /
COPY --from=mesos /usr/local /usr/local
COPY --from=mesos /usr/bin/docker* /usr/bin/

COPY discover-ip /sbin/

LABEL org.mobyproject.config='{"pid": "host", "net": "host", "binds": ["/var/run:/var/run"], "mounts": [{"type": "cgroup", "options": ["rw", "nosuid", "noexec", "nodev", "relatime"]}], "capabilities": ["all"]}'

CMD ["mesos-agent", "--ip_discovery_command=/sbin/discover-ip", "--work_dir=/var/run/mesos"]
