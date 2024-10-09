# freefam
FreeBSD Family QEMU Notes for All Versions

This repo contains notes and procedures for installing all versions of FreeBSD, from 1.0 up through the latest FreeBSD version, on QEMU.
FreeBSD versions from @@@3.0 and later use the latest QEMU (9.1.x) to perform installs.
FreeBSD versions for 3.0 and earlier use the following QEMU versions to perform installs:
* 3.x : use QEMU 0.11.1 to build installation.  Transfer to 9.1.x to run.
* 2.x : use QEMU 0.11.1 to build installation.  Transfer to 9.1.x to run
* 1.x : use QEMU 0.11.1 to prep hard disks (2 required).  Transfer to 9.1.x to complete installation and run.
Details for each version are in the specfic install file.

# General Notes

FreeBSD does not support QEMU accelleration, so none of these installs use the ```-accell``` option

