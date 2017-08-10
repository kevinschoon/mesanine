#!/bin/sh
set -xe

/usr/bin/ignition --oem="$(cat /hostroot/oem)" --root=/hostroot --stage disks --platform linuxkit || true

/usr/bin/ignition --oem="$(cat /hostroot/oem)" --root=/hostroot --stage files --platform linuxkit || true
