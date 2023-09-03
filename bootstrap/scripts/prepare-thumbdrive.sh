#!/usr/bin/env bash

set -eu

DEV=$1

echo wiping disk
sudo sfdisk --wipe always --wipe-partitions always --delete $DEV

echo installing iso
ISO=`echo ./result/iso/nixos-*-x86_64-linux.iso`
sudo dd bs=1M conv=fsync oflag=direct status=progress if=$ISO of=$DEV
