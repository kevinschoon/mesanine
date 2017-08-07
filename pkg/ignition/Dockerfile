FROM quay.io/vektorcloud/go:1.8 AS source

RUN apk add --no-cache bash musl-dev util-linux-dev \ 
  && mkdir -p /go/src/github.com/coreos \
  && cd /go/src/github.com/coreos \
  && git clone https://github.com/coreos/ignition \
  && cd ignition \
  && glide install \
  && ./build 

FROM mesanine/base AS base

RUN add-pkgs \
  e2fsprogs \
  e2fsprogs-extra \
  btrfs-progs \
  musl-dev \
  sfdisk \
  util-linux-dev 

FROM scratch

COPY --from=base /base /

COPY --from=source /go/src/github.com/coreos/ignition/bin/amd64/ignition /usr/bin/

CMD ["/usr/bin/ignition", "--root=/hostroot", "--oem=qemu", "--stage=files"]

LABEL org.mobyproject.config='{"pid": "host", "net": "host", "binds": ["/:/hostroot", "/lib/modules:/lib/modules", "/sys:/sys"], "capabilities": ["all"]}'


