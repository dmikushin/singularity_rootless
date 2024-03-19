# CentOS 7 rootless Singularity container

This is an CentOS 7 Singularity container made free of root requirement for using `yum`.

[Singularity](https://docs.sylabs.io/guides/3.5/user-guide/introduction.html) is a way to run containers in unpriviledged environments, where `setuid`, `seccomp` and `namespaces` are not available for security reasons. Despite that an unpriviledged container could nicely serve the most of the daily needs such as CI or code development, some distro utilities require the root priviledges for historical reasons. For CentOS 7 the most impotant utility is YUM package manager. Although it normally requires admin privilege, this requirement is not mandatory by design and can be lifted. The purpose of this repository is to provide modifications that allow to run YUM without admin priviliges in the Singularity container.

The modification consists of two parts:

1. Replacement `sudo` executable, which allows any command to ignore `chown()` errors
2. Modified `yum` executable, which ignores the root priviledged checking


## Building

This repository provides the Singularity .def spec to build an CentOS 7 container with YUM utility modified to run without root priviledges:

```
singularity build -f centos7_rootless.sif centos7_rootless.def
```

The resulting `centos7_rootless.sif` can be used to create a persistent rootfs (sandbox):

```
singularity build --sandbox ./centos7_rootless ./centos7_rootless.sif
```


# Usage

Lauch interactive session:

```
singularity exec --writable ./centos7_rootless fish
sudo apt install g++
```

OR launch container in the background and connect to it through SSH server (dropbear):

```
singularity instance start --writable ./centos7_rootless centos7_rootless
```

Stop the container:

```
singularity instance stop centos7_rootless
```


## TODO

1. Include modern version of Singularity CE compiled from source without suid
2. Include static version of `proot`, in order to build containers without fakeroot
3. Modify `dropbear` and `/etc/shells` to acknowledge the `SIGNULARITY_SHELL` setting
4. Build the most recent version of fish from source

