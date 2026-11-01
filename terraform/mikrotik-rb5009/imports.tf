# Created by the bootstrap in docs/mikrotik.md
import {
  to = routeros_interface_bridge.this
  id = local.bridge
}

import {
  to = routeros_interface_bridge_port.breakglass
  id = "interface=${local.breakglass}"
}

import {
  to = routeros_ip_address.this["management"]
  id = "address=${local.networks.management.address}"
}

import {
  to = routeros_system_user_group.this["terraform"]
  id = "terraform"
}

import {
  to = routeros_system_user.this["terraform"]
  id = "group=terraform"
}

# Exist after every reset
import {
  to = routeros_system_user.this["admin"]
  id = "admin"
}
