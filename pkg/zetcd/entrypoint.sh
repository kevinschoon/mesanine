#!/bin/sh
set -xe

echo "$ETCD_ENDPOINTS"
env

exec /usr/bin/zetcd -zkaddr="0.0.0.0:2181" -endpoints="$ETCD_ENDPOINTS" -logtostderr
