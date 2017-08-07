FROM linuxkit/alpine:9bcf61f605ef0ce36cc94d59b8eac307862de6e1 AS build
RUN apk add --no-cache --initdb alpine-baselayout make gcc musl-dev

ADD usermode-helper.c .
RUN make usermode-helper

RUN apk add --no-cache go musl-dev
ENV GOPATH=/go PATH=$PATH:/go/bin

COPY init.go /go/src/init/
COPY vendor /go/src/init/vendor/
RUN go-compile.sh /go/src/init/

FROM mesanine/base AS base

FROM scratch
COPY --from=build /go/bin/init /
COPY --from=build usermode-helper /sbin/
COPY --from=base /base/ /
COPY etc etc/
COPY bin bin/
