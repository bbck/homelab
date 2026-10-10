---
# yaml-language-server: $schema=https://raw.githubusercontent.com/siderolabs/talos/v1.14.2/website/content/v1.14/schemas/config.schema.json
# The installer image is injected by topf from talosVersion and the node's schematic.
# Only runs when booted from an ISO, and only if no disk already has a Talos
# META partition.
apiVersion: v1alpha1
kind: UnattendedInstallConfig
provisioning:
  diskSelector:
    match: disk.dev_path == "{{ .Node.Data.installDisk }}"
  wipe: true
