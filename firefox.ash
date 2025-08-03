#!/bin/ash
# frontend to isolate+run Firefox in new namespaces + usernet
set -eu

# 1. Spawn new namespaces and fork into the isolate-firefox script
unshare \
  --mount \
  --uts   \
  --ipc   \
  --net   \
  --pid --fork \
  --    /bin/ash "/bin/ash isolate-firefox.ash" &
# New mount namespace, UTS/hostname, IPC, Networking, and a new PID fork that makes it's child PID=1.

# 2. Remember the PID of the unshared child (which will run Firefox)
UNSHARE_PID=$!

# 3. Give it a moment to come up, then hook up user‐mode networking
#    tap0 is an arbitrary name in the host; slirp4netns will create it
sleep 0.2
slirp4netns "$UNSHARE_PID" tap0 --configure --mtu=65520 >/dev/null 2>&1 &

SLIRP_PID=$!
echo "Spawned Firefox PID=$UNSHARE_PID, slirp4netns PID=$SLIRP_PID"

# 4. Wait for Firefox to quit before killing slirp with it.
wait "$UNSHARE_PID"
echo "Firefox (PID $UNSHARE_PID) has exited; killing slirp4netns (PID $SLIRP_PID)"
kill "$SLIRP_PID" 2>/dev/null || true

echo "Goo By"
