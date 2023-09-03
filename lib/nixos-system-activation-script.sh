set -eu
shopt -s dotglob

# This script is run on system activation, i.e after `nixos-rebuild
# switch` or when rebooting after `nixos-rebuild boot`.
#
# The conditional represents these two cases.

if [ -L /etc/nixos ]; then
  # file is symbolic - we are not booting, but probably just ran
  # `nixos-rebuild switch`. No need to link anything!
  echo not symlinking /persist
elif [ -z "`ls -A /etc/nixos`" ]; then
  # Remove (the empty) /etc/nixos directory when encountering an
  # empty root, and replace it with my config
  rmdir -v /etc/nixos
  echo symlinking /persist

  prefix=/persist/etc

  ln -vsf $prefix/nixos /etc/
  ln -vs $prefix/NetworkManager/system-connections \
      /etc/NetworkManager/
  ln -vsf $prefix/machine-id /etc/machine-id

  function keep_dirs() {
    prefix=$1
    # NOTE: Whitespace in directory names is not allowed
    for dir in `cat $prefix/KEEP_LIST`; do
      target=$prefix/$dir
      mkdir -vp $target
      chown -v martin $target
      mkdir -vp /home/martin/`dirname $dir`
      chown -v martin /home/martin/`dirname $dir`
      ln -vs $target /home/martin/$dir
    done
  }
  echo CHECK2
  keep_dirs /persist/home/dirs

  echo CHECK3
  prefix=/persist/home/files/
  # create directories
  find $prefix -type f,l | grep -oP "^$prefix\K.*" | \
    xargs -n 1 dirname | \
    xargs -I{} mkdir -vp /home/martin/{}

  # change owner
  find $prefix -type f,l | grep -oP "^$prefix\K.*" | \
    xargs -n 1 dirname | \
    xargs -I{} chown -v martin /home/martin/{}

  echo CHECK4
  # symlink files and symlinks
  find $prefix -type f,l | grep -oP "^$prefix\K.*" | \
     xargs -I{} ln -vs $prefix{} /home/martin/{}

else
  echo /etc/nixos not a symlink and not empty
  echo have you just formatted?
  echo doing nothing...
fi
