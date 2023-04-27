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
make firecracker_dev
```

## 2. Setup firecracker

``` 
# Start firecracker and use a temp socket

API_SOCKET="./firecracker.socket"
rm -f "$API_SOCKET"
firecracker --api-sock "${API_SOCKET}"

# Setup Network
# TODO: what do we actually do here?
# - create a tap device
# - configure the tap device to have access to internet
#    - iptable rules 
#    - ip forwarding
# https://github.com/firecracker-microvm/firecracker/blob/main/docs/getting-started.md#running-firecracker


... continue here ...

```

