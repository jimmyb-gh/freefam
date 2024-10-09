#!/bin/sh
#
# 13.0
# See notes below.

/usr/local/bin/qemu-system-x86_64 \
  -monitor stdio \
  -cpu qemu64 \
  -vga std \
  -m 4096 \
  -smp 4   \
  -cdrom ./fbsd13_0.iso \
  -boot order=cd,menu=on \
  -blockdev driver=file,node-name=myfile,filename=./fbsd13_0.qcow2 \
  -blockdev driver=qcow2,node-name=myqcow2,file=myfile,cache-size=16777216 \
  -device virtio-blk-pci,drive=myqcow2,bootindex=1  \
  -netdev tap,id=nd0,ifname=tap0,script=no,downscript=no,br=bridge0 \
  -device virtio-net-pci,netdev=nd0,mac=52:54:6c:13:00:00 \
  -name \"fbsd13.0\"


# This is a standard install using:
#   - a cdrom line with a link to an ISO located elsewhere.
#   - blockdev/device options for defining a hard disk
#   - netdev/device options for using a tap(4) device.
# Should work with any QEMU version supporting blockdev/device options.
# Must be run under sudo(8).
# Use -runas or -runwith if you take extra precautions for security.
# There are no network setup/takedown scripts.
# Uses tap0 by default.
#
# To use:
# 1. Create a to the downloaded ISO.
#    ln -s <filepath>/FreeBSD-13.0-RELEASE-<arch>-<bootfile>.iso  fbsd13_0.iso
# 2. Create a 2G hard disk image with qemu-img(1).
#    qemu-image create -f qcow2 -o preallocation=full fbsd13_0.qcow2 2G
# 3. Run script under sudo(8).
#    sudo /bin/sh f13_0.sh
# 4. Finish installation.
