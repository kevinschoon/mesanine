# mesanine

Mesanine is a minimalist container-oriented Linux distribution based on [Alpine](https://alpinelinux.org) for running [Apache Mesos](https://mesos.apache.org). It is assembled with [linuxkit](https://github.com/linuxkit/linuxkit).

## FAQ

  * How does Mesanine compare to CoreOS?
    Mesanine is similar to CoreOS but uses Apache Mesos in favor of Kubernetes as a container orechestration platform. Kubernetes, however, may be run [on top](https://kubernetes.io/docs/getting-started-guides/mesos/) of Mesos with Mesanine.
  * How does Mesanine compare to DC/OS?
    DC/OS is a collection of wrapper scripts and server processes that install along side an existing Linux distribution of CentOS or Ubuntu. Mesanine is a pure Linux distribution that focuses on simplicity.

## Building

Install the most recent version of [linuxkit](https://github.com/linuxkit/linuxkit) and ensure the `moby` executable is available in your path. You also need a working `make` system.

    go get github.com/vektorlab/mesanine
    cd $GOPATH/src/github.com/vektorlab/mesanine
    make

### Targets

Mesanine has two supported build targets: `aws`, `qemu`.

#### qemu

To run Mesanine locally you need to use qemu and expose ports for the Mesos HTTP interface and optional SSH access.
You should specify your public RSA key in `mesanine.yml` before building.

    cd target
    qemu-system-x86_64 -device virtio-rng-pci -smp 1 -m 1024 -enable-kvm -machine q35,accel=kvm:tcg -kernel mesanine-bzImage -initrd mesanine-initrd.img -append "console=ttyS0 console=tty0 page_poison=1" -nographic -net nic,vlan0,model=virtio -net user,vlan=0,hostfwd=tcp::2222-:22,hostfwd=tcp::5050-:5050


#### aws
TODO
