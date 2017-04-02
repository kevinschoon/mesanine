#!/bin/sh
set -e

ABUILD="$HOME/.abuild"
PACKAGES="$HOME/packages/packages"

[ ! -d "$ABUILD" ] && {
  abuild-keygen -ain
}

[ -d "$PACKAGES" ] && {
  sudo sh -c "echo $PACKAGES >> /etc/apk/repositories"
}

sudo cp -v $HOME/.abuild/*.rsa.pub /etc/apk/keys/

# Ensure mounted volumes get set to the builder user
# TODO: Better way to do this?
sudo chown -R builder:builder $HOME

exec $@

