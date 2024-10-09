#!/bin/sh
#
# 13.0
#
# -device and -blockev from qemu(1)
#
#  The most explicit way to describe disks is to use a combination of
#  -device to specify the hardware device and -blockdev to describe the
#  backend. The device defines what the guest sees and the backend
#  describes how QEMU handles the data. It is the only guaranteed stable
#  interface for describing block devices and as such is recommended for
#  management tools and scripting.
#


/usr/local/bin/qemu-system-x86_64  -monitor stdio \
  -cpu qemu64 \
  -vga std \
  -m 4096 \
  -smp 4   \
  -cdrom ../../ISO/fbsd13_0.iso \
  -boot order=cd,menu=on \
  -blockdev driver=file,node-name=myfile,filename=./fbsd13_0.qcow2 \
  -blockdev driver=qcow2,node-name=myqcow2,file=myfile,cache-size=16777216 \
  -device virtio-blk-pci,drive=myqcow2,bootindex=1  \
  -netdev tap,id=nd0,ifname=tap0,script=no,downscript=no,br=bridge0 \
  -device virtio-net-pci,netdev=nd0,mac=52:54:6c:65:13:00 \
  -name \"fbsd13.0\"


