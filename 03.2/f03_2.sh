#!/bin/sh
#
# f03_2.sh
#
#/usr/local/bin/qemu-system-x86_64  -monitor stdio \
#  -cpu qemu64 \
#  -vga std \
#  -m 4096 \
#  -smp 4 \
#  -drive file=./fbsd03_0.iso,index=2,media=cdrom \
#  -boot order=cda,menu=on \
#  -blockdev driver=file,filename=./fbsd03_0.qcow2,node-name=myfile \
#  -blockdev driver=qcow2,file=myfile,node-name=myqcow2,cache-size=16777216 \
#  -device virtio-blk-pci,drive=myqcow2,bootindex=1  \
#  -netdev tap,id=nd0,ifname=tap0,script=no,downscript=no,br=bridge0 \
#  -device virtio-net-pci,netdev=nd0,mac=56:00:00:03:00:00 \
#  -name \"fbsd03.0\"
#



/usr/local/bin/qemu-system-i386  -monitor stdio \
  -cpu qemu32 \
  -machine pc \
  -vga std \
  -m 1024 \
  -drive file=./fbsd03_2.iso,index=1,id=cdrom0,media=cdrom \
  -boot order=cd,menu=on \
  -drive file=./fbsd03_2.img,if=ide,index=0,media=disk,cache=writeback,format=raw \
  -netdev tap,id=nd0,ifname=tap0,script=no,downscript=no,br=bridge0 \
  -device ne2k_pci,netdev=nd0,mac=52:54:6c:65:03:02 \
  -name \"fbsd03.2\"











# -runas user \           <--- for QEMU version up through 9.0
# -run-with user=name \   <--- for QEMU version 9.1 and up

# NOTE:  This is NOT a standard install.
# See the Notex.txt file.
# An updated command line is used above.
#
#   - a cdrom line using a link to an ISO located elsewhere.
#   - blockdev/device options for defining a hard disk
#   - netdev/device options for using a tap(4) device.
# Should work with any QEMU version supporting blockdev/device options.
# Must be run under sudo(8).
# Use -runas or -run-with if you take extra precautions for security.
# There are no network setup/takedown scripts.
# Uses tap0 by default. Must be set up beforehand.  See mkbr.sh for use.
#
# To use:
# 1. Create a link to the downloaded ISO using the fbsdnn_n.iso parameter above.
#    ln -s <filepath>/FreeBSD-03.0-RELEASE-<arch>-<bootfile>.iso  fbsd03_0.iso
# 2. Create a 2G hard disk image with qemu-img(1).
#    qemu-image create -f qcow2 -o preallocation=full fbsd03_0.qcow2 2G
# 3. Ensure the tap and bridge devices are set up.
#    sudo /bin/sh mkbr.sh reset bridge0 tap0 em0  # em0 or other host interface
# 4. Run script under sudo(8).
#    sudo /bin/sh f03_0.sh
# 5. Finish installation.  If the tap and bridge connections are set up
#    correctly, and routing is correct on the host, the guest VM will be
#    able to use the Internet immediately.
#
# https://github.com/jimmyb-gh/freefam
