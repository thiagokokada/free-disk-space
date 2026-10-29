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
        # /opt, /var/cache, only use them if you know what you're doing
        usrmisc: true
        usrlocal: true
        opt: true
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
/dev/root       145G   57G   88G  40% /
devtmpfs        7.1G     0  7.1G   0% /dev
proc               0     0     0    - /proc
sysfs              0     0     0    - /sys
securityfs         0     0     0    - /sys/kernel/security
tmpfs           7.9G     0  7.9G   0% /dev/shm
devpts             0     0     0    - /dev/pts
tmpfs           3.2G  1.1M  3.2G   1% /run
cgroup2            0     0     0    - /sys/fs/cgroup
none               0     0     0    - /sys/fs/pstore
efivarfs        128M   32K  128M   1% /sys/firmware/efi/efivars
bpf                0     0     0    - /sys/fs/bpf
systemd-1          -     -     -    - /proc/sys/fs/binfmt_misc
mqueue             0     0     0    - /dev/mqueue
hugetlbfs          0     0     0    - /dev/hugepages
debugfs            0     0     0    - /sys/kernel/debug
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
none            1.0M     0  1.0M   0% /run/credentials/serial-getty@ttyS0.service
none            1.0M     0  1.0M   0% /run/credentials/getty@tty1.service

$ free -h
               total        used        free      shared  buff/cache   available
Mem:            15Gi       907Mi        14Gi        40Mi       859Mi        14Gi
Swap:          3.0Gi          0B       3.0Gi

$ du -h /* 2>/dev/null | sort -hr | head -n 100
38G	/usr
19G	/usr/local
12G	/usr/local/lib/android/sdk
12G	/usr/local/lib/android
12G	/usr/local/lib
11G	/usr/share
9.2G	/opt
6.5G	/usr/local/lib/android/sdk/ndk
6.3G	/usr/lib
5.8G	/usr/share/dotnet
5.3G	/opt/hostedtoolcache
4.3G	/usr/share/dotnet/sdk
3.7G	/usr/local/.ghcup
3.6G	/usr/share/swift/usr
3.6G	/usr/share/swift
3.6G	/usr/local/.ghcup/ghc/9.14.1
3.6G	/usr/local/.ghcup/ghc
3.1G	/swapfile
2.8G	/usr/local/.ghcup/ghc/9.14.1/lib/ghc-9.14.1
2.8G	/usr/local/.ghcup/ghc/9.14.1/lib
2.7G	/usr/local/lib/android/sdk/platforms
2.7G	/usr/local/.ghcup/ghc/9.14.1/lib/ghc-9.14.1/lib/x86_64-linux-ghc-9.14.1-3203
2.7G	/usr/local/.ghcup/ghc/9.14.1/lib/ghc-9.14.1/lib
2.4G	/usr/local/lib/android/sdk/ndk/29.0.14206865
2.3G	/usr/local/share
2.3G	/usr/local/lib/android/sdk/ndk/30.0.16248370
2.3G	/usr/local/lib/android/sdk/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64
2.3G	/usr/local/lib/android/sdk/ndk/29.0.14206865/toolchains/llvm/prebuilt
2.3G	/usr/local/lib/android/sdk/ndk/29.0.14206865/toolchains/llvm
2.3G	/usr/local/lib/android/sdk/ndk/29.0.14206865/toolchains
2.1G	/usr/share/swift/usr/lib
2.1G	/usr/local/lib/android/sdk/ndk/30.0.16248370/toolchains/llvm/prebuilt/linux-x86_64
2.1G	/usr/local/lib/android/sdk/ndk/30.0.16248370/toolchains/llvm/prebuilt
2.1G	/usr/local/lib/android/sdk/ndk/30.0.16248370/toolchains/llvm
2.1G	/usr/local/lib/android/sdk/ndk/30.0.16248370/toolchains
2.0G	/usr/local/lib/android/sdk/ndk/27.3.13750724
1.9G	/usr/local/lib/android/sdk/ndk/27.3.13750724/toolchains/llvm/prebuilt/linux-x86_64
1.9G	/usr/local/lib/android/sdk/ndk/27.3.13750724/toolchains/llvm/prebuilt
1.9G	/usr/local/lib/android/sdk/ndk/27.3.13750724/toolchains/llvm
1.9G	/usr/local/lib/android/sdk/ndk/27.3.13750724/toolchains
1.7G	/opt/hostedtoolcache/Python
1.5G	/usr/share/swift/usr/bin
1.4G	/usr/local/share/powershell/Modules
1.4G	/usr/local/share/powershell
1.4G	/opt/hostedtoolcache/CodeQL/2.27.3/x64/codeql
1.4G	/opt/hostedtoolcache/CodeQL/2.27.3/x64
1.4G	/opt/hostedtoolcache/CodeQL/2.27.3
1.4G	/opt/hostedtoolcache/CodeQL
1.3G	/usr/lib/x86_64-linux-gnu
1.3G	/usr/lib/jvm
1.2G	/usr/share/swift/usr/lib/swift
1.2G	/home
1.1G	/usr/local/.ghcup/ghc/9.14.1/lib/ghc-9.14.1/lib/x86_64-linux-ghc-9.14.1-3203/ghc-9.14.1-c6c3
1.1G	/usr/bin
1.1G	/opt/runner-cache
1013M	/usr/local/lib/android/sdk/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/lib
980M	/home/runner
892M	/usr/local/lib/android/sdk/build-tools
886M	/usr/local/lib/android/sdk/ndk/27.3.13750724/toolchains/llvm/prebuilt/linux-x86_64/lib
871M	/usr/local/.ghcup/ghc/9.14.1/share/doc/ghc-9.14.1
871M	/usr/local/.ghcup/ghc/9.14.1/share/doc
871M	/usr/local/.ghcup/ghc/9.14.1/share
846M	/usr/local/lib/android/sdk/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin
846M	/usr/lib/google-cloud-sdk
844M	/opt/microsoft
841M	/usr/local/bin
830M	/usr/local/.ghcup/ghc/9.14.1/share/doc/ghc-9.14.1/html
826M	/usr/local/lib/android/sdk/ndk/30.0.16248370/toolchains/llvm/prebuilt/linux-x86_64/lib
823M	/etc
814M	/etc/skel
799M	/opt/hostedtoolcache/go
789M	/usr/local/.ghcup/ghc/9.14.1/share/doc/ghc-9.14.1/html/libraries
788M	/usr/share/dotnet/shared
760M	/usr/local/lib/android/sdk/ndk/30.0.16248370/toolchains/llvm/prebuilt/linux-x86_64/bin
735M	/usr/local/lib/android/sdk/ndk/27.3.13750724/toolchains/llvm/prebuilt/linux-x86_64/bin
725M	/usr/share/swift/usr/lib/swift/embedded
723M	/usr/local/lib/android/sdk/extras
675M	/usr/share/dotnet/packs
673M	/opt/microsoft/msedge
672M	/usr/local/share/chromium/chrome-linux
672M	/usr/local/share/chromium
671M	/usr/share/swift/usr/lib/swift/embedded/Swift.swiftmodule
668M	/opt/az
649M	/usr/libexec
638M	/opt/az/lib
628M	/opt/az/lib/python3.14
624M	/opt/hostedtoolcache/CodeQL/2.27.3/x64/codeql/qlpacks/codeql
624M	/opt/hostedtoolcache/CodeQL/2.27.3/x64/codeql/qlpacks
617M	/home/runner/.rustup/toolchains/stable-x86_64-unknown-linux-gnu
617M	/home/runner/.rustup/toolchains
617M	/home/runner/.rustup
617M	/etc/skel/.rustup/toolchains/stable-x86_64-unknown-linux-gnu
617M	/etc/skel/.rustup/toolchains
617M	/etc/skel/.rustup
603M	/usr/local/lib/android/sdk/ndk/27.3.13750724/toolchains/llvm/prebuilt/linux-x86_64/lib/clang/18
603M	/usr/local/lib/android/sdk/ndk/27.3.13750724/toolchains/llvm/prebuilt/linux-x86_64/lib/clang
601M	/opt/runner-cache/externals
592M	/usr/share/dotnet/shared/Microsoft.NETCore.App
591M	/usr/lib/google-cloud-sdk/lib
589M	/usr/local/lib/android/sdk/ndk/27.3.13750724/toolchains/llvm/prebuilt/linux-x86_64/lib/clang/18/lib

================================================================================
********************************************************************************
=> Heroku: Saved  775MiB
********************************************************************************
********************************************************************************
=> Mono runtime: Saved  359MiB
********************************************************************************
********************************************************************************
=> Apt: Saved  976MiB
********************************************************************************
********************************************************************************
=> Julia runtime: Saved  2.0GiB
********************************************************************************
********************************************************************************
=> Snap: Saved  4.6GiB
********************************************************************************
********************************************************************************
=> MySQL: Saved  6.5GiB
********************************************************************************
********************************************************************************
=> Rust runtime: Saved  7.7GiB
********************************************************************************
********************************************************************************
=> GCC: Saved   11GiB
********************************************************************************
********************************************************************************
=> Browsers: Saved   12GiB
********************************************************************************
********************************************************************************
=> Powershell runtime: Saved   13GiB
********************************************************************************
********************************************************************************
=> JVM runtime: Saved   14GiB
********************************************************************************
********************************************************************************
=> Swift runtime: Saved   15GiB
********************************************************************************
********************************************************************************
=> PostgreSQL: Saved   16GiB
********************************************************************************
********************************************************************************
=> LLVM: Saved   19GiB
********************************************************************************
********************************************************************************
=> Node runtime: Saved   19GiB
********************************************************************************
********************************************************************************
=> Haskell runtime: Saved   21GiB
********************************************************************************
********************************************************************************
=> Ruby runtime: Saved   24GiB
********************************************************************************
********************************************************************************
=> Az: Saved   27GiB
********************************************************************************
********************************************************************************
=> .NET runtime: Saved   38GiB
********************************************************************************
********************************************************************************
=> Python runtime: Saved   38GiB
********************************************************************************
********************************************************************************
=> Google Cloud SDK: Saved   38GiB
********************************************************************************
********************************************************************************
=> Docker images: Saved   40GiB
********************************************************************************
********************************************************************************
=> Tool cache: Saved   44GiB
********************************************************************************
********************************************************************************
=> Android library: Saved   46GiB
********************************************************************************

================================================================================
AFTER CLEAN-UP:

$ dh -ha
Filesystem      Size  Used Avail Use% Mounted on
/dev/root       145G   11G  134G   8% /
devtmpfs        7.1G     0  7.1G   0% /dev
proc               0     0     0    - /proc
sysfs              0     0     0    - /sys
securityfs         0     0     0    - /sys/kernel/security
tmpfs           7.9G     0  7.9G   0% /dev/shm
devpts             0     0     0    - /dev/pts
tmpfs           3.2G 1020K  3.2G   1% /run
cgroup2            0     0     0    - /sys/fs/cgroup
none               0     0     0    - /sys/fs/pstore
efivarfs        128M   32K  128M   1% /sys/firmware/efi/efivars
bpf                0     0     0    - /sys/fs/bpf
systemd-1          -     -     -    - /proc/sys/fs/binfmt_misc
mqueue             0     0     0    - /dev/mqueue
hugetlbfs          0     0     0    - /dev/hugepages
debugfs            0     0     0    - /sys/kernel/debug
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
none            1.0M     0  1.0M   0% /run/credentials/serial-getty@ttyS0.service
none            1.0M     0  1.0M   0% /run/credentials/getty@tty1.service

$ free -h
               total        used        free      shared  buff/cache   available
Mem:            15Gi       1.8Gi        12Gi        43Mi       1.9Gi        13Gi
Swap:          3.0Gi          0B       3.0Gi

$ du -h /* 2>/dev/null | sort -hr | head -n 100
4.6G	/usr
3.1G	/swapfile
1.6G	/usr/local
1.6G	/opt
1.1G	/usr/bin
1.1G	/opt/runner-cache
875M	/usr/lib
841M	/usr/local/bin
601M	/opt/runner-cache/externals
543M	/usr/lib/x86_64-linux-gnu
476M	/usr/share
275M	/usr/local/aws-cli/v2/2.38.5/dist
275M	/usr/local/aws-cli/v2/2.38.5
275M	/usr/local/aws-cli/v2
275M	/usr/local/aws-cli
273M	/opt/actionarchivecache
244M	/usr/local/share
244M	/usr/libexec
210M	/usr/local/share/vcpkg
209M	/opt/pipelinesagent-cache
208M	/opt/runner-cache/externals/node24
201M	/usr/local/aws-sam-cli/1.170.0/dist
201M	/usr/local/aws-sam-cli/1.170.0
201M	/usr/local/aws-sam-cli
177M	/usr/local/aws-sam-cli/1.170.0/dist/_internal
171M	/usr/src
168M	/home/runner
168M	/home
167M	/opt/runner-cache/externals/node20
164M	/home/runner/actions-runner/cached
164M	/home/runner/actions-runner
160M	/usr/local/aws-cli/v2/2.38.5/dist/awscli
151M	/usr/lib/modules/7.0.0-1017-azure
151M	/usr/lib/modules
142M	/usr/lib/modules/7.0.0-1017-azure/kernel
140M	/usr/src/linux-azure-headers-7.0.0-1017
127M	/opt/runner-cache/externals/node24_alpine/bin
127M	/opt/runner-cache/externals/node24_alpine
126M	/usr/local/share/vcpkg/.git
124M	/usr/local/share/vcpkg/.git/objects/pack
124M	/usr/local/share/vcpkg/.git/objects
122M	/opt/runner-cache/externals/node24/bin
116M	/usr/lib/modules/7.0.0-1017-azure/kernel/drivers
115M	/usr/sbin
114M	/var
113M	/usr/local/aws-cli/v2/2.38.5/dist/awscli/botocore/data
113M	/usr/local/aws-cli/v2/2.38.5/dist/awscli/botocore
101M	/opt/runner-cache/externals/node20_alpine
100M	/opt/runner-cache/externals/node20_alpine/bin
97M	/usr/libexec/docker/cli-plugins
97M	/usr/libexec/docker
95M	/opt/runner-cache/externals/node20/bin
95M	/opt/actionarchivecache/actions_cache
93M	/usr/libexec/buildah
84M	/boot
82M	/home/runner/actions-runner/cached/2.338.2/bin
82M	/home/runner/actions-runner/cached/2.338.2
82M	/home/runner/actions-runner/cached/2.338.0/bin
82M	/home/runner/actions-runner/cached/2.338.0
81M	/usr/include
75M	/var/lib
73M	/usr/share/locale
70M	/usr/share/doc
67M	/opt/runner-cache/externals/node24/include/node
67M	/opt/runner-cache/externals/node24/include
66M	/opt/runner-cache/externals/node24/include/node/openssl
64M	/opt/runner-cache/externals/node24/include/node/openssl/archs
62M	/usr/src/linux-azure-headers-7.0.0-1017/include
61M	/var/lib/dpkg
60M	/usr/local/doc/cmake
60M	/usr/local/doc
58M	/var/lib/dpkg/info
56M	/opt/actionarchivecache/actions_setup-node
55M	/usr/local/share/vcpkg/ports
54M	/opt/runner-cache/externals/node20/include/node
54M	/opt/runner-cache/externals/node20/include
53M	/opt/runner-cache/externals/node20/include/node/openssl
51M	/usr/local/doc/cmake/html
51M	/opt/runner-cache/externals/node20/include/node/openssl/archs
51M	/opt/actionarchivecache/actions_setup-python
45M	/usr/share/vim/vim91
45M	/usr/share/vim
44M	/opt/actionarchivecache/actions_upload-artifact
42M	/usr/include/c++
39M	/usr/local/aws-cli/v2/2.38.5/dist/python3.14/lib-dynload
39M	/usr/local/aws-cli/v2/2.38.5/dist/python3.14
39M	/usr/libexec/podman
38M	/usr/share/man
37M	/usr/local/aws-sam-cli/1.170.0/dist/_internal/cfnlint
36M	/usr/share/fonts/truetype
36M	/usr/share/fonts
35M	/usr/local/aws-sam-cli/1.170.0/dist/_internal/cfnlint/data
34M	/usr/src/linux-azure-headers-7.0.0-1017/arch
33M	/usr/local/aws-sam-cli/1.170.0/dist/_internal/cfnlint/data/schemas
32M	/usr/src/linux-headers-7.0.0-1017-azure
32M	/usr/lib/modules/7.0.0-1017-azure/kernel/drivers/net
29M	/usr/src/linux-azure-headers-7.0.0-1017/include/linux
27M	/usr/local/aws-sam-cli/1.170.0/dist/_internal/botocore/data
27M	/usr/local/aws-sam-cli/1.170.0/dist/_internal/botocore
26M	/usr/local/aws-cli/v2/2.38.5/dist/awscli/examples

================================================================================
********************************************************************************
=> Saved   46GiB
```
