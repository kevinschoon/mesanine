# mesanine

Mesanine is a minimalist container-oriented Linux distribution based on [Alpine](https://alpinelinux.org) for running [Apache Mesos](https://mesos.apache.org).

## FAQ

  * How does Mesanine compare to CoreOS?
    Mesanine is similar to CoreOS but uses Apache Mesos in favor of Kubernetes. Mesanine also uses the lighter weight OpenRC init manager instead of systemd.
  * How does Mesanine compare to DC/OS?
    DC/OS is a collection of wrapper scripts and server processes that install along side an existing Linux distribution of CentOS or Ubuntu. Mesanine is a true Linux distribution that focuses on simplicity.

## packages

The packages directory contains all of the sources for building packages on Mesanine. Some of these packages will be merged into Alpine while others are specific to Mesanine.

## Running ISO

    qemu-system-x86_64 -boot d -cdrom mesanine-170404-x86_64.iso -drive file=fat:rw:/tmp/share -m 512

## Bootchart

![chart](bootchart.png)

