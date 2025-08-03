#!/bin/ash
# update-browser-blocker.ash
# Overwrite DNS + /etc/hosts inside the $CHROOT to block “useless” domains.

set -eu

# The default chroot location is just cwd/alpine-firefox
CHROOT=alpine-firefox

# Check if the chroot dir is actually present
[ -d "$CHROOT" ] || {
  echo "ERROR: chroot not found at $CHROOT" >&2
  exit 1
}

# 1. Remove the default DNS and set it to Quad9's safe DNS
rm -f "$CHROOT/etc/resolv.conf"
echo "nameserver 9.9.9.9" | tee $CHROOT/etc/resolv.conf

# 2. Build a /etc/hosts and block useless sites
echo "=> Blocking useless sites with /etc/hosts"
cat > "$CHROOT/etc/hosts" << 'EOF'
# A hosts file for the firefox chroot
# Redirect localhost to 127.0.0.100 inside the new net namespace
127.0.0.100   localhost

# ——————————————————
# Block some useless or anti-privacy domains:
127.0.0.100   google.com
127.0.0.100   www.google.com
127.0.0.100   google-analytics.com
127.0.0.100   www.google-analytics.com
127.0.0.100   youtube.com
127.0.0.100   www.youtube.com
127.0.0.100   facebook.com
127.0.0.100   www.facebook.com
127.0.0.100   instagram.com
127.0.0.100   www.instagram.com
127.0.0.100   twitter.com
127.0.0.100   www.twitter.com
127.0.0.100   doubleclick.net

# Block some Communist Chinese terrorist or surveillance-heavy sites:
127.0.0.100   tencent.com
127.0.0.100   www.tencent.com
127.0.0.100   baidu.com
127.0.0.100   www.baidu.com
127.0.0.100   weibo.com
127.0.0.100   www.weibo.com
127.0.0.100   taobao.com
127.0.0.100   www.taobao.com
127.0.0.100   alipay.com
127.0.0.100   www.alipay.com

# End of hosts
EOF

echo "=> Hosts file updated in $CHROOT/etc/hosts"

