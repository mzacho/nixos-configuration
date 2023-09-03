set -eu

prefix=/mnt/persist/etc

# copy wifi password
mkdir -vp $prefix
cp -vr /etc/NetworkManager/system-connections $prefix/NetworkManager

# and machine id
cp -vr /etc/machine-id $prefix/
