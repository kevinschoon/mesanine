FROM quay.io/vektorcloud/go:dep AS build

ENV VERSION runc-input

# TODO Update once/if https://github.com/influxdata/telegraf/pull/3045 is merged
RUN mkdir -p $GOPATH/src/github.com/influxdata \
  && cd $GOPATH/src/github.com/influxdata \
  && git clone --depth=1 --branch="$VERSION" https://github.com/kevinschoon/telegraf.git \
  && cd telegraf \
  && make

FROM quay.io/vektorcloud/base:3.6

COPY --from=build /go/bin/telegraf /usr/bin/

ENTRYPOINT ["/usr/bin/telegraf"]

LABEL org.mobyproject.config='{"pid": "host", "binds": ["/var/config/ssh:/root/.ssh", "/etc/resolv.conf:/etc/resolv.conf", "/:/hostroot", "/usr/bin/gaffer:/usr/bin/gaffer", "/usr/bin/runc:/usr/bin/runc", "/var:/var", "/containers:/containers", "/dev:/dev", "/sys:/sys", "/var/config/telegraf:/etc/telegraf"], "capabilities": ["all"]}'
