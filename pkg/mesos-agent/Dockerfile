FROM mesanine/base AS base

RUN add-pkgs \
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

COPY discover-ip /sbin/

LABEL org.mobyproject.config='{"pid": "host", "net": "host", "binds": ["/var/run/mesos:/var/run/mesos"], "capabilities": ["all"]}'

CMD ["/usr/local/sbin/mesos-agent", "--ip_discovery_command=/sbin/discover-ip", "--work_dir=/var/run/mesos"]
