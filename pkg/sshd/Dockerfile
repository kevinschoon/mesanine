FROM quay.io/vektorcloud/base:3.6 AS mirror

RUN mkdir -p /out/etc/apk && cp -r /etc/apk/* /out/etc/apk/
RUN apk add --no-cache --initdb -p /out \
    alpine-baselayout \
    busybox \
    curl \
    ca-certificates \
    htop \
    file \
    jq \
    musl \
    openssh-server \
    tini \
    util-linux \
    vim \
    && true
RUN rm -rf /out/etc/apk /out/lib/apk /out/var/cache

FROM scratch
ENTRYPOINT []
WORKDIR /
COPY --from=mirror /out/ /
COPY etc/ /etc/
COPY usr/ /usr/
RUN mkdir -p /etc/ssh /root/.ssh && chmod 0700 /root/.ssh
CMD ["/sbin/tini", "/usr/bin/ssh.sh"]
LABEL org.mobyproject.config='{"pid": "host", "binds": ["/var/config/ssh:/root/.ssh", "/etc/resolv.conf:/etc/resolv.conf", "/:/hostroot", "/usr/bin/gaffer:/usr/bin/gaffer", "/usr/bin/runc:/usr/bin/runc", "/var:/var", "/containers:/containers", "/dev:/dev", "/sys:/sys", "/lib/modules:/lib/modules"], "capabilities": ["all"]}'
