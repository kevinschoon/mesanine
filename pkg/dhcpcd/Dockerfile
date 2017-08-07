FROM mesanine/base AS base

RUN add-pkgs dhcpcd

FROM scratch
ENTRYPOINT []
CMD []
WORKDIR /
COPY --from=base /base/ /
COPY /dhcpcd.conf /usr/ /
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
LABEL org.mobyproject.config='{"binds": ["/run/resolvconf:/etc"], "capabilities": ["CAP_NET_ADMIN", "CAP_NET_BIND_SERVICE", "CAP_NET_RAW"]}'
