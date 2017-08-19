FROM quay.io/vektorcloud/go:1.8 AS source

RUN apk add --no-cache bash musl-dev util-linux-dev

COPY src/ /go/src/github.com/coreos/ignition/

RUN cd /go/src/github.com/coreos/ignition \
  && glide install \
  && sed -i -e 's/VERSION=.*/VERSION=mesanine/' ./build \
  && PLATFORM=linuxkit ./build

FROM scratch

ENTRYPOINT []

COPY --from=source /go/src/github.com/coreos/ignition/bin/amd64/ignition /usr/bin/
