# mesanine

Mesanine is a minimalist container-oriented Linux distribution based on [Alpine](https://alpinelinux.org) for running [Apache Mesos](https://mesos.apache.org). It is assembled with [linuxkit](https://github.com/linuxkit/linuxkit).

## Building

Install the most recent version of [linuxkit](https://github.com/linuxkit/linuxkit) and ensure the `moby` executable is available in your path. You also need a working `make` system.

    go get github.com/vektorlab/mesanine
    cd $GOPATH/src/github.com/vektorlab/mesanine
    make

### Targets

Mesanine has two supported build targets: `aws`, `qemu`.

#### qemu

    make && make qemu && make run-qemu


#### aws
TODO
