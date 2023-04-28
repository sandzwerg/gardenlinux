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

## 2. Setup Network

```
# Edit variables in prepare-network.sh 
make network
```

## 3. Start firecracker
```
make start-firecracker  
# Keep this process running, and open a second terminal
```
## 4. Start VM
In a second terminal start the VM via

```
make start  
```




# Issues

## containerd OOM after startup
```
 containerd invoked oom-killer: gfp_mask=0x140cca(GFP_HIGHUSER_MOVABLE|__GFP_COMP), order=0, oom_score_adj=-999
```

## Garden Linux test fails when including chost in firecracker
adding `chost` to included features of firecracker will result in a failing test:

<details>
<summary> Test Log </summary>

```
  _________________ test_sgid_suid_files[suid-whitelist_files1] __________________

client = <helper.sshclient.RemoteClient object at 0x7f705f9eba50>
test_type = 'suid'
whitelist_files = ['/usr/bin/chsh,root,root', '/usr/lib/openssh/ssh-keysign,root,root', '/usr/bin/newgrp,root,root', '/usr/bin/su,root,root', '/usr/lib/dbus-1.0/dbus-daemon-launch-helper,root,messagebus', '/usr/bin/chfn,root,root', ...]
non_vhost = None

    @pytest.mark.parametrize(
         "test_type,whitelist_files",
        [
            ("sgid", [
                     "/usr/bin/expiry,root,shadow",
                     "/usr/bin/write,root,tty",
                     "/usr/bin/wall,root,tty",
                     "/usr/bin/chage,root,shadow",
                     "/usr/bin/ssh-agent,root,_ssh",
                     "/usr/sbin/unix_chkpwd,root,shadow",
                     "/usr/lib/systemd-cron/crontab_setgid,root,crontab",
                     ]
            ),
            ("suid", [
                     "/usr/bin/chsh,root,root",
                     "/usr/lib/openssh/ssh-keysign,root,root",
                     "/usr/bin/newgrp,root,root",
                     "/usr/bin/su,root,root",
                     "/usr/lib/dbus-1.0/dbus-daemon-launch-helper,root,messagebus",
                     "/usr/bin/chfn,root,root",
                     "/usr/bin/gpasswd,root,root",
                     "/usr/bin/sudo,root,root",
                     "/usr/bin/passwd,root,root",
                     "/usr/lib/polkit-1/polkit-agent-helper-1,root,root",
                     "/usr/bin/pkexec,root,root"
                     ]
            )
        ]
    )
    
    
    # Run the test unit to perform the
    # final tests by the given artifact.
    def test_sgid_suid_files(client, test_type, whitelist_files, non_vhost):
>       sgid_suid_files(client, test_type, whitelist_files)

client     = <helper.sshclient.RemoteClient object at 0x7f705f9eba50>
non_vhost  = None
test_type  = 'suid'
whitelist_files = ['/usr/bin/chsh,root,root', '/usr/lib/openssh/ssh-keysign,root,root', '/usr/bin/newgrp,root,root', '/usr/bin/su,root,root', '/usr/lib/dbus-1.0/dbus-daemon-launch-helper,root,messagebus', '/usr/bin/chfn,root,root', ...]

../features/base/test/test_sgid_suid_files.py:40: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
helper/tests/sgid_suid_files.py:8: in sgid_suid_files
    _val_whitelist_files(remote_files, whitelist_files)
        client     = <helper.sshclient.RemoteClient object at 0x7f705f9eba50>
        id_type    = 'suid'
        remote_files = ['/usr/lib/polkit-1/polkit-agent-helper-1,root,root', '/usr/lib/openssh/ssh-keysign,root,root', '/usr/lib/dbus-1.0/dbu...n-launch-helper,root,messagebus', '/usr/bin/sudo,root,root', '/usr/bin/su,root,root', '/usr/bin/pkexec,root,root', ...]
        whitelist_files = ['/usr/bin/chsh,root,root', '/usr/lib/openssh/ssh-keysign,root,root', '/usr/bin/newgrp,root,root', '/usr/bin/su,root,root', '/usr/lib/dbus-1.0/dbus-daemon-launch-helper,root,messagebus', '/usr/bin/chfn,root,root', ...]
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

remote_files = ['/usr/lib/polkit-1/polkit-agent-helper-1,root,root', '/usr/lib/openssh/ssh-keysign,root,root', '/usr/lib/dbus-1.0/dbu...n-launch-helper,root,messagebus', '/usr/bin/sudo,root,root', '/usr/bin/su,root,root', '/usr/bin/pkexec,root,root', ...]
whitelist_files = ['/usr/bin/chsh,root,root', '/usr/lib/openssh/ssh-keysign,root,root', '/usr/bin/newgrp,root,root', '/usr/bin/su,root,root', '/usr/lib/dbus-1.0/dbus-daemon-launch-helper,root,messagebus', '/usr/bin/chfn,root,root', ...]

    def _val_whitelist_files(remote_files, whitelist_files):
        """ Validates that remotly found files are in whitelist """
        found_files = []
        for file in remote_files:
            if file not in whitelist_files:
                found_files.append(file)
>       assert not found_files, f"{found_files}"
E       AssertionError: ['/usr/bin/newuidmap,root,root', '/usr/bin/newgidmap,root,root']

file       = '/usr/bin/chfn,root,root'
found_files = ['/usr/bin/newuidmap,root,root', '/usr/bin/newgidmap,root,root']
remote_files = ['/usr/lib/polkit-1/polkit-agent-helper-1,root,root', '/usr/lib/openssh/ssh-keysign,root,root', '/usr/lib/dbus-1.0/dbu...n-launch-helper,root,messagebus', '/usr/bin/sudo,root,root', '/usr/bin/su,root,root', '/usr/bin/pkexec,root,root', ...]
whitelist_files = ['/usr/bin/chsh,root,root', '/usr/lib/openssh/ssh-keysign,root,root', '/usr/bin/newgrp,root,root', '/usr/bin/su,root,root', '/usr/lib/dbus-1.0/dbus-daemon-launch-helper,root,messagebus', '/usr/bin/chfn,root,root', ...]

helper/tests/sgid_suid_files.py:32: AssertionError
```
</details>



