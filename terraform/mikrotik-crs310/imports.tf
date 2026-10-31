# Created by the bootstrap in docs/mikrotik.md
import {
  to = routeros_interface_bridge.this
  id = local.bridge
}

import {
  to = routeros_interface_bridge_port.trunk
  id = "interface=${local.trunk}"
}

import {
  to = routeros_ip_address.management
  id = "address=${local.management_address}"
}

import {
  to = routeros_ip_route.default
  id = "dst-address=0.0.0.0/0"
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
