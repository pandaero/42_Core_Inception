#!/bin/bash
# Script to create an Alpine 3.16 Virtual Machine on macOS using VirtualBox

NAME="Alpine_3.16"
DIR=Alpine_VM
IMAGE=alpine-standard-3.16.4-x86_64.iso
HASH=$IMAGE.sha256
IMAGELINK=https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/$IMAGE
HASHLINK=$IMAGELINK.sha256
VIRTUALBOXDIR=/Users/pandalaf/Library/VirtualBox/$DIR
HDISK=${NAME}_disk.vdi

# Clean the VM directory
if [ "$1" == "clean" ]; then
	rm -rf $DIR
fi

# Clear the VM VirtualBox directory and from VirtualBox
if [ "$1" == "clear" ]; then
	if [ -f "$DIR/$HDISK" ]; then
		rm -f $DIR/$HDISK
	fi
	if [ -f "$DIR/$NAME.ova" ]; then
		rm -f $DIR/$NAME.ova
	fi
	if [[ $(VBoxManage list vms | grep $NAME) ]]; then
		rm -rf $VIRTUALBOXDIR
		VBoxManage unregistervm $NAME
	fi
fi

# Create the VM
if [ "$1" == "create" ]; then
	if [ ! -d "$DIR" ]; then
		mkdir $DIR
	fi
	# Download OS image hash to determine whether to download again
	wget $HASHLINK
	mv $HASH $DIR
	cd $DIR
	# Download OS image if current incorrect and move to directory
	if [ -f "$IMAGE" ]; then
		shasum -a 256 $IMAGE > checksum
		if [ diff checksum $HASH ]; then
			rm -f $IMAGE
			wget $IMAGELINK
		fi
	else
		wget $IMAGELINK
		shasum -a 256 $IMAGE > checksum
		if [ $(diff checksum $HASH) ]; then
			echo "Error: image hash does not match."
			exit 1
		fi
	fi
	rm -f $HASH
	rm -f checksum
	cd ..
	# Create VM entry
	VBoxManage createvm --name $NAME --ostype Linux_64 --register --basefolder $DIR
	# Set VM properties (memory and network)
	VBoxManage modifyvm $NAME --memory 1024 --vram 128
	VBoxManage modifyvm $NAME --nic1 nat
	VBoxManage modifyvm $NAME --graphicscontroller vmsvga
	# Set VM resources (disk and OS-image)
	VBoxManage createmedium disk --filename $DIR/$HDISK --size 4096 --format VDI 
	VBoxManage storagectl $NAME --name "SATA Controller" --add sata
	VBoxManage storageattach $NAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $DIR/$HDISK
	VBoxManage storagectl $NAME --name "IDE Controller" --add ide --controller PIIX4
	VBoxManage storageattach $NAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium $DIR/$IMAGE
	VBoxManage modifyvm $NAME --boot1 dvd --boot2 disk --boot3 none --boot4 none
	# Export the VM as OVA for import
	VBoxManage export $NAME --output $DIR/$NAME.ova --ovf10
	# Delete VM from machine
	VBoxManage unregistervm $NAME --delete
	# Re-import machine
	VBoxManage import $DIR/$NAME.ova --vsys 0 --vmname $NAME --unit 12 --disk $DIR/$HDISK
	# Re-attach OS image to disk controller
	VBoxManage storageattach $NAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium $DIR/$IMAGE
	echo "Remember to change the snapshots folder of the VM"
fi

# Unregister VM and delete from machine
if [ "$1" == "unregister" ]; then
	VBoxManage unregistervm $NAME --delete
fi

# Export VM (keep in mind new snapshots)
if [ "$1" == "export" ]; then
	if [ -f "$DIR/$NAME.ova" ]; then
		rm -f $DIR/$NAME.ova
	fi
	VBoxManage export $NAME --output $DIR/$NAME.ova --ovf10
fi

# Import VM
if [ "$1" == "import" ]; then
	VBoxManage import $DIR/$NAME.ova --vsys 0 --vmname $NAME --unit 12 --disk $DIR/$HDISK
fi

# Start VM
if [ "$1" == "start" ]; then
	VBoxManage startvm $NAME --type gui
fi
