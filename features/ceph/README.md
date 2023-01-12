## Feature: ceph
### Description
<website-feature>
The `ceph` feature adjusts Garden Linux to support running ceph container workload.
</website-feature>

### Features
The `ceph` feature adjusts Garden Linux to support running ceph container workload and installs and configures all related packages like `chrony`.

### Unit testing
To be fully complaint these unit tests validate the extended capabilities on `chrony`, the installed packages, correctly defined suids and sgids as well as the systemd unit files.

### Meta
|||
|---|---|
|type|element|
|artifact|None|
|included_features|server|
|excluded_features|None|
