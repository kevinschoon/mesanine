FROM quay.io/vektorcloud/mesos:latest as mesos

FROM scratch
ENTRYPOINT []
WORKDIR /
COPY --from=mesos / /etc/mesos/
