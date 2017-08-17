FROM quay.io/vektorcloud/runc AS runc

FROM scratch

COPY --from=runc /usr/bin/runc /usr/bin/
