FROM alpine:3.6

RUN mkdir -p /base/etc/apk \
  && cp -r /etc/apk/* /base/etc/apk/ \
  && apk add --no-cache --initdb -p /base \
  alpine-baselayout \
  busybox \
  eudev \
  ca-certificates \
  dhcpcd \
  musl \
  e2fsprogs \
  e2fsprogs-extra \
  btrfs-progs \
  musl-dev \
  sgdisk \
  sfdisk \
  util-linux-dev  \
  linux-headers \
  libseccomp \
  libseccomp-dev \
  && rm -rv /base/dev/*

# Ignition is hard-coded to look in /sbin/sgdisk
RUN ln -sv /usr/bin/sgdisk /sbin/sgdisk

COPY add-pkgs.sh /usr/bin/add-pkgs
