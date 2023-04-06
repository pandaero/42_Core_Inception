I will be doing this project from a 42 School iMac (on macOS).

## Creating the VM that will create the Containers
### Alpine vs. Debian
Before deciding which OS to use, let's compare their characteristics:
- Debian
- - Much more widely used
- - Heavier
- - Longer cycles mean older software versions
- Alpine
- - Focus on light weight and security

I decided to use Alpine as it is new for me and is lightweight, which should speed things up. It also seems to include newer software packages, and stability will not be an issue for this project.

#### Penultimate Stable Versions (25.03.2023)
The versions that are meant to be used for this project are the penultimate stable ones available:
- [Debian Releases](https://www.debian.org/releases/): "Bullseye" 11.x latest -> Buster 10.13 penultimate
- [Alpine Releases](https://www.alpinelinux.org/releases/): 3.17 latest -> 3.16 penultimate
For Alpine, this means the Alpine 3.16 version.

### Virtual Machine Set-Up
I created a [bash script](https://github.com/pandaero/42_Core_inception/blob/master/virtual_machine.sh) to reliably set-up the virtual machine on VirtualBox (macOS) from scratch, and perform the clearing of it for "hard resets".

The script will do the following:
- Download the image of the OS (requires wget)
- Create and register the VM in VirtualBox (requires VirtualBox)
The script will check for the image to be correctly downloaded. It includes a VM-starting section, however the VM is going to be set-up using the VirtualBox GUI as well.

#### Operating System Set-Up
Very importantly, the network interface must be set-up ([documentation](https://wiki.alpinelinux.org/wiki/Configure_Networking)), to do this we edit the `/etc/network/interfaces` and add the ethernet adapter with the following lines:
```
auto eth0
iface eth0 inet dhcp
```
Then apply the changes by running:
```
/etc/init.d/networking restart
```
The package manager APK must be configured before being able to install packages. We are interested in the `make`, `docker`, `docker-compose`, and potentially other packages. We edit `/etc/apk/repositories` and add:
```
http://dl-cdn.alpinelinux.org/alpine/v3.16/main
http://dl-cdn.alpinelinux.org/alpine/v3.16/community
```
Now we can install packages and run the VM normally.

## Creating the Containers
The packages `docker` and `docker-compose` are required for this. `make` is required to use the Makefile.

### Docker images
There are docker images with the operating systems ready, these are:
[Debian Images](https://hub.docker.com/_/debian)
[Alpine Images](https://hub.docker.com/_/alpine)

#### Alpine Docker Image
The dockerfile to set-up a container running the vanilla Alpine 3.16 operating system looks like this (good to know, but we will set up our containers `FROM Alpine 3.16` instead of `FROM scratch`):
```Dockerfile
FROM scratch
ADD alpine-minirootfs-3.16.4-x86_64.tar.gz /
CMD ["/bin/sh"]
```
