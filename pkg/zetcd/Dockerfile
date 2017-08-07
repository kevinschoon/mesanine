FROM mesanine/base AS base
FROM quay.io/vektorcloud/zetcd AS zetcd

FROM scratch

COPY --from=base /base/ /
COPY --from=zetcd /usr/bin/zetcd /usr/bin/

LABEL org.mobyproject.config='{"pid": "host", "net": "host", "capabilities": ["CAP_NET_BIND_SERVICE"]}'

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

