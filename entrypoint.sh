#!/bin/sh
set -e

USER="builder"
USER_ID="${USER_ID:=1000}"
USER_GID="${USER_GID:=1000}"
PACKAGES="/home/$USER/packages/packages"
APK_UPDATE="${APK_UPDATE:=0}"
WITH_PACKAGES=${WITH_PACKAGES:=""}

[ -d "$PACKAGES" ] && {
  echo "$PACKAGES" >> /etc/apk/repositories
}

[ -f "/home/$USER/.abuild/"*.rsa.pub ] && {
  cp -v "/home/$USER/.abuild/"*.rsa.pub /etc/apk/keys/
}

[ "$APK_UPDATE" -eq 1 ] && {
  apk update
}

for package in $(echo "$WITH_PACKAGES" | tr "," "\n"); do
  apk add $package
done

sed -i -e "s/^${USER}:\([^:]*\):[0-9]*:[0-9]*/${USER}:\1:${USER_ID}:${USER_GID}/" /etc/passwd
sed -i -e "s/^${USER}:\([^:]*\):[0-9]*/${USER}:\1:${USER_GID}/" /etc/group

chown -R "$USER:$USER" "/home/$USER"

exec sudo -u builder -g builder "$@"
