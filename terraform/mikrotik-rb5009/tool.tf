resource "routeros_tool_bandwidth_server" "this" {
  enabled = false
}

resource "routeros_tool_mac_server" "this" {
  allowed_interface_list = "none"
}

resource "routeros_tool_mac_server_ping" "this" {
  enabled = false
}

# The way back in if the management IP breaks
resource "routeros_tool_mac_server_winbox" "this" {
  allowed_interface_list = routeros_interface_list.this["management"].name
}
