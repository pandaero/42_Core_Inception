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
- [Debian Releases](https://www.debian.org/releases/): "Bullseye" 11.x latest -> "Buster" 10.13 penultimate
- [Alpine Releases](https://www.alpinelinux.org/releases/): 3.17 latest -> 3.16 penultimate
For Alpine, this means the Alpine 3.16 version.

### Virtual Machine Set-Up
I created a [bash script](https://github.com/pandaero/42_Core_inception/blob/master/virtual_machine.sh) to reliably set-up the virtual machine on VirtualBox (macOS) from scratch, and perform the clearing of it for "hard resets".

The script will do the following:
- Download the image of the OS (requires wget)
- Create and register the VM in VirtualBox (requires VirtualBox)
The script will check for the image to be correctly downloaded. It includes a VM-starting section, however the VM is going to be set-up using the VirtualBox GUI as well.

I began to run the VM from a USB and VirtualBox on different machines, so the set-up includes a step that exports the machine to a universal format, and a parameter that imports the virtual machine to a new virtualbox session. (`unregister` and `import`)

#### Script Usage
`bash virtual_machine.sh create` - will create the new machine and prompt the snapshot folder to be changed to match the VM disk folder.
`bash virtual_machine.sh export` - will save the machine to an importable file.
`bash virtual_machine.sh clear` - will delete the VM from the VirtualBox register and its files.
`bash virtual_machine.sh import` - will import the exported (or created) VM from the file.
The VM's snapshots will not be exported into the importable file!

#### Operating System Set-Up
It is a good idea to save snapshots of the machine at key stages of the set-up. The first would be after successfully booting up for the first time.

##### `setup-alpine` Command
This command will provide a guided set-up for system elements (used values in brackets):
- input (us - us keyboard)
- hostname (localhost) - default {press `Enter`}
- network (default) - default
- root user password (take note, uppercase + lowercase + digit)
- timezone (UTC) - default
- network proxy (none) - default
- NTP client (chrony) - default
- system download mirrors (f)
- Additional user (loginname / password)
- ssh server (openssh) - default
- machine disk (sda) - virtual machine hard disk for system installation
- disk partitioning (lvmsys)
After running the command and creating the partitions, we will reboot the machine (`reboot` command). Note that the first time we booted from the OS image. Now we will want to boot from the machine hard disk. A great point for a second snapshot is after this boot.

##### Network Interfaces
Very importantly, the network interface must be set-up ([Alpine Wiki](https://wiki.alpinelinux.org/wiki/Configure_Networking)), this should have been done by the `setup-alpine` command, but to do this manually we would edit the `/etc/network/interfaces` and add the ethernet adapter with the following lines:
```
auto eth0
iface eth0 inet dhcp
```
Then apply the changes by running:
```
/etc/init.d/networking restart
```

##### Package Manager
The package manager APK must be configured before being able to install packages. Again, `setup-alpine` should have configured this, though not the specific version mirrors. We are interested in the `nano`, `make`, `docker`, `docker-compose`, and potentially other packages. We can edit `/etc/apk/repositories` (the repository lists) and add the following:
```
http://dl-cdn.alpinelinux.org/alpine/v3.16/main
http://dl-cdn.alpinelinux.org/alpine/v3.16/community
```
Now we can install packages and run the VM normally.

##### Display Manager
At some point in the project, we will verify that our containers are running well by opening the website that they serve. For this we will need a GUI and access to a browser. Therefore, we will install a display manager. Through a light search, I decided on using XFCE with Lightdm for its light weight. I followed the following steps:
- Run the `setup-xorg-base` command, it will download packages to prepare an Xorg-server based GUI.
- To run XFCE4/Lightdm minimally, these packages need to be installed: `xfce4` `xfce4-terminal` `xfce4-screensaver` `lightdm-gtk-greeter` `dbus`
- The service `dbus` has to be running, launched with: `rc-service dbus start`
- The service can be set to run on start-up with `rc-update add dbus` (apparently `rc` could be deprecated and superseded by `openrc`)
- Another service `mdev` may be required to be added to the sysinit runlevel: `rc-update add mdev sysinit`
- To enable the display manager, the following command can be run: `rc-update add lightdm`
- To run the display manager: `rc-service lightdm start`

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

### Docker Configuration
We will run docker from the machine's user, not root, so we might require `sudo` to run certain commands. Also we need to add the user to the `docker` group, by running: `addgroup <user> docker`.

#### Docker daemon
Docker runs through a service or daemon, which will have to be running when the `docker` command is used. To start it normally (one-time), we use:
- `sudo rc-service docker start`
So that it starts when turning on the computer/machine:
- `rc-update add docker boot`

#### Useful Docker commands
- `docker images`: list built docker images.
- `docker run <image>`: run container from image

### [NGinX Container](https://github.com/pandaero/42_Core_inception/master/src/requirements/nginx)
- The [Docker Documentation](https://docs.docker.com/engine/reference/builder/) comes in handy for this process.
- This container will run an NGINX server with a configuration file we will prepare.
- Starting from the `alpine:3.16` docker image, we will need to install NGINX in the container. The command `apk update && apk upgrade && apk add --no-cache nginx` will install the most recent version of NGINX available. The `--no-cache` option removes the cache from the installation process, freeing up space on the container.
- The requirements of the project ask for the NGINX communicating with TLS 1.2 and 1.3 only, this means it only communicates through HTTPS. The container requires the standard HTTPS port to be opened, so we can `EXPOSE 443`. Additionally this means for the NGINX config the following line: `ssl_protocols TLSv1.2 TLSv1.3`.
- The configuration file for NGINX that we will prepare must also be read inside the container, we can copy our file into the container using `COPY conf/nginx.conf /etc/nginx/nginx.conf`. NGINX loads the default configuration from this location unless another is specified using `-c`.
- To run the NGINX server, we can pass a `CMD ["nginx", "-g", "daemon off;"]` that will run every time the container starts. (see the [differences between RUN, CMD, and ENTRYPOINT](https://www.tutorialspoint.com/run-vs-cmd-vs-entrypoint-in-docker)) (see also this [stackoverflow answer](https://stackoverflow.com/questions/25970711/what-is-the-difference-between-nginx-daemon-on-off-option) to describe the `-g daemon off;` parameter)

#### [Server Configuration](https://github.com/pandaero/42_Core_inception/master/src/requirements/nginx/nginx.conf)
According to the project requirements, the NGINX server will be hosting a WordPress + PHP website (running on another container). It is connected to this container using port 9000. Also, it will read from a volume containing the website. It will listen from (and communicate with) the internet on port 443 (securely).
- Why would we connect the WordPress container to the NGINX? This set-up is called 'reverse proxy', and it means the NGINX server handles all incoming requests and outgoing responses, while the WordPress container only needs to handle internal communication with the NGINX container.
