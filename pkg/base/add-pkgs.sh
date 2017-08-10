#!/bin/sh

apk add --no-cache -p /base $@

CLEANUP="
/base/var/cache
/base/lib/apk 
/base/etc/apk 
/base/dev
"

for p in $CLEANUP; do 
  [[ -d $p ]] && {
    rm -rv $p
  }
done

exit 0
