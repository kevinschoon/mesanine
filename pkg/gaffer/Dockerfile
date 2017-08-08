FROM mesanine/gaffer AS gaffer
FROM scratch

WORKDIR /
ENTRYPOINT []

COPY --from=gaffer /usr/bin/gaffer /usr/bin/
COPY etc/ /etc/
