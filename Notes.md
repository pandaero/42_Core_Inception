## Creating the VM that will create the Containers
### Alpine vs. Debian
- Debian
- - Much more widely used
- - Heavier
- - Longer cycles mean older software versions
- Alpine
- - Focus on light weight and security
### Docker images
[Debian](https://hub.docker.com/_/debian)
[Alpine](https://hub.docker.com/_/alpine)
Penultimate Stable (25.03.2023)
Debian: Bullseye 11.6 latest -> Buster 10.13 penultimate
Alpine: 3.17 latest -> 3.16 penultimate
### Alpine Image
```Dockerfile
FROM scratch
ADD alpine-minirootfs-3.16.4-x86_64.tar.gz /
CMD ["/bin/sh"]
```
This gives us a starting point for a Docker image, however, we are using Debian or Alpine from a Virtual machine, and need the .iso to run in a VM software such as VirtualBox.
[Alpine Releases](https://www.alpinelinux.org/releases/)
I will be using `alpine-standard-3.16.4-x86_64.iso`.
### VirtualBox
We can configure a virtual machine for VirtualBox from the command line with VBoxManage. This is useful for scripting the creation of a virtual machine. Indeed the script `Virtual_Machine.sh` performs this task.
#### Script
The script will do the following:
- Download the image of the OS (requires wget)
- Create and register the VM in VirtualBox (requires VirtualBox)
The script will check for the image to be correctly downloaded. It includes a VM-starting section, however the VM is going to be set-up using the VirtualBox GUI.
#### Set-up
Very importantly, the network interface must be set-up ([documentation](https://wiki.alpinelinux.org/wiki/Configure_Networking)), to do this we edit the `/etc/network/interfaces` and add the ethernet adapter:
```
auto eth0
iface eth0 inet dhcp
```
Then apply the changes by running:
```
/etc/init.d/networking restart
```
The package manager APK must be configured to install docker and other packages from it. We edit `/etc/apk/repositories` and add:
```
http://dl-cdn.alpinelinux.org/alpine/v3.16/main
http://dl-cdn.alpinelinux.org/alpine/v3.16/community
```
Now we can install packages and run the VM normally.
### Running Containers
The packages `docker` and `docker-compose` are required for this. `make` is required to use the Makefile.
