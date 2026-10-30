# GitHub Actions to Free Disk Space on Ubuntu runners

A customizable GitHub Actions to free disk space on Linux GitHub Actions
runners.

A hard fork of https://github.com/jlumbroso/free-disk-space, that comes with
extra options and **no support**. The use case here is mostly to be used with
[Nix](https://nixos.org/) since Nix builders tends to be self-contained, but it
may be useful in other contexts too.

See the table below for available free space in the runner before and after the
action with commit
[44f33bad](https://github.com/thiagokokada/free-disk-space/commit/44f33bad836ef29fc1fde0e3a1700e3dc8d637b8).

| runner                             | before | after  | diff |
|------------------------------------|--------|--------|------|
| ubuntu-24.04                       | 86G    | 134G   | 48G  |
| ubuntu-26.04                       | 88G    | 134G   | 46G  |
| ubuntu-26.04 (including optionals) | 88G    | 136G   | 48G  |

Keep in mind that the numbers above depends on the actual instance that the
runner is run, i.e., you can have more or less free space depending on how much
the instance has initially.

This action is also fast, generally taking less than 1 minute with default
options, since it runs deletion in parallel and doesn't depend in `apt` to
remove packages.

## Example

It is recommended to look at the [source
code](https://github.com/thiagokokada/free-disk-space/blob/main/script.sh) for
the action and look at all available inputs and see which ones may affect you.
By default it will pretty much remove support for any of the pre-installed
programming languages, but it will try to keep support for common Linux tools.

I also recommend you to fork and adapt this accordingly to your needs. Again,
this comes with **no support**. If you want to use this repository directly I
recommend you to pin a specific commit.

```yaml
name: Free Disk Space (Ubuntu)
on: push

jobs:
  free-disk-space:
    runs-on: ubuntu-latest
    steps:

    - name: Free Disk Space (Ubuntu)
      uses: thiagokokada/free-disk-space@main
      with:
        # this might remove tools that are actually needed, but is enabled by
        # default
        tool-cache: false
        # possible dangerous options since they delete whole directories that
        # are generally for third-party software or cache like /usr/local,
        # /var/cache, only use them if you know what you're doing
        usrmisc: true
        usrlocal: true
        varcache: true
        # this will run `du -h /* 2>/dev/null | sort -hr | head -n <N>` to show
        # the top N directories by size, it is mostly used by development/debug
        # and should not be used generally since it takes a while to calculate
        debug: false
```

## Acknowledgement

Here are a few sources of inspiration:
- https://github.community/t/bigger-github-hosted-runners-disk-space/17267/11
- https://github.com/apache/flink/blob/master/tools/azure-pipelines/free_disk_space.sh
- https://github.com/ShubhamTatvamasi/free-disk-space-action
- https://github.com/actions/virtual-environments/issues/2875#issuecomment-1163392159
- https://github.com/easimon/maximize-build-space/
- https://github.com/jlumbroso/free-disk-space
- https://github.com/lucasew/action-i-only-care-about-nix

## Typical Output

The log output of a typical example (with all options set to `true`) looks like
this:

```
================================================================================
BEFORE CLEAN-UP:

$ dh -ha
Filesystem      Size  Used Avail Use% Mounted on
/dev/root       145G   58G   87G  41% /
devtmpfs        7.1G     0  7.1G   0% /dev
proc               0     0     0    - /proc
sysfs              0     0     0    - /sys
securityfs         0     0     0    - /sys/kernel/security
tmpfs           7.9G     0  7.9G   0% /dev/shm
devpts             0     0     0    - /dev/pts
tmpfs           3.2G  1.0M  3.2G   1% /run
cgroup2            0     0     0    - /sys/fs/cgroup
none               0     0     0    - /sys/fs/pstore
efivarfs           0     0     0    - /sys/firmware/efi/efivars
bpf                0     0     0    - /sys/fs/bpf
systemd-1          -     -     -    - /proc/sys/fs/binfmt_misc
debugfs            0     0     0    - /sys/kernel/debug
mqueue             0     0     0    - /dev/mqueue
hugetlbfs          0     0     0    - /dev/hugepages
tracefs            0     0     0    - /sys/kernel/tracing
none            1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
configfs           0     0     0    - /sys/kernel/config
fusectl            0     0     0    - /sys/fs/fuse/connections
none            1.0M     0  1.0M   0% /run/credentials/systemd-resolved.service
/dev/sda13      989M   84M  838M  10% /boot
/dev/sda15      105M  6.3M   99M   7% /boot/efi
binfmt_misc        0     0     0    - /proc/sys/fs/binfmt_misc
none            1.0M     0  1.0M   0% /run/credentials/systemd-networkd.service
tmpfs           1.6G  8.0K  1.6G   1% /run/user/1001
none            1.0M     0  1.0M   0% /run/credentials/getty@tty1.service
none            1.0M     0  1.0M   0% /run/credentials/serial-getty@ttyS0.service

$ free -h
               total        used        free      shared  buff/cache   available
Mem:            15Gi       1.1Gi        12Gi        47Mi       2.1Gi        14Gi
Swap:          3.0Gi          0B       3.0Gi

================================================================================
********************************************************************************
=> Heroku: Saved  152MiB
********************************************************************************
********************************************************************************
=> Mono runtime: Saved  152MiB
********************************************************************************
********************************************************************************
=> Julia runtime: Saved  152MiB
********************************************************************************
********************************************************************************
=> Apt: Saved  2.6GiB
********************************************************************************
********************************************************************************
=> MySQL: Saved  2.9GiB
********************************************************************************
********************************************************************************
=> Snap: Saved  3.5GiB
********************************************************************************
********************************************************************************
=> GCC: Saved  8.8GiB
********************************************************************************
********************************************************************************
=> Rust runtime: Saved  9.2GiB
********************************************************************************
********************************************************************************
=> Browsers: Saved   11GiB
********************************************************************************
********************************************************************************
=> Powershell runtime: Saved   12GiB
********************************************************************************
********************************************************************************
=> Swift runtime: Saved   14GiB
********************************************************************************
********************************************************************************
=> JVM runtime: Saved   15GiB
********************************************************************************
********************************************************************************
=> PostgreSQL: Saved   15GiB
********************************************************************************
********************************************************************************
=> LLVM: Saved   20GiB
********************************************************************************
********************************************************************************
=> Node runtime: Saved   21GiB
********************************************************************************
********************************************************************************
=> Haskell runtime: Saved   21GiB
********************************************************************************
********************************************************************************
=> Az: Saved   30GiB
********************************************************************************
********************************************************************************
=> Ruby runtime: Saved   30GiB
********************************************************************************
********************************************************************************
=> .NET runtime: Saved   38GiB
********************************************************************************
********************************************************************************
=> Docker images: Saved   39GiB
********************************************************************************
********************************************************************************
=> Python runtime: Saved   40GiB
********************************************************************************
********************************************************************************
=> Google Cloud SDK: Saved   40GiB
********************************************************************************
********************************************************************************
=> Tool cache: Saved   45GiB
********************************************************************************
********************************************************************************
=> Android library: Saved   46GiB
********************************************************************************

================================================================================
AFTER CLEAN-UP:

$ dh -ha
Filesystem      Size  Used Avail Use% Mounted on
/dev/root       145G   12G  133G   8% /
devtmpfs        7.1G     0  7.1G   0% /dev
proc               0     0     0    - /proc
sysfs              0     0     0    - /sys
securityfs         0     0     0    - /sys/kernel/security
tmpfs           7.9G     0  7.9G   0% /dev/shm
devpts             0     0     0    - /dev/pts
tmpfs           3.2G  1.0M  3.2G   1% /run
cgroup2            0     0     0    - /sys/fs/cgroup
none               0     0     0    - /sys/fs/pstore
efivarfs           0     0     0    - /sys/firmware/efi/efivars
bpf                0     0     0    - /sys/fs/bpf
systemd-1          -     -     -    - /proc/sys/fs/binfmt_misc
debugfs            0     0     0    - /sys/kernel/debug
mqueue             0     0     0    - /dev/mqueue
hugetlbfs          0     0     0    - /dev/hugepages
tracefs            0     0     0    - /sys/kernel/tracing
none            1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
configfs           0     0     0    - /sys/kernel/config
fusectl            0     0     0    - /sys/fs/fuse/connections
none            1.0M     0  1.0M   0% /run/credentials/systemd-resolved.service
/dev/sda13      989M   84M  838M  10% /boot
/dev/sda15      105M  6.3M   99M   7% /boot/efi
binfmt_misc        0     0     0    - /proc/sys/fs/binfmt_misc
none            1.0M     0  1.0M   0% /run/credentials/systemd-networkd.service
tmpfs           1.6G  8.0K  1.6G   1% /run/user/1001
none            1.0M     0  1.0M   0% /run/credentials/getty@tty1.service
none            1.0M     0  1.0M   0% /run/credentials/serial-getty@ttyS0.service

$ free -h
               total        used        free      shared  buff/cache   available
Mem:            15Gi       1.0Gi        12Gi        48Mi       2.7Gi        14Gi
Swap:          3.0Gi          0B       3.0Gi

================================================================================
********************************************************************************
=> Saved   46GiB
********************************************************************************
```
