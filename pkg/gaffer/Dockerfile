FROM alpine:3.6 AS build

COPY usermode-helper.c /

RUN apk add --no-cache gcc make musl-dev \
  && make usermode-helper

FROM mesanine/base AS base
FROM mesanine/gaffer AS gaffer
FROM scratch

WORKDIR /
ENTRYPOINT []

COPY --from=base /base/ /
COPY --from=build /usermode-helper /sbin/
COPY --from=gaffer /usr/bin/gaffer /usr/bin/

COPY etc etc/
COPY bin bin/
COPY init /
