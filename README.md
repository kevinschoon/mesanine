# mezzanine

Mezzanine is a minimalist container-oriented Linux distribution based on [Alpine](https://alpinelinux.org) for running [Apache Mesos](https://mesos.apache.org).

## FAQ

  * How does Mezzanine compare to CoreOS?
    Mezzanine is similar to CoreOS but uses Apache Mesos in favor of Kubernetes. Mezzanine also uses the lighter weight OpenRC init manager instead of systemd.
  * How does Mezzanine compare to DC/OS?
    DC/OS is a collection of wrapper scripts and server processes that install along side an existing Linux distribution of CentOS or Ubuntu. Mezzanine is a true Linux distribution that focuses on simplicity.

## packages

The packages directory contains all of the sources for building packages on Mezzanine. Some of these packages will be merged into Alpine while others are specific to Mezzanine.
