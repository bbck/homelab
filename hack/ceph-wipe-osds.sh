#!/usr/bin/env bash
#
# Wipe the Rook Ceph OSD partition (r-osd) on every node of a freshly reset
# cluster.

set -euo pipefail

context=admin@homelab
# The Ceph version Rook runs, the rook-ceph-cluster chart's default, for
# ceph-bluestore-tool
image=quay.io/ceph/ceph:v20.2.4

read -rp "This destroys the old Ceph OSDs. Type wipe to continue: " answer
[[ $answer == wipe ]] || exit 1

for node in $(kubectl --context "$context" get nodes -o jsonpath='{.items[*].metadata.name}'); do
  overrides=$(
    cat <<EOF
{
  "spec": {
    "nodeName": "$node",
    "hostNetwork": true,
    "tolerations": [{"operator": "Exists"}],
    "containers": [{
      "name": "wipe",
      "image": "$image",
      "command": ["bash", "-s"],
      "stdin": true,
      "stdinOnce": true,
      "securityContext": {"privileged": true},
      "volumeMounts": [{"name": "dev", "mountPath": "/dev"}]
    }],
    "volumes": [{"name": "dev", "hostPath": {"path": "/dev"}}]
  }
}
EOF
  )

  # The first pull of the Ceph image takes a while on the RK1s
  kubectl --context "$context" -n kube-system run "ceph-wipe-$node" --image="$image" \
    --restart=Never --rm -i --quiet --pod-running-timeout=15m \
    --overrides="$overrides" <<'EOF' | sed "s/^/$node: /"
set -euo pipefail

if [[ ! -e /dev/disk/by-partlabel/r-osd ]]; then
  echo "no r-osd partition"
  exit 0
fi
dev=$(readlink -f /dev/disk/by-partlabel/r-osd)
size=$(blockdev --getsize64 "$dev")

blkdiscard --force "$dev" || echo "discard failed, zeroing the labels only"
# A discard isn't guaranteed to read back as zeros, so zero the label and its
# copies as well
for gib in 0 1 10 100 1000; do
  if (((gib << 30) + (1 << 20) <= size)); then
    dd if=/dev/zero of="$dev" bs=1M count=1 seek=$((gib << 10)) oflag=direct status=none
  fi
done

if ceph-bluestore-tool show-label --dev "$dev" >/dev/null 2>&1; then
  echo "a BlueStore label is still readable"
  exit 1
fi
echo "wiped $dev"
EOF
done
