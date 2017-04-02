FROM alpine:3.5

RUN apk update \
    && apk add --no-cache alpine-sdk xorriso syslinux \
    && adduser -D builder \
    && addgroup builder abuild \
    && echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && mkdir -p /var/cache/distfiles \
    && chmod a+w /var/cache/distfiles \
    && mkdir /home/builder/target

COPY entrypoint.sh /
USER builder
WORKDIR /home/builder/target

ENTRYPOINT ["/entrypoint.sh"]
