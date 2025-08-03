#!/bin/ash
# semi-noob POSIX mount script for firefox chroot
set -eu

# ─── CONFIGURATION ────────────────────────────────────────────────────────────
CHROOT=alpine-firefox
RUN_UID=1000
TMP_HOST=/tmp/firefox-tmp
TMP_CHROOT=$CHROOT/tmp
DEV_CHROOT=$CHROOT/dev
PROC_CHROOT=$CHROOT/proc
SYS_CHROOT=$CHROOT/sys
RUN_HOST=/run/user/$RUN_UID
RUN_CHROOT=$CHROOT/run

# ─── MOUNT SEQUENCE ───────────────────────────────────────────────────────────
# 1. Ensure base dir exists
[ -d "$CHROOT" ] || {
  mkdir -p $CHROOT
}

# 2. Bind-mount the chroot onto itself to make it a private namespace
mount --bind "$CHROOT" "$CHROOT"

# 3. Make a minimal /dev inside
mount -t tmpfs tmpfs "$DEV_CHROOT"
chmod 755 "$DEV_CHROOT"
mknod -m 666 "$DEV_CHROOT/null"  c 1 3
mknod -m 666 "$DEV_CHROOT/zero"  c 1 5
mknod -m 444 "$DEV_CHROOT/random"  c 1 8
mknod -m 444 "$DEV_CHROOT/urandom" c 1 9

# 4. Mount proc and sys inside
mount -t proc proc "$PROC_CHROOT"
mount -t sysfs sysfs "$SYS_CHROOT"

# 5. Bind-mount /run/user/$RUN_UID into chroot (ro)
mount --bind "$RUN_HOST" "$RUN_CHROOT"
mount -o remount,nosuid,noexec,ro "$RUN_CHROOT"

# 6. Make /tmp/browser-tmp on host and bind it in (rw)
mkdir -p "$TMP_HOST"
mount --bind "$TMP_HOST" "$TMP_CHROOT"
mount -o remount,rw,nosuid,noexec "$TMP_CHROOT"

# 7. Re-mount the chroot rootfs read-only
mount -o remount,ro "$CHROOT"

# 8. Bind home directories to make it writable while nerfing root and execution
mount --bind $CHROOT/home $CHROOT/home
mount -o remount,rw,discard,nosuid,noexec $CHROOT/home
mount --bind $CHROOT/home/madoka $(awk -F: '$3==1000 { print $6 "/firefox"; exit }' /etc/passwd) # And put the chroot home in the equivalent host user home for easy access

echo "Mounted chroot at $CHROOT"
