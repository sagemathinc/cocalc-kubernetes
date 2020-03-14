#!/bin/bash

set -ev

echo "Ensure exported path exists"
mkdir -p /projects/home

echo "Starting NFS in the background..."
/usr/sbin/rpc.nfsd --debug 8 --no-udp --no-nfs-version 2 --no-nfs-version 3

echo "Exporting File System..."
/usr/sbin/exportfs -rv

echo "Starting Mountd..."
/usr/sbin/rpc.mountd --debug all --no-nfs-version 2 --no-nfs-version 3

