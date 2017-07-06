#!/bin/sh
set -xe

CONFIG_DIR="/opt/zookeeper/conf"
CONFIG_PATH="/var/config/zookeeper"

[[ -d "$CONFIG_PATH" ]] && {
  cp -Rv "$CONFIG_PATH"/* "$CONFIG_DIR"
}

[[ -f "$CONFIG_PATH"/myid ]] && {
  mv -v "$CONFIG_PATH"/myid "$CONFIG_DIR"../data/
}


exec "$@"
