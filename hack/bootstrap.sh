#!/usr/bin/env bash
#
# Install the minimum a fresh cluster needs before Flux can take over:
#
#   prometheus-operator-crds  the ServiceMonitor CRD the charts below use
#   cilium                    pod networking, nodes stay NotReady without it
#   coredns                   cluster DNS, so Flux can resolve GitHub
#   flux-operator             installs and upgrades Flux
#   flux-instance             Flux itself, syncing k8s/flux from GitHub
#
# Each chart, version and set of values is read from the app's own
# OCIRepository and HelmRelease, so nothing here needs updating when they
# change. Flux adopts the Helm releases on its first reconcile. Safe to re-run.
#
# Usage: hack/bootstrap.sh

set -euo pipefail

root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
context=admin@homelab

die() {
  echo "$1" >&2
  exit 1
}

# Install or upgrade the HelmRelease in k8s/apps/<namespace>/<app>/<dir>
install() {
  local dir=$root/k8s/apps/$1 ns=${1%%/*}
  local hr=$dir/helmrelease.yaml oci=$dir/ocirepository.yaml
  local name url tag values

  name=$(yq '.spec.releaseName // .metadata.name' "$hr")
  url=$(yq '.spec.url' "$oci")
  tag=$(yq '.spec.ref.tag' "$oci")
  [[ $tag != null ]] || die "$1: the OCIRepository has no ref.tag"

  # Flux fills these in from the cluster, which helm can't do
  [[ $(yq '.spec | has("valuesFrom")' "$hr") == false ]] ||
    die "$1: valuesFrom isn't supported"
  values=$(yq '.spec.values // {} | explode(.)' "$hr")
  [[ $values != *'${'* ]] || die "$1: the values use Flux substitutions"

  echo "Installing $name $tag into $ns"
  helm upgrade "$name" "$url" --install --version "$tag" \
    --kube-context "$context" --namespace "$ns" --create-namespace \
    --values - --wait --timeout 10m <<<"$values"
}

echo "Bootstrapping $context"
install monitoring/prometheus-operator-crds/app
install kube-system/cilium/app
install kube-system/coredns/app
install flux-system/flux-operator/app
install flux-system/flux-operator/instance
