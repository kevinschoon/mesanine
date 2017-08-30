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

COPY --from=quay.io/vektorcloud/mesos /usr/local /usr/local

COPY discover-ip /sbin/

LABEL org.mobyproject.config='{"pid": "host", "net": "host", "binds": ["/var/run:/var/run"], "capabilities": ["CAP_NET_BIND_SERVICE"]}'

CMD ["mesos-master", "--ip_discovery_command=/sbin/discover-ip", "--work_dir=/var/run/mesos"]
