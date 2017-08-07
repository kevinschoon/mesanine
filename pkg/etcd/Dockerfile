FROM mesanine/base AS base

RUN add-pkgs openssl

FROM quay.io/vektorcloud/etcd:3.2 as etcd

FROM scratch

COPY --from=base /base/ /
COPY --from=etcd /bin/etcd /bin/etcd

ENTRYPOINT ["/bin/etcd"]

LABEL org.mobyproject.config='{"pid": "host", "net": "host", "capabilities": ["CAP_NET_BIND_SERVICE"]}'
