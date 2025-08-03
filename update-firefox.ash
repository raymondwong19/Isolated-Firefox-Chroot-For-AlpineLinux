#!/bin/ash
set -eu

CHROOT=alpine-firefox
CHROOT_URL=https://github.com/termux/proot-distro/releases/download/v4.25.0/alpine-aarch64-pd-v4.25.0.tar.xz
CHROOT_SUBDIR=alpine-aarch64

# 1. Nuke any existing chroot dir
if [ -d "$CHROOT" ]; then
  echo "=> Found existing $CHROOT — deleting"
  ./unmount-chroot.ash 2>/dev/null || true
  rm -rf "$CHROOT"
fi

# 2. Download and populate
echo "=> Creating fresh $CHROOT"
mkdir -p "$CHROOT"

echo "=> Downloading while Extracting rootfs"
wget -qO- "$CHROOT_URL" \
  | xzcat \
  | tar -xf -C "$CHROOT"

# Move out of alpine-aarch64 subdir if present
if [ -d "$CHROOT/$CHROOT_SUBDIR" ]; then
  mv "$CHROOT/$CHROOT_SUBDIR"/* "$CHROOT"/
  rmdir "$CHROOT/$CHROOT_SUBDIR"
fi

# 3. Download firefox, zenhei, and ublock
mount --bind /dev $CHROOT/dev
mount --bind /sys $CHROOT/sys
mount --bind /proc $CHROOT/proc
chroot $CHROOT /sbin/apk update
chroot $CHROOT /sbin/apk upgrade
chroot $CHROOT /sbin/apk add firefox ublock-origin font-wqy-zenhei
chroot $CHROOT /usr/sbin/adduser -u 1000 -D -s /bin/sh madoka
chroot $CHROOT /bin/rm -rf /var/cache/apk /sbin/apk
./update-browser-blocker.ash
umount $CHROOT/proc
umount $CHROOT/sys
umount $CHROOT/dev
./mount-chroot.sh
echo "Update complete"
