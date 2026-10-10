---
# yaml-language-server: $schema=https://raw.githubusercontent.com/siderolabs/talos/v1.14.2/website/content/v1.14/schemas/config.schema.json
apiVersion: v1alpha1
kind: LinkConfig
name: {{ .Node.Data.link }}
addresses:
  - address: {{ .Node.IP }}/24
routes:
  - gateway: {{ .Data.gateway }}
---
apiVersion: v1alpha1
kind: ResolverConfig
nameservers:
{{- range .Data.nameservers }}
  - address: {{ . }}
{{- end }}
