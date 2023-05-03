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
#    - allocated memory and cpu in prepare-vm.sh
make start-vm 
```

# Todos
- expose containerd socket
    - Issue 1: exposing via tcp_address setting in /etc/containerd/config.toml. does it really expose all parts of the API? 
    - Issue 2: nerdctl and crictl seem to not support TCP endpoints

