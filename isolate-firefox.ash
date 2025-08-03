#!/bin/ash
# isolated-firefox: Runs inside the unshare()’d namespaces

set -eu

CHROOT=alpine-firefox
USER=madoka

# 1. Bring up loopback so firefox works
ip addr add 127.0.0.100/8 dev lo
ip link set lo up

# 2. Exec into the chroot as madoka and launch Firefox on Wayland-1 and remember, UID 1000's XDG_RUNTIME_DIR
# has been mounted in /run in the chroot
exec chroot "$CHROOT" /bin/su - "$USER" -c \
  'export WAYLAND_DISPLAY=wayland-1 XDG_RUNTIME_DIR=/run; exec firefox'

