FROM quay.io/vektorcloud/zetcd

LABEL org.mobyproject.config='{"pid": "host", "net": "host", "capabilities": ["CAP_NET_BIND_SERVICE"]}'

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

