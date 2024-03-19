# Ubuntu rootless Singularity container

This is an Ubuntu 22.04 Singularity container made free of root requirement for using `apt`.

[Singularity](https://docs.sylabs.io/guides/3.5/user-guide/introduction.html) is a way to run containers in unpriviledged environments, where `setuid`, `seccomp` and `namespaces` are not available for security reasons. Despite that an unpriviledged container could nicely serve the most of the daily needs such as CI or code development, some distro utilities require the root priviledges for historical reasons. For Ubuntu the most impotant utility is APT package manager. Although it normally requires admin privilege, this requirement is not mandatory by design and can be lifted. The purpose of this repository is to provide modifications that allow to run APT without admin priviliges in the Singularity container.

The modification consists of two parts:

1. Replacement `sudo` executable, which allows any command to ignore `chown()` errors
2. Replacement `dpkg` executable, which is modified to ignore `chown()` errors (the `sudo` alone above does not help, because `dpkg` ignores `LD_PRELOAD`)


## Building

This repository provides the Singularity .def spec to build an Ubuntu 22.04 container with APT utility modified to run without root priviledges:

```
singularity build -f ubuntu_rootless.sif ubuntu_rootless.def
```

The resulting `ubuntu_rootless.sif` can be used to create a persistent rootfs (sandbox):

```
singularity build --sandbox ./ubuntu_rootless ./ubuntu_rootless.sif
```


# Usage

Lauch interactive session:

```
singularity exec --writable ./ubuntu_rootless fish
sudo apt install g++
```

OR launch container in the background and connect to it through SSH server (dropbear):

```
singularity instance start --writable ./ubuntu_rootless ubuntu_rootless
```

Stop the container:

```
singularity instance stop ubuntu_rootless
```


## TODO

1. Include modern version of Singularity CE compiled from source without suid
2. Include static version of `proot`, in order to build containers without fakeroot

