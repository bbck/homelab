#!/bin/bash

set -e

DISK="/dev/disk2"

sudo -v
read -p "HOSTNAME: " HOST
read -s -p "TAILSCALE AUTH KEY: " AUTH_KEY
echo

diskutil unmountDisk $DISK

echo "flashing onto $DISK"
for i in $(seq 10); do
  echo -n "."
  sleep 1
done
echo
sudo dd if=$1 of=${DISK//\/dev\///dev/r} bs=1m status=progress

echo "re-mounting disk..."
sleep 2
diskutil mountDisk $DISK

echo "copying files..."
envsubst '${HOST}' < "$(basename "${0}")/user-data" > /Volumes/system-boot/user-data
echo $AUTH_KEY > /Volumes/system-boot/tailscale-authkey

echo "unmounting disk..."
sync
sleep 2
diskutil unmountDisk $DISK
