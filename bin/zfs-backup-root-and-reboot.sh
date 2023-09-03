#!/usr/bin/env bash

set -e

# swap old root and root datasets
zfs rename rpool/local/root rpool/local/tmp
zfs rename rpool/local/old-root rpool/local/root
zfs rename rpool/local/tmp rpool/local/old-root

reboot
