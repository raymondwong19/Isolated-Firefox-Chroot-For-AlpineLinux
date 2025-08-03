# Isolated-Firefox-Chroot-For-AlpineLinux
A bragging attempt because I wish to join the Linux community.

However, I am too noob. So I release some scripts for busybox's /bin/ash that is somewhat in a POSIX compatible format and is KISS compatible. It is tested on Alpine Linux and fetches a ARM64 Alpine stable chroot from proot-distro, installs firefox on it, and then runs firefox with unshare to create isolated namespaces with it's own network and processes, therefore cutting off Firefox from the host.

And of course, do whatever you want with it, I just wish to join the Linux community. I wish.
