# Proof of Concept

This PoC has the goal to start a container inside a microvm using gardenlinux as the microvm os. 


# Steps 


## 0. Requirements

- Install firecracker [getting started guide](https://github.com/firecracker-microvm/firecracker#getting-started)


## 1. Build Garden Linux image

The image that is used to run the microvm is a Garden Linux. 
Containerd is included via `chost` feature that is included in feature `firecracker` with this poc.

The `_dev` feature is used for easy access to the microvm during the poc.

```
make build
```

## 2. Prepare firecracker

```
# Edit CUSTOM_* variables:
#    - network interface names to use in prepare-network.sh
make prepare-host
```

## 3. Start microVM

```
# Edit CUSTOM_* variables:
#    - allocated memory and cpu in configure-vm.sh
make start-vm 
```

## 4. Steps inside microVM

### Expose containerd unix socket via socat over TCP

Guest
```
socat TCP-LISTEN:2224,fork UNIX-CONNECT:/run/containerd/containerd.sock
```

Host:
```
socat UNIX-LISTEN:$(pwd)/containerd.sock,fork TCP-CONNECT:10.0.2.11:2224

# in second terminal:
nerdctl --address unix://$(pwd)/containerd.sock version
```



## TODO

- using /etc/containerd/config.toml settings.. do they already provide everything we need?
    - API scope enough if using tcp? https://github.com/containerd/containerd/issues/3466#issuecomment-516204803
    - suitable client to use the tcp endpoint?
- How should the communication between host and firecracker VM be designed?
    - use vsock to expose vm local unix socket of grpc?
        - how to handle the initial overhead when connecting to the vsock?
    - use socat to bridge unix socket via tcp
        - unix->tcp->tcp->unix
        - nerdctl --address <unix-socket-on-host-that-got-forwarded-via-socat>
            - this does work for `pull nginx`, but does not work for `run -p 8080:80 nginx`because of a permission error.
                -  `FATA[0000] failed to mount {Type:overlay Source:overlay Target: Options:[index=off lowerdir=/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/6/fs:/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/5/fs:/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/4/fs:/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/3/fs:/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/2/fs:/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/1/fs]} on "/tmp/initialC160386887": operation not permitted `
            - doing the same in the vm (no --address flag) works
            - running sudo nerdctl ...
                - FATA[0000] failed to mount /tmp/containerd-mount1272006949: no such file or directory


# Snippets

``` 
cd path/to/containerd/api/services/version/v1
grpcurl -plaintext -proto version.proto 10.0.2.11:2224 containerd.services.version.v1.Version/Version
# Should this return the version if grpc api expose correctly on host?
```

```
# in the VM
sudo socat -d -d -d TCP-LISTEN:2225,reuseaddr UNIX-CONNECT:/var/run/containerd/containerd.sock
# on the Host
socat -d -d -d UNIX-LISTEN:$(pwd)/containerd.socket TCP-CONNECT:10.0.2.11:2225,reuseaddr,fork
```