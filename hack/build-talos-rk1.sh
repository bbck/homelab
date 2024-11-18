#!/bin/bash
set -exo pipefail

TALOS_VERSION="v1.8.3"
TALOS_EXTENSIONS="tailscale iscsi-tools util-linux-tools"

WORK_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
cleanup() { rm -rf "$WORK_DIR"/_out; }
trap cleanup EXIT

_get_extension_images() {
  crane export "ghcr.io/siderolabs/extensions:${TALOS_VERSION}" | tar x -O image-digests | grep -E "$(echo $TALOS_EXTENSIONS | tr ' ' '|')"
}

build_image() {
  docker run --rm -t -v "${WORK_DIR}/_out:/out" -v /dev:/dev --privileged "ghcr.io/nberlee/imager:${TALOS_VERSION}" \
    installer \
    --arch arm64 \
    --overlay-name turingrk1 \
    --overlay-image ghcr.io/nberlee/sbc-turingrk1:$TALOS_VERSION \
    --base-installer-image ghcr.io/nberlee/installer:$TALOS_VERSION-rk3588 \
    --system-extension-image ghcr.io/nberlee/rk3588:$TALOS_VERSION \
    $(_get_extension_images | sed 's/^/--system-extension-image /' | tr '\n' ' ')
}

upload_image() {
  # https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic
  # gh auth token | crane auth login ghcr.io -u bbck --password-stdin
  crane push "${WORK_DIR}/_out/installer-arm64.tar" "ghcr.io/bbck/talos-rk1:${TALOS_VERSION}"
  crane tag "ghcr.io/bbck/talos-rk1:${TALOS_VERSION}" "latest"
}

main() {
  build_image
  upload_image
}

main
