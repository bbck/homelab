# Cilium on each Kubernetes node peers with the router to advertise
# LoadBalancer IPs and pod CIDRs
resource "routeros_routing_bgp_instance" "this" {
  name      = "bgp-instance-1"
  as        = "65530"
  router_id = "192.168.88.2"
}

# The connection to the nodes is added by hand after the first apply: provider
# v1.99.1 always sends add-path-out, which RouterOS 7.22+ rejects. Replace this
# with a routeros_routing_bgp_connection once that's fixed:
# https://github.com/terraform-routeros/terraform-provider-routeros/issues/959
#
#   /routing/bgp/connection add name=k8s instance=bgp-instance-1 as=65530 routing-table=main multihop=no local.address=192.168.40.2 local.role=ebgp remote.address=192.168.40.40/29 remote.as=65535
