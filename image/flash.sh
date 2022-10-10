#!/bin/bash

set -e

DISK="/dev/disk4"

sudo -v
read -r -p "HOSTNAME: " HOST
read -r -s -p "TAILSCALE AUTH KEY: " AUTH_KEY
export HOST
echo

echo "flashing onto $DISK"
for _ in {1..10}; do
  echo -n "."
  sleep 1
done
echo

diskutil unmountDisk $DISK
sleep 2
sudo dd if="$1" of=${DISK//\/dev\///dev/r} bs=1m status=progress

echo "re-mounting disk..."
sleep 2
diskutil mountDisk $DISK

echo "copying files..."
# We do not want variable expansion in the SHELL-FORMAT argument
# shellcheck disable=SC2016
envsubst '${HOST}' < "$(dirname "${0}")/user-data" > /Volumes/system-boot/user-data
echo "$HOST" > /Volumes/system-boot/hostname
echo "$AUTH_KEY" > /Volumes/system-boot/tailscale-authkey

echo "unmounting disk..."
sync
sleep 2
diskutil unmountDisk $DISK
