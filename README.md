# GitHub Actions to Free Disk Space on Ubuntu runners

A customizable GitHub Actions to free disk space on Linux GitHub Actions
runners.

A hard fork of https://github.com/jlumbroso/free-disk-space, that comes with
extra options and **no support**. The use case here is mostly to be used with
[Nix](https://nixos.org/) since Nix builders tends to be self-contained, but it
may be useful in other contexts too.

See the table below for available free space in the runner before and after the
action with commit
[d6963712](https://github.com/thiagokokada/free-disk-space/commit/d6963712fc4596d95a7f83718242c072337a5368).

| runner                             | before | after | diff | swap |
|------------------------------------|--------|-------|------|------|
| ubuntu-22.04                       | 22G    | 66G   | 44G  | 4G   |
| ubuntu-22.04 (including optionals) | 22G    | 69G   | 47G  | 0    |
| ubuntu-24.04                       | 29G    | 66G   | 37G  | 4G   |

This action is also fast, generally taking less than 1 minute with default
options, since it runs deletion in parallel and doesn't depend in `apt` to
remove packages.

Swap storage actually seems useless to remove in recent version of GitHub
runners (maybe because they're not using swap file anymore?), but it still
provided as an option for backwards compatibility.

## Example

It is recommended to look at the [source
code](https://github.com/thiagokokada/free-disk-space/blob/main/action.yml) for
the action and look at all available inputs and see which ones may affect you.
By default it will pretty much remove support for any of the pre-installed
programming languages, but it will try to keep support for common Linux tools
and `apt`, so you can still install more things if needed.
I also recommend you to fork and adapt this accordingly to your needs. Again,
this comes with **no support**. If you want to use this repository directly
I recommend you to pin a specific commit.

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
        # /opt, /var/cache, only use them if you know what you're doing
        usrmisc: true
        usrlocal: true
        opt: true
        varcache: true
        # technically frees up to 4 GiB, but see note above about it being
        # useless, and can also cause Out-of-Memory errors in bigger builds,
        # so disabled by default
        swap-storage: true
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
/dev/root        72G   44G   29G  61% /
devtmpfs        7.9G     0  7.9G   0% /dev
proc               0     0     0    - /proc
sysfs              0     0     0    - /sys
securityfs         0     0     0    - /sys/kernel/security
tmpfs           7.9G   84K  7.9G   1% /dev/shm
devpts             0     0     0    - /dev/pts
tmpfs           3.2G  1.1M  3.2G   1% /run
tmpfs           5.0M     0  5.0M   0% /run/lock
cgroup2            0     0     0    - /sys/fs/cgroup
pstore             0     0     0    - /sys/fs/pstore
bpf                0     0     0    - /sys/fs/bpf
systemd-1          -     -     -    - /proc/sys/fs/binfmt_misc
hugetlbfs          0     0     0    - /dev/hugepages
mqueue             0     0     0    - /dev/mqueue
debugfs            0     0     0    - /sys/kernel/debug
tracefs            0     0     0    - /sys/kernel/tracing
fusectl            0     0     0    - /sys/fs/fuse/connections
configfs           0     0     0    - /sys/kernel/config
/dev/sdb16      881M   59M  761M   8% /boot
/dev/sdb15      105M  6.1M   99M   6% /boot/efi
binfmt_misc        0     0     0    - /proc/sys/fs/binfmt_misc
/dev/sda1        74G  4.1G   66G   6% /mnt
tmpfs           1.6G   12K  1.6G   1% /run/user/1001

$ free -h
               total        used        free      shared  buff/cache   available
Mem:            15Gi       910Mi         9Gi        60Mi       5.1Gi        14Gi
Swap:          4.0Gi          0B       4.0Gi
================================================================================


********************************************************************************
=> Heroku: Saved 505MiB
********************************************************************************


********************************************************************************
=> Mono runtime: Saved 3.4GiB
********************************************************************************


********************************************************************************
=> MySQL: Saved 3.5GiB
********************************************************************************


********************************************************************************
=> Browsers: Saved 4.0GiB
********************************************************************************


********************************************************************************
=> GCC: Saved 7.5GiB
********************************************************************************


********************************************************************************
=> Rust runtime: Saved 7.5GiB
********************************************************************************


********************************************************************************
=> Snap: Saved 4.2GiB
********************************************************************************


********************************************************************************
=> PostgreSQL: Saved 8.5GiB
********************************************************************************


********************************************************************************
=> Powershell runtime: Saved 11GiB
********************************************************************************


********************************************************************************
=> JVM runtime: Saved 12GiB
********************************************************************************


********************************************************************************
=> Swift runtime: Saved 12GiB
********************************************************************************


********************************************************************************
=> .NET runtime: Saved 15GiB
********************************************************************************


********************************************************************************
=> Julia runtime: Saved 16GiB
********************************************************************************


********************************************************************************
=> LLVM: Saved 18GiB
********************************************************************************


********************************************************************************
=> AWS CLI: Saved 20GiB
********************************************************************************


********************************************************************************
=> Haskell runtime: Saved 22GiB
********************************************************************************


********************************************************************************
=> Node runtime: Saved 24GiB
********************************************************************************


********************************************************************************
=> Az: Saved 24GiB
********************************************************************************


********************************************************************************
=> Google Cloud SDK: Saved 25GiB
********************************************************************************


********************************************************************************
=> Python runtime: Saved 25GiB
********************************************************************************


********************************************************************************
=> Ruby runtime: Saved 25GiB
********************************************************************************


********************************************************************************
=> Tool cache: Saved 35GiB
********************************************************************************


********************************************************************************
=> Docker images: Saved 1.2GiB
********************************************************************************


********************************************************************************
=> Android library: Saved 38GiB
********************************************************************************


********************************************************************************
=> /usr/src and /usr/{,local}/share/{man,doc,icons}: Saved 3.0GiB
********************************************************************************


================================================================================
AFTER CLEAN-UP:

$ dh -ha
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        72G  5.0G   67G   7% /
devtmpfs        7.9G     0  7.9G   0% /dev
proc               0     0     0    - /proc
sysfs              0     0     0    - /sys
securityfs         0     0     0    - /sys/kernel/security
tmpfs           7.9G   84K  7.9G   1% /dev/shm
devpts             0     0     0    - /dev/pts
tmpfs           3.2G  1.1M  3.2G   1% /run
tmpfs           5.0M     0  5.0M   0% /run/lock
cgroup2            0     0     0    - /sys/fs/cgroup
pstore             0     0     0    - /sys/fs/pstore
bpf                0     0     0    - /sys/fs/bpf
systemd-1          -     -     -    - /proc/sys/fs/binfmt_misc
hugetlbfs          0     0     0    - /dev/hugepages
mqueue             0     0     0    - /dev/mqueue
debugfs            0     0     0    - /sys/kernel/debug
tracefs            0     0     0    - /sys/kernel/tracing
fusectl            0     0     0    - /sys/fs/fuse/connections
configfs           0     0     0    - /sys/kernel/config
/dev/sdb16      881M   59M  761M   8% /boot
/dev/sdb15      105M  6.1M   99M   6% /boot/efi
binfmt_misc        0     0     0    - /proc/sys/fs/binfmt_misc
/dev/sda1        74G  4.1G   66G   6% /mnt
tmpfs           1.6G   12K  1.6G   1% /run/user/1001
tracefs            -     -     -    - /sys/kernel/debug/tracing

$ free -h
               total        used        free      shared  buff/cache   available
Mem:            15Gi       897Mi       9.5Gi        66Mi       5.6Gi        14Gi
Swap:          4.0Gi          0B       4.0Gi
================================================================================


********************************************************************************
=> Saved 38GiB
********************************************************************************
```

Keep in mind that each `Saved` part is the cumulative storage saved up-to that
point (i.e.: not only for that particular step), and since everything is
running in parallel it may show out of order.
