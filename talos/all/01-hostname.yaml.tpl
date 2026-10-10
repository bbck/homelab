---
# yaml-language-server: $schema=https://raw.githubusercontent.com/siderolabs/talos/v1.14.2/website/content/v1.14/schemas/config.schema.json
apiVersion: v1alpha1
kind: HostnameConfig
auto: "off"
hostname: {{ .Node.Host }}
