#!/bin/bash
#
# This is a Singularity container control script.
#
# The container is shipped in $CONTAINER_BASE folder shared between all users.
# The container is owned by root and is read-only for everyone else.
# But we use OverlayFS so that every user could diverge his very own container
# variant from the base container. Each user merges his own modifications on top of
# the base container, making a read-write environment out of the read-only base.
#
# Container comes with local SSH access via Dropbear, which may be bridged
# to the server's main SSH connection via ProxyJump. This method allows to
# login directly to the container via SSH, and connect remotely from VS Code.

CONTAINER_NAME=rockylinux8_rootless
CONTAINER_BASE=/opt/$CONTAINER_NAME
OVERLAY_USER=$HOME/rockylinux8_overlay

# Create OverlayFS.
mkdir -p $OVERLAY_USER/{lower,upper,work,merged}

# Mount OverlayFS, if not already mounted.
# Note we set UID and GID so that all files belong to the current user,
# which is not fully consistent, because some files may be required to belong
# to root or nobody. However, this is a way to provide read-write access
# within the overlay to the originally read-only base system.
# In future we may wish to customize the fuse-overlayfs behavior to take
# ownership of read-only file in case of legitimate write operation demand.
if ! mountpoint -q "$OVERLAY_USER/merged"; then
    fuse-overlayfs -o squash_to_uid=$(id -u) -o squash_to_gid=$(id -g) -o lowerdir=$CONTAINER_BASE,upperdir=$OVERLAY_USER/upper,workdir=$OVERLAY_USER/work $OVERLAY_USER/merged
fi

# Create a host key required by Dropbear, if not already existing
if [ ! -f $HOME/.ssh/dropbear_ed25519_host_key ]; then
    $CONTAINER_BASE/usr/local/bin/dropbearkey -t ed25519 -f $HOME/.ssh/dropbear_ed25519_host_key
fi

# Start Singularity instance, if not already started.
if ! singularity instance list | grep -q $CONTAINER_NAME; then
    # Check which ports starting with 22221 are already occupied by existing
    # processes, and use the next free port.
    PORT=22221
    while ss -tulwn | grep -q ":$PORT "; do
        PORT=$((PORT + 1))
    done
    echo "Free port: $PORT"

    while ss -tulwn | grep -q ":$PORT "; do
        PORT=$((PORT + 1))
    done
    singularity instance start --writable --bind $HOME/.ssh/dropbear_ed25519_host_key:/etc/dropbear/dropbear_ed25519_host_key $OVERLAY_USER/merged $CONTAINER_NAME $PORT
    echo "Now login to $CONTAINER_NAME container via SSH: ssh localhost -p $PORT -i <key_file>"
else
    echo "$CONTAINER_NAME Singularity container is already started"
fi

# Stop Singularity instance, of not already stopped.
if singularity instance list | grep -q $CONTAINER_NAME; then
    singularity instance stop $CONTAINER_NAME
else
    echo "$CONTAINER_NAME Singularity container is not running"
fi
