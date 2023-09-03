#!/usr/bin/env bash
set -eu

tmpdir=`mktemp -d /tmp/XXXXXXX`

qemu-img create $tmpdir/my-image.img 10G

qemu-system-x86_64 \
  -enable-kvm -m 256 \
  -cdrom ./result/iso/nixos-*-x86_64-linux.iso \
  -drive if=none,id=stick,format=raw,file=$tmpdir/my-image.img \
  -device nec-usb-xhci,id=xhci  \
  -device usb-storage,bus=xhci.0,drive=stick

rm -rf $tmpdir
