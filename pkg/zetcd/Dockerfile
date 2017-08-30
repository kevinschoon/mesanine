FROM alpine:3.6

COPY --from=quay.io/vektorcloud/zetcd /usr/bin/zetcd /usr/bin/

LABEL org.mobyproject.config='{"pid": "host", "net": "host", "capabilities": ["CAP_NET_BIND_SERVICE"]}'

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

