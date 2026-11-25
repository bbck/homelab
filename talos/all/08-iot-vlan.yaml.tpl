---
# yaml-language-server: $schema=https://raw.githubusercontent.com/siderolabs/talos/v1.14.6/website/content/v1.14/schemas/config.schema.json
{{- with get .Node.Data "iotVlan" }}
apiVersion: v1alpha1
kind: VLANConfig
name: {{ $.Node.Data.link }}.{{ . }}
vlanID: {{ . }}
parent: {{ $.Node.Data.link }}
---
apiVersion: v1alpha1
kind: SysctlConfig
params:
  net/ipv6/conf/{{ $.Node.Data.link }}.{{ . }}/disable_ipv6: "1"
{{- end }}
