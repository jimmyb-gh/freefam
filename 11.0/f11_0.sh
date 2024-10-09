#!/bin/sh
#
# f11.0.sh
#
/usr/local/bin/qemu-system-x86_64  -monitor stdio \
  -cpu qemu64 \
  -vga std \
  -m 4096 \
  -smp 4 \
  -drive file=./fbsd11_0.iso,index=2,media=cdrom \
  -boot order=cda,menu=on \
  -blockdev driver=file,filename=./fbsd11_0.qcow2,node-name=myfile \
  -blockdev driver=qcow2,file=myfile,node-name=myqcow2,cache-size=16777216 \
  -device virtio-blk-pci,drive=myqcow2,bootindex=1  \
  -netdev tap,id=nd0,ifname=tap0,script=no,downscript=no,br=bridge0 \
  -device virtio-net-pci,netdev=nd0,mac=56:00:00:11:00:00 \
  -name \"fbsd11.0\"

# -runas user \           <--- for QEMU version up through 9.0
# -run-with user=name \   <--- for QEMU version 9.1 and up

# This is a standard install using:
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
#    ln -s <filepath>/FreeBSD-11.0-RELEASE-<arch>-<bootfile>.iso  fbsd11_0.iso
# 2. Create a 2G hard disk image with qemu-img(1).
#    qemu-image create -f qcow2 -o preallocation=full fbsd11_0.qcow2 2G
# 3. Ensure the tap and bridge devices are set up.
#    sudo /bin/sh mkbr.sh reset bridge0 tap0 em0  # em0 or other host interface
# 4. Run script under sudo(8).
#    sudo /bin/sh f11_0.sh
# 5. Finish installation.  If the tap and bridge connections are set up
#    correctly, and routing is correct on the host, the guest VM will be
#    able to use the Internet immediately.
#
# https://github.com/jimmyb-gh/freefam
