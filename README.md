# GitHub Actions to Free Disk Space on Ubuntu runners

A customizable GitHub Actions to free disk space on Linux GitHub Actions
runners.

On a typical Ubuntu runner, with default options turned on, this can clear up
to about 45 GiB of disk space (or about 51 GiB with all options enabled) in
`ubuntu-22.04` runner (or about 38GiB in `ubuntu-24.04`, but keep in mind that
the free space is similar because the image itself is smaller). It is also fast
(generally less than 1 minute with default options) since it runs deletion in
parallel and doesn't depend in `apt` to remove packages.

A hard fork of https://github.com/jlumbroso/free-disk-space, that comes with
extra options and **no support**. The use case here is mostly to be used with
[Nix](https://nixos.org/) since Nix builders tends to be self-contained, but it
may be useful in other contexts too.

## Example

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
        usrlocal: true
        opt: true
        varcache: true
        # frees up 4 GiB, but you may also run Out-of-Memory since memory in
        # builders are relatively low, so it is also disabled by default
        swap-storage: true
        # this will run `du -h /* 2>/dev/null | sort -hr | head -n <N>` to show
        # the top N directories by size, it is mostly used by development/debug
        # and should not be used generally since it takes a while to calculate
        debug: false
```

## Acknowledgement

This GitHub Actions came around because I kept rewriting the same few lines of `rm -rf` code.

Here are a few sources of inspiration:
- https://github.community/t/bigger-github-hosted-runners-disk-space/17267/11
- https://github.com/apache/flink/blob/master/tools/azure-pipelines/free_disk_space.sh
- https://github.com/ShubhamTatvamasi/free-disk-space-action
- https://github.com/actions/virtual-environments/issues/2875#issuecomment-1163392159
- https://github.com/easimon/maximize-build-space/
- https://github.com/jlumbroso/free-disk-space

## Typical Output

The log output of a typical example (with all options set to `true`) looks like
this:

```
================================================================================
BEFORE CLEAN-UP:

$ dh -ha
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        73G   52G   22G  71% /
devtmpfs        7.9G     0  7.9G   0% /dev
proc               0     0     0    - /proc
sysfs              0     0     0    - /sys
securityfs         0     0     0    - /sys/kernel/security
tmpfs           7.9G  172K  7.9G   1% /dev/shm
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
configfs           0     0     0    - /sys/kernel/config
fusectl            0     0     0    - /sys/fs/fuse/connections
ramfs              0     0     0    - /run/credentials/systemd-sysusers.service
/dev/loop0       64M   64M     0 100% /snap/core20/2379
/dev/loop1       88M   88M     0 100% /snap/lxd/29351
/dev/loop2       39M   39M     0 100% /snap/snapd/21759
/dev/sda15      105M  6.1M   99M   6% /boot/efi
binfmt_misc        0     0     0    - /proc/sys/fs/binfmt_misc
/dev/sdb1        74G  4.1G   66G   6% /mnt
tmpfs           3.2G  1.1M  3.2G   1% /run/snapd/ns
tmpfs           1.6G   12K  1.6G   1% /run/user/1001
nsfs               0     0     0    - /run/snapd/ns/lxd.mnt

$ free -h
               total        used        free      shared  buff/cache   available
Mem:            15Gi       568Mi        13Gi        61Mi       1.1Gi        14Gi
Swap:          4.0Gi          0B       4.0Gi

$ du -h /* 2>/dev/null | sort -hr | head -n 100
34G	/usr
20G	/usr/local
12G	/opt
8.8G	/usr/local/lib
8.7G	/opt/hostedtoolcache
7.8G	/usr/local/lib/android/sdk
7.8G	/usr/local/lib/android
6.8G	/usr/lib
6.3G	/usr/share
5.5G	/usr/local/.ghcup/ghc
5.5G	/usr/local/.ghcup
5.2G	/opt/hostedtoolcache/CodeQL/2.19.3/x64/codeql
5.2G	/opt/hostedtoolcache/CodeQL/2.19.3/x64
5.2G	/opt/hostedtoolcache/CodeQL/2.19.3
5.2G	/opt/hostedtoolcache/CodeQL
4.1G	/mnt
4.0G	/usr/local/lib/android/sdk/ndk
3.7G	/var
3.5G	/var/lib
3.0G	/opt/hostedtoolcache/CodeQL/2.19.3/x64/codeql/swift
2.8G	/usr/local/.ghcup/ghc/9.10.1
2.7G	/usr/local/.ghcup/ghc/9.8.2
2.6G	/usr/share/swift/usr
2.6G	/usr/share/swift
2.6G	/opt/hostedtoolcache/CodeQL/2.19.3/x64/codeql/swift/resource-dir
2.5G	/var/lib/docker/overlay2
2.5G	/var/lib/docker
2.1G	/usr/local/lib/android/sdk/ndk/26.3.11579264
2.1G	/usr/local/.ghcup/ghc/9.10.1/lib/ghc-9.10.1
2.1G	/usr/local/.ghcup/ghc/9.10.1/lib
2.0G	/usr/local/share
2.0G	/usr/local/lib/android/sdk/ndk/27.2.12479018
2.0G	/usr/local/lib/android/sdk/ndk/26.3.11579264/toolchains/llvm/prebuilt/linux-x86_64
2.0G	/usr/local/lib/android/sdk/ndk/26.3.11579264/toolchains/llvm/prebuilt
2.0G	/usr/local/lib/android/sdk/ndk/26.3.11579264/toolchains/llvm
2.0G	/usr/local/lib/android/sdk/ndk/26.3.11579264/toolchains
2.0G	/usr/local/.ghcup/ghc/9.8.2/lib/ghc-9.8.2
2.0G	/usr/local/.ghcup/ghc/9.8.2/lib
2.0G	/usr/local/.ghcup/ghc/9.10.1/lib/ghc-9.10.1/lib/x86_64-linux-ghc-9.10.1
2.0G	/usr/local/.ghcup/ghc/9.10.1/lib/ghc-9.10.1/lib
2.0G	/opt/hostedtoolcache/CodeQL/2.19.3/x64/codeql/swift/resource-dir/osx64
2.0G	/home
1.9G	/usr/local/lib/android/sdk/ndk/27.2.12479018/toolchains/llvm/prebuilt/linux-x86_64
1.9G	/usr/local/lib/android/sdk/ndk/27.2.12479018/toolchains/llvm/prebuilt
1.9G	/usr/local/lib/android/sdk/ndk/27.2.12479018/toolchains/llvm
1.9G	/usr/local/lib/android/sdk/ndk/27.2.12479018/toolchains
1.9G	/usr/local/.ghcup/ghc/9.8.2/lib/ghc-9.8.2/lib/x86_64-linux-ghc-9.8.2
1.9G	/usr/local/.ghcup/ghc/9.8.2/lib/ghc-9.8.2/lib
1.7G	/usr/local/lib/android/sdk/platforms
1.6G	/usr/share/dotnet
1.6G	/opt/hostedtoolcache/Python
1.4G	/usr/share/swift/usr/lib
1.2G	/usr/share/swift/usr/bin
1.2G	/usr/local/share/powershell/Modules
1.2G	/usr/local/share/powershell
1.2G	/usr/local/lib/android/sdk/build-tools
1.2G	/usr/local/bin
1.2G	/usr/lib/jvm
1.2G	/home/runner
1.1G	/usr/share/dotnet/sdk
1.1G	/usr/local/lib/node_modules
1.1G	/usr/lib/x86_64-linux-gnu
998M	/usr/local/lib/android/sdk/ndk/26.3.11579264/toolchains/llvm/prebuilt/linux-x86_64/lib
925M	/usr/lib/google-cloud-sdk
886M	/usr/local/lib/android/sdk/ndk/27.2.12479018/toolchains/llvm/prebuilt/linux-x86_64/lib
869M	/usr/bin
868M	/usr/local/.ghcup/ghc/9.10.1/lib/ghc-9.10.1/lib/x86_64-linux-ghc-9.10.1/ghc-9.10.1-69c3
856M	/usr/local/julia1.11.1
831M	/usr/local/.ghcup/ghc/9.8.2/lib/ghc-9.8.2/lib/x86_64-linux-ghc-9.8.2/ghc-9.8.2-6af5
765M	/opt/hostedtoolcache/go
764M	/usr/local/.ghcup/ghc/9.10.1/share/doc
764M	/usr/local/.ghcup/ghc/9.10.1/share
763M	/usr/local/.ghcup/ghc/9.10.1/share/doc/ghc-9.10.1
748M	/opt/microsoft
746M	/opt/az
735M	/usr/local/lib/android/sdk/ndk/27.2.12479018/toolchains/llvm/prebuilt/linux-x86_64/bin
727M	/usr/local/.ghcup/ghc/9.10.1/share/doc/ghc-9.10.1/html
723M	/usr/local/lib/android/sdk/extras
716M	/opt/az/lib
706M	/opt/az/lib/python3.12
698M	/usr/local/.ghcup/ghc/9.8.2/share/doc
698M	/usr/local/.ghcup/ghc/9.8.2/share
698M	/usr/local/.ghcup/ghc/9.10.1/share/doc/ghc-9.10.1/html/libraries
697M	/usr/local/.ghcup/ghc/9.8.2/share/doc/ghc-9.8.2
693M	/usr/share/swift/usr/lib/swift
690M	/usr/local/lib/android/sdk/ndk/26.3.11579264/toolchains/llvm/prebuilt/linux-x86_64/bin
664M	/opt/hostedtoolcache/PyPy
663M	/usr/local/.ghcup/ghc/9.8.2/share/doc/ghc-9.8.2/html
656M	/usr/share/miniconda
655M	/etc
644M	/home/runneradmin
644M	/etc/skel
638M	/opt/az/lib/python3.12/site-packages
635M	/usr/local/.ghcup/ghc/9.8.2/share/doc/ghc-9.8.2/html/libraries
625M	/snap
616M	/opt/hostedtoolcache/CodeQL/2.19.3/x64/codeql/swift/resource-dir/osx64/macosx
608M	/opt/hostedtoolcache/CodeQL/2.19.3/x64/codeql/swift/resource-dir/linux64
603M	/usr/local/lib/android/sdk/ndk/27.2.12479018/toolchains/llvm/prebuilt/linux-x86_64/lib/clang/18
603M	/usr/local/lib/android/sdk/ndk/27.2.12479018/toolchains/llvm/prebuilt/linux-x86_64/lib/clang
591M	/var/lib/docker/overlay2/49eeda0ef8105af226598ad7cc9d17d2930d0b0ec45757dbd2b59fecc787f9e5/diff

================================================================================


********************************************************************************
=> /var/cache: Saved 166MiB
********************************************************************************


********************************************************************************
=> Snap: Saved 308MiB
********************************************************************************


********************************************************************************
=> GCC: Saved 3.9GiB
********************************************************************************


********************************************************************************
=> Browsers: Saved 5.6GiB
********************************************************************************


********************************************************************************
=> Rust runtime: Saved 11GiB
********************************************************************************


********************************************************************************
=> Powershell runtime: Saved 12GiB
********************************************************************************


********************************************************************************
=> JVM runtime: Saved 14GiB
********************************************************************************


********************************************************************************
=> Swift runtime: Saved 14GiB
********************************************************************************


********************************************************************************
=> Mono runtime: Saved 16GiB
********************************************************************************


********************************************************************************
=> Julia runtime: Saved 17GiB
********************************************************************************


********************************************************************************
=> LLVM: Saved 20GiB
********************************************************************************


********************************************************************************
=> .NET runtime: Saved 21GiB
********************************************************************************


********************************************************************************
=> AWS CLI: Saved 24GiB
********************************************************************************


********************************************************************************
=> Miniconda runtime: Saved 24GiB
********************************************************************************


********************************************************************************
=> Haskell runtime: Saved 25GiB
********************************************************************************


********************************************************************************
=> Heroku: Saved 26GiB
********************************************************************************


********************************************************************************
=> Az: Saved 29GiB
********************************************************************************


********************************************************************************
=> Python runtime: Saved 30GiB
********************************************************************************


********************************************************************************
=> Rust runtime: Saved 36GiB
********************************************************************************


********************************************************************************
=> Google Cloud SDK: Saved 36GiB
********************************************************************************


********************************************************************************
=> Node runtime: Saved 37GiB
********************************************************************************


********************************************************************************
=> Tool cache: Saved 41GiB
********************************************************************************


********************************************************************************
=> Swap storage: Saved 4.2GiB
********************************************************************************


********************************************************************************
=> /opt: Saved 4.4GiB
********************************************************************************


********************************************************************************
=> Android library: Saved 48GiB
********************************************************************************


********************************************************************************
=> /usr/local: Saved 8.1GiB
********************************************************************************


********************************************************************************
=> /usr/src and /usr/{,local}/share/{man,doc,icons}: Saved 8.2GiB
********************************************************************************


********************************************************************************
=> Docker images: Saved 9.2GiB
********************************************************************************


================================================================================
AFTER CLEAN-UP:

$ dh -ha
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        73G  4.1G   69G   6% /
devtmpfs        7.9G     0  7.9G   0% /dev
proc               0     0     0    - /proc
sysfs              0     0     0    - /sys
securityfs         0     0     0    - /sys/kernel/security
tmpfs           7.9G  172K  7.9G   1% /dev/shm
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
configfs           0     0     0    - /sys/kernel/config
fusectl            0     0     0    - /sys/fs/fuse/connections
ramfs              0     0     0    - /run/credentials/systemd-sysusers.service
/dev/sda15      105M  6.1M   99M   6% /boot/efi
binfmt_misc        0     0     0    - /proc/sys/fs/binfmt_misc
/dev/sdb1        74G   28K   70G   1% /mnt
tmpfs           3.2G  1.1M  3.2G   1% /run/snapd/ns
tmpfs           1.6G   12K  1.6G   1% /run/user/1001
nsfs               0     0     0    - /run/snapd/ns/lxd.mnt
tracefs            -     -     -    - /sys/kernel/debug/tracing

$ free -h
               total        used        free      shared  buff/cache   available
Mem:            15Gi       585Mi        13Gi        68Mi       1.7Gi        14Gi
Swap:             0B          0B          0B

$ du -h /* 2>/dev/null | sort -hr | head -n 100
2.8G	/usr
1.3G	/usr/lib
869M	/usr/bin
655M	/var
630M	/var/lib
600M	/usr/lib/x86_64-linux-gnu
382M	/usr/share
355M	/home
352M	/home/runner
346M	/home/runner/runners/2.321.0
346M	/home/runner/runners
266M	/home/runner/runners/2.321.0/externals
209M	/var/lib/apt/lists
209M	/var/lib/apt
180M	/var/lib/mysql
168M	/home/runner/runners/2.321.0/externals/node20
125M	/usr/lib/python3/dist-packages
125M	/usr/lib/python3
118M	/usr/libexec
116M	/usr/libexec/docker
116M	/usr/lib/modules/6.5.0-1025-azure
116M	/usr/lib/modules
115M	/usr/libexec/docker/cli-plugins
115M	/usr/lib/modules/6.5.0-1025-azure/kernel
101M	/var/lib/mysql/#innodb_redo
98M	/home/runner/runners/2.321.0/externals/node20_alpine/bin
98M	/home/runner/runners/2.321.0/externals/node20_alpine
94M	/usr/include
94M	/home/runner/runners/2.321.0/externals/node20/bin
91M	/var/lib/mecab/dic
91M	/var/lib/mecab
91M	/usr/sbin
79M	/home/runner/runners/2.321.0/bin
74M	/var/lib/dpkg
70M	/var/lib/dpkg/info
69M	/usr/lib/R
68M	/boot
65M	/usr/lib/R/library
63M	/usr/share/locale
56M	/home/runner/runners/2.321.0/externals/node20/include/node
56M	/home/runner/runners/2.321.0/externals/node20/include
54M	/home/runner/runners/2.321.0/externals/node20/include/node/openssl
53M	/home/runner/runners/2.321.0/externals/node20/include/node/openssl/archs
52M	/usr/share/mecab/dic/ipadic
52M	/usr/share/mecab/dic
52M	/usr/share/mecab
51M	/var/lib/mecab/dic/ipadic-utf8
50M	/usr/lib/modules/6.5.0-1025-azure/kernel/drivers
48M	/usr/lib/cni
48M	/usr/include/c++
43M	/usr/lib/python3.10
43M	/usr/lib/postgresql/14
43M	/usr/lib/postgresql
42M	/var/lib/postgresql/14/main
42M	/var/lib/postgresql/14
42M	/var/lib/postgresql
40M	/var/lib/mecab/dic/ipadic
36M	/usr/share/vim/vim82
36M	/usr/share/vim
35M	/usr/share/fonts/truetype
35M	/usr/share/fonts
32M	/usr/lib/x86_64-linux-gnu/dri
30M	/usr/lib/postgresql/14/lib
28M	/usr/share/python-babel-localedata/locale-data
28M	/usr/share/python-babel-localedata
28M	/usr/lib/python3/dist-packages/twisted
26M	/var/lib/waagent
26M	/usr/lib/linux-azure-6.5-tools-6.5.0-1025
25M	/var/log/journal/85ae9add133f4bec8a71b8a92a2b5337
25M	/var/log/journal
25M	/var/log
25M	/var/lib/postgresql/14/main/base
25M	/usr/lib/x86_64-linux-gnu/perl/5.34.0
25M	/usr/lib/x86_64-linux-gnu/perl
25M	/usr/lib/postgresql/14/lib/bitcode
24M	/usr/lib/modules/6.5.0-1025-azure/kernel/net
22M	/usr/lib/monodoc/sources
22M	/usr/lib/monodoc
22M	/usr/lib/modules/6.5.0-1025-azure/kernel/fs
21M	/usr/share/perl/5.34.0
21M	/usr/share/perl
21M	/usr/lib/grub
20M	/usr/lib/x86_64-linux-gnu/lapack
20M	/usr/lib/ruby
20M	/usr/lib/python3.10/config-3.10-x86_64-linux-gnu
20M	/usr/lib/postgresql/14/lib/bitcode/postgres
20M	/usr/lib/php
20M	/usr/lib/modules/6.5.0-1025-azure/kernel/drivers/net
19M	/var/lib/waagent/Microsoft.Azure.Extensions.CustomScript-2.1.10/bin
19M	/var/lib/waagent/Microsoft.Azure.Extensions.CustomScript-2.1.10
19M	/usr/lib/udev
19M	/usr/lib/php/20210902
19M	/root
18M	/usr/lib/python3/dist-packages/mercurial
18M	/usr/lib/modules/6.5.0-1025-azure/kernel/drivers/net/ethernet
18M	/home/runner/runners/2.321.0/externals/node20/lib/node_modules
18M	/home/runner/runners/2.321.0/externals/node20/lib
17M	/var/lib/postgresql/14/main/pg_wal
17M	/usr/share/i18n
17M	/home/runner/runners/2.321.0/externals/node20/lib/node_modules/npm

================================================================================


********************************************************************************
=> Saved 50GiB
********************************************************************************
```

Keep in mind that each `Saved` part is the cumulative storage saved up-to that
point (i.e.: not only for that particular step), and since everything is
running in parallel it may show out of order.
