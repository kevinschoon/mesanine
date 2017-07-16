FROM quay.io/vektorlab/gaffer AS gaffer
FROM scratch

WORKDIR /
ENTRYPOINT []

COPY --from=gaffer /bin/gaffer /usr/bin/
COPY etc/ /etc/
