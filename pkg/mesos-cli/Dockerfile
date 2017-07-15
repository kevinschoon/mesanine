FROM quay.io/vektorlab/mesos-cli AS mesos-cli
FROM scratch

WORKDIR /
ENTRYPOINT []

COPY --from=mesos-cli /bin/mesos /usr/bin/
