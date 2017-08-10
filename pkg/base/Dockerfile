FROM alpine:3.6

RUN mkdir -p /base/etc/apk \
  && cp -r /etc/apk/* /base/etc/apk/ \
  && apk add --no-cache --initdb -p /base \
  alpine-baselayout \
  busybox \
  ca-certificates \
  dhcpcd \
  musl \
  e2fsprogs \
  e2fsprogs-extra \
  btrfs-progs \
  musl-dev \
  sfdisk \
  util-linux-dev  \
  && rm -rv /base/dev/*

COPY add-pkgs.sh /usr/bin/add-pkgs
