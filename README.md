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
1. Begin the installation.  If there are errors in interfaces, or configuration options, edit the temlate and re-run.
1. Finish the installation.

## Template
A typical template for later FreeBSD versions is shown below.
This version does not use floppy disks for booting and has only one hard disk.
Early versions require two hard disks and one or two floppy disks for installation.
As a convention, the last three octets of the MAC address enumerate the FreeBSD verion number.
````
/usr/local/bin/qemu-system-x86_64  -monitor stdio \
  -cpu qemu64 \
  -vga std \
  -m 4096 \
  -smp 4 \
  -drive file=./ISO/fbsd09_0.iso,index=2,media=cdrom \
  -boot order=cda,menu=on \
  -blockdev driver=file,node-name=myfile,filename=./fbsd14_0.qcow2 \
  -blockdev driver=qcow2,node-name=myqcow2,file=myfile,cache-size=16777216 \
  -device virtio-blk-pci,drive=myqcow2,bootindex=1  \
  -netdev tap,id=nd0,ifname=tap0,script=no,downscript=no,br=bridge0 \
  -device virtio-net-pci,netdev=nd0,mac=52:54:6c:14:01:00 \
  -name \"fbsd14.0\"
````
There are many other details noted in each installation file.

## Layout
The simplest layout is ordering the directories for each version as two digit major and minor numbers.
Example:
````
09.00/
-rw-r--r--   1 user group       1376 Oct  2 09:10 f.sh
-rw-r--r--   1 user group 2148073472 Oct  8 20:14 fbsd09_0.qcow2
````
There are some versions that require additional numbering.
In this script, and the other scripts in this repo, the ```tap(4)``` is always **tap0**.
Change as desired to run multiple versions of FreeBSD simultaneously.

## mkbr.sh script
Below is a sample run of the **mkbr.sh** script.
This run creates one bridge, two taps and adds the host interface (em0) to the bridge.
See the script for additional details.
````
$ sudo  /bin/sh  mkbr.sh reset bridge0 tap0 tap1 em0
````


