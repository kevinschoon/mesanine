FROM alpine:3.6

RUN apk add --no-cache openssl

COPY --from=quay.io/vektorcloud/etcd:3.2 /bin/etcd /bin/etcd

ENV ETCD_ADVERTISE_CLIENT_URLS http://0.0.0.0:2379
ENV ETCD_LISTEN_CLIENT_URLS http://0.0.0.0:2379
# Mesanine does not yet support multi-master mode
ENV ETCD_ADVERTISE_PEER_URLS http://127.0.0.1:2379

ENTRYPOINT ["/bin/etcd"]

LABEL org.mobyproject.config='{"pid": "host", "net": "host", "capabilities": ["CAP_NET_BIND_SERVICE"]}'
