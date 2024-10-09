# freefam
FreeBSD Family QEMU Notes for All Versions

This repo contains notes and procedures for installing all versions of FreeBSD, from 1.0 up through the latest FreeBSD version, on QEMU.
FreeBSD versions from @@@3.0 and later can use the latest QEMU (9.1.x) to perform installs.
FreeBSD versions for 3.0 and earlier must use the following QEMU versions to perform installs:
* 3.x : use QEMU 0.11.1 to build installation.  Transfer to 9.1.x to run.
* 2.x : use QEMU 0.11.1 to build installation.  Transfer to 9.1.x to run
* 1.x : use QEMU 0.11.1 to prep hard disks (2 required).  Transfer to 9.1.x to complete installation and run.
Details for each version are in the specfic install file.

# General Notes

FreeBSD does not support QEMU acceleration, so none of these installs use the ```-accel``` option.

The general procedure for a typical installation is as follows:
1. Create a new directory for work and change to it.
1. Create the hard disk image with ```qemu-img(1)```.
   Middle and later versions of FreeBSD can use the 'qcow2' image format.
   Early versions must use 'raw' format.
1. Edit the QEMU installation template as required.  See below for a sample template.
1. Ensure that the ```bridge(4)``` and ```tap(4)``` interfaces are up.  See the ```mkbr.sh``` script to set these up.
1. Run the template as a script under ```sudo(8)```.
1. Example:
````
 sudo /bin/sh f.sh
````

7. Begin the installation.  If there are errors in interfaces, or configuration options, edit the temlate and re-run.
8. Finish the installation.

## Template
A typical template for later FreeBSD versions is shown below.
This version does not use floppy disks for booting and has only one hard disk.
Early versions require two hard disks and one or two floppy disks for installation.

As a convention, the last three octets of the MAC address enumerate the FreeBSD verion number.
The first three octets are available for any use but *should* be aligned with "Locally Administered Addresses" similar to:
````
x2-xx-xx-nn-nn-nn
x6-xx-xx-nn-nn-nn
xA-xx-xx-nn-nn-nn
xE-xx-xx-nn-nn-nn
````
where 'x' can be any hexadecimal digit and 'n' designates the FreeBSD version.
This convention will allow all the FreeBSD versions to be run on the same network, even at the same time, without conflicts.
See https://serverfault.com/questions/40712/what-range-of-mac-addresses-can-i-safely-use-for-my-virtual-machines for notes on using "Locally Administered Addresses."

````
#!/bin/sh
#
# f14.0.sh
#
/usr/local/bin/qemu-system-x86_64  -monitor stdio \
  -cpu qemu64 \
  -vga std \
  -m 4096 \
  -smp 4 \
  -drive file=./fbsd14_0.iso,index=2,media=cdrom \
  -boot order=cda,menu=on \
  -blockdev driver=file,node-name=myfile,filename=./fbsd14_0.qcow2 \
  -blockdev driver=qcow2,node-name=myqcow2,file=myfile,cache-size=16777216 \
  -device virtio-blk-pci,drive=myqcow2,bootindex=1  \
  -netdev tap,id=nd0,ifname=tap0,script=no,downscript=no,br=bridge0 \
  -device virtio-net-pci,netdev=nd0,mac=56:00:00:14:00:00 \
  -name \"fbsd14.0\"
````
There are many other details noted in each installation file.

## Directory and File Layout
The simplest layout is ordering the directories for each version as two digit major and minor numbers.
A separate directory containing the downloaded ISOs is also required.
````
...
14.00/
    -rw-r--r--   1 user group        973 Oct  1 19:50 f14_0.sh
    lrwxr-xr-x   1 user group         45 Oct  9 15:16 fbsd14_0.iso -> ../ISO/FreeBSD-14.0-RELEASE-amd64-dvd1.iso
    -rw-r--r--   1 user group 2148073472 Oct  8 20:14 fbsd14_0.qcow2
ISO/
    -rw-r--r--  1 jpb jpb  661202944 Oct  8 21:30 FreeBSD-01.0-RELEASE-i386-disc1.iso
    -rw-r--r--  1 jpb jpb  427421696 Oct  2 17:12 FreeBSD-02.0-RELEASE-i386-disc1.iso
    ...
    -rw-r--r--  1 jpb jpb 4541104128 Oct  1 17:05 FreeBSD-14.0-RELEASE-amd64-dvd1.iso
````
There are some versions that require additional minor and sub-minor numbering.
In this script, and the other scripts in this repo, the ```tap(4)``` is always **tap0**.
Change as desired to run multiple versions of FreeBSD simultaneously.

## mkbr.sh script
Below is a sample run of the **mkbr.sh** script.
This run creates one bridge with two taps and adds the host interface (em0) to the bridge.
See the script for additional details.
````
$ sudo  /bin/sh  mkbr.sh reset bridge0 tap0 tap1 em0
````
## Understanding QEMU blockdev/device Constructions
The ```qemu(1)``` section titled **Block device options** describes the use of blockdev and device options.


**ChatGPT** explained it this way:

I understand how the terms "blockdev", "device", and their parameters (like "driver", "file", and "node-name") in QEMU can be confusing.
Let me break down the meanings and usage of these terms, particularly in the context of using a qcow2 block device.
### Overview of Key Concepts in QEMU

1. **blockdev**:
   * The blockdev command (or the -blockdev QEMU option) describes *block devices* at a lower level, typically defining how data is accessed or how storage is structured.
   It's used in modern QEMU setups.
   * Block devices refer to things like virtual hard drives (e.g., qcow2 images) and provide an abstraction for file or disk access.
   * **"blockdev"** is more flexible and modular, separating the storage medium from the actual device that uses it.
1. **device**:
   * The device command (or the -device QEMU option) adds a hardware device (like a virtual hard drive or network card) to the virtual machine.
   * Devices usually refer to something that QEMU presents to the guest operating system.
     For example, it could be an IDE or SCSI disk, where the backing storage is defined via a block device.
   * The device is usually something that gets attached to the virtual machine and uses a block device for its backing storage.

#### Key Parameters

* **driver**:
   * Specifies the driver that QEMU uses to handle the block device or device.
     For block devices, the driver might be qcow2, raw, file, or host_device.
     For virtual hardware devices, it could be virtio-blk, ide-hd, or scsi-hd.
   * Example: If you're using a qcow2 image, you would set the driver to qcow2 in a -blockdev option.
* **file**:
   * Specifies the file or backing storage for the block device.
     For example, if you're using a qcow2 image file, this is where you specify the path to the file.
   * This is often defined in conjunction with a file driver (e.g., file or qcow2).
* **node-name**:
   * A unique name given to a block node (a block device layer in QEMU).
     The node-name identifies the block device in the QEMU graph of devices and can be referenced by other QEMU commands.
   * **Important**: In the blockdev command, the node-name uniquely identifies this block device in QEMU's internal block layer.
     Later on, when you define a device (e.g., a virtio-blk or ide-hd), you reference this node-name to tell QEMU what block device to associate with the virtual device.
     
### Putting It All Together for a qcow2 Block Device

Let’s walk through how to define a block device using a qcow2 image and attach it to a virtual machine using the -blockdev and -device options in QEMU.

**Example: Defining a qcow2 Block Device and Attaching It to a Virtual Machine**

1. **Define the underlying file** that stores the qcow2 image:
````
-blockdev driver=file,filename=/path/to/disk.qcow2,node-name=myfile
````
   * driver=file: Tells QEMU that the underlying storage is a file.
   * filename=/path/to/disk.qcow2: The path to the qcow2 image.
   * node-name=myfile: Assigns the node name myfile to this file.

2. **Define the qcow2 block device** on top of the file:
````
-blockdev driver=qcow2,file=myfile,node-name=myqcow2
````
   * driver=qcow2: Specifies that the block device uses the qcow2 format.
   * file=myfile: Points to the file node (myfile) created in step 1.
   * node-name=myqcow2: Assigns the node name myqcow2 to this qcow2 block device.

3. **Attach the block device to a virtual machine device**, like a virtio-blk or ide-hd disk:
````
-device virtio-blk,drive=myqcow2
````
   * virtio-blk: Specifies that the virtual machine will use a virtio-blk device to interface with the block storage.
   * drive=myqcow2: References the block device with the node-name myqcow2, which is the qcow2 block device defined in step 2.

#### Full Example Command:
(Capitalization added for emphasis.)
````
qemu-system-x86_64 \
    -blockdev driver=file,filename=/path/to/disk.qcow2,node-name=MYFILE \
    -blockdev driver=qcow2,file=MYFILE,node-name=MYQCOW2 \
    -device virtio-blk,drive=MYQCOW2
````
**Breakdown**:
* First, the file /path/to/disk.qcow2 is specified as the storage medium with the node-name=myfile.
* Then, a block device in qcow2 format is created on top of that file with the node-name=myqcow2.
* Finally, a virtio-blk device is created, and it uses the block device myqcow2.

### Summary of Parameters:
* **-blockdev**: Describes block devices in a flexible way.
* **driver**: Specifies how QEMU should interpret the block device (e.g., qcow2, raw, file).
* **file**: Points to the actual storage backing the block device (e.g., a qcow2 image).
* **node-name**: Uniquely identifies the block device for internal reference.
* **-device**: Attaches a virtual hardware device to the virtual machine, referencing the block device by its node-name.

I hope this clears up the relationship between blockdev, device, and the parameters like driver, file, and node-name!
Let me know if you need further clarification.




