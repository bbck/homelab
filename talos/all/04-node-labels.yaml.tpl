---
# yaml-language-server: $schema=https://raw.githubusercontent.com/siderolabs/talos/v1.14.2/website/content/v1.14/schemas/config.schema.json
{{- with get .Node.Data "zone" }}
apiVersion: v1alpha1
kind: KubeNodeConfig
labels:
  topology.kubernetes.io/zone: {{ . }}
{{- end }}
