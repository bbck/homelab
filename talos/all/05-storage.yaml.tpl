---
# yaml-language-server: $schema=https://raw.githubusercontent.com/siderolabs/talos/v1.14.2/website/content/v1.14/schemas/config.schema.json
# Only honored when the volumes are first provisioned: the data disk must not
# already have an EPHEMERAL partition filling it.
{{- with get .Node.Data "dataDisk" }}
apiVersion: v1alpha1
kind: VolumeConfig
name: EPHEMERAL
provisioning:
  diskSelector:
    match: disk.dev_path == "{{ . }}"
  maxSize: 200GiB
---
# Unformatted partition for a Rook Ceph OSD at /dev/disk/by-partlabel/r-osd.
# The name must not contain "ceph", or Ceph refuses to use the partition.
apiVersion: v1alpha1
kind: RawVolumeConfig
name: osd
provisioning:
  diskSelector:
    match: disk.dev_path == "{{ . }}"
  minSize: 500GiB
{{- end }}
