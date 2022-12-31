#!/bin/bash

# renovate: datasource=github-releases depName=kube-vip/kube-vip
export KVVERSION=v0.5.7
export VIP=192.168.1.1 # 192.168.1.0/29
export INTERFACE=eth0

export DOCKER="colima nerdctl --"
export KUBE_VIP="$DOCKER run --network host --rm ghcr.io/kube-vip/kube-vip:$KVVERSION"

$KUBE_VIP manifest daemonset \
  --interface $INTERFACE \
  --address $VIP \
  --inCluster \
  --taint \
  --controlplane \
  --services \
  --arp \
  --leaderElection \
  | tee kube-vip.yaml
