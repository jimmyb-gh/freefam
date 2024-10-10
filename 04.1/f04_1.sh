#!/bin/sh
#
# f04_1.sh
#

/usr/local/bin/qemu-system-i386  -monitor stdio \
  -cpu qemu32 \
  -machine pc \
  -vga std \
  -m 1024 \
  -drive file=./fbsd04_1.iso,index=2,media=cdrom \
  -boot order=cd,menu=on \
  -drive file=./fbsd04_1.qcow2,if=ide,index=0,media=disk,cache=writeback,format=qcow2 \
  -netdev tap,id=nd0,ifname=tap0,script=no,downscript=no,br=bridge0 \
  -device ne2k_pci,netdev=nd0,mac=52:54:6c:65:04:01 \
  -name \"fbsd04.1\"


# -runas user \           <--- for QEMU version up through 9.0
# -run-with user=name \   <--- for QEMU version 9.1 and up

# NOTE:  NOT a standard install.
#        See the file Notes.txt for required modifications to the 
#        standard template.
# ----------------------------------------------------------------
#
#   Does boot from CDROM.
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
#    ln -s <filepath>/FreeBSD-04.0-RELEASE-<arch>-<bootfile>.iso  fbsd04_0.iso
# 2. Create a 2G hard disk image with qemu-img(1).
#    qemu-image create -f qcow2 -o preallocation=full fbsd04_0.qcow2 2G
# 3. Ensure the tap and bridge devices are set up.
#    sudo /bin/sh mkbr.sh reset bridge0 tap0 em0  # em0 or other host interface
# 4. Run script under sudo(8).
#    sudo /bin/sh f04_0.sh
# 5. Finish installation.  If the tap and bridge connections are set up
#    correctly, and routing is correct on the host, the guest VM will be
#    able to use the Internet immediately.
#
# https://github.com/jimmyb-gh/freefam
