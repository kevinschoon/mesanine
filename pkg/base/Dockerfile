FROM alpine:3.6 AS base

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
  && rm -Rv /base/dev/* \
  && rm -Rv /base/lib/apk/* \
  && rm -Rv /base/var/cache/* \
  && rm -Rv /base/etc/apk/* 

FROM alpine:3.6 AS build

COPY usermode-helper.c /

RUN apk add --no-cache gcc make musl-dev \
  && make usermode-helper

FROM scratch 

COPY --from=base /base /
COPY --from=build /usermode-helper /sbin/
COPY --from=mesanine/ignition-bin /ignition /bin/
COPY --from=quay.io/vektorcloud/runc /usr/bin/runc /bin/
COPY bin/ /bin/
COPY etc/ /etc/
COPY init /

RUN rm -v /sbin/init && ln -sv /bin/gaffer /sbin/init
