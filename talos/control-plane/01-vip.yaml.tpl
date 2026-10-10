---
# yaml-language-server: $schema=https://raw.githubusercontent.com/siderolabs/talos/v1.14.2/website/content/v1.14/schemas/config.schema.json
apiVersion: v1alpha1
kind: Layer2VIPConfig
name: {{ .Data.vip }}
link: {{ .Node.Data.link }}
