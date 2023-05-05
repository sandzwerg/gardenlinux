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

- generate a test sshkey and add it to `/home/dev/.ssh/authorized_keys` via console spawned by `make prepare-host`
- TODO: ... continue to do the work and document here....
    - using /etc/containerd/config.toml settings.. do they already provide everything we need?
        - API scope enough if using tcp? https://github.com/containerd/containerd/issues/3466#issuecomment-516204803
        - suitable client to use the tcp endpoint?


- CRI-O probieren? (same problem as containerd)
- virtio vsock? (requires extra management overhead to initialize connection)
- socat?

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