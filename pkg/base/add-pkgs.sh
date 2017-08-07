#!/bin/sh

apk add --no-cache -p /base $@

CLEANUP="
/base/var/cache
/base/lib/apk 
/base/etc/apk 
/base/dev
/base/usr/share/terminfo
/base/etc/terminfo
"

for p in $CLEANUP; do 
  [[ -d $p ]] && {
    rm -rv $p
  }
done

exit 0
