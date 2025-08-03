#!/bin/ash
# semi-noob POSIX unmount script for firefox chroot
set -eu

CHROOT=alpine-firefox
RUN_UID=1000
TMP_HOST=/tmp/firefox-tmp
TMP_CHROOT=$CHROOT/tmp
DEV_CHROOT=$CHROOT/dev
PROC_CHROOT=$CHROOT/proc
SYS_CHROOT=$CHROOT/sys
RUN_CHROOT=$CHROOT/run

# Unmount in reverse order and ignore failures if already gone

umount $(awk -F: '$3==1000 { print $6 "/firefox"; exit }' /etc/passwd) 2>/dev/null	|| true
umount /home 2>/dev/null          || true

umount "$TMP_CHROOT"               2>/dev/null || true
umount "$RUN_CHROOT"               2>/dev/null || true

umount "$SYS_CHROOT"               2>/dev/null || true
umount "$PROC_CHROOT"              2>/dev/null || true
umount "$DEV_CHROOT"               2>/dev/null || true

umount "$CHROOT"                   2>/dev/null || true

echo "Unmounted chroot at $CHROOT"
