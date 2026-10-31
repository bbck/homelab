locals {
  networks = {
    trusted = {
      ssid                 = "Blips and Chitz"
      vlan                 = 10
      item                 = "wifi-blips-and-chitz"
      authentication_types = ["wpa3-psk"]
      client_isolation     = false
      bridge_horizon       = null
    }
    untrusted = {
      ssid                 = "Jerryboree"
      vlan                 = 20
      item                 = "wifi-jerryboree"
      authentication_types = ["wpa2-psk", "wpa3-psk"]
      client_isolation     = true
      bridge_horizon       = 1
    }
  }

  radios = toset(["wifi1", "wifi2"])
}

resource "routeros_wifi_cap" "this" {
  enabled = false
}

# client_isolation is per radio, so the horizon blocks 2.4 <-> 5 GHz traffic
resource "routeros_wifi_datapath" "this" {
  for_each = local.networks

  name             = each.key
  bridge           = routeros_interface_bridge.this.name
  vlan_id          = each.value.vlan
  client_isolation = each.value.client_isolation
  bridge_horizon   = each.value.bridge_horizon
}

resource "routeros_wifi_security" "this" {
  for_each = local.networks

  name                 = each.key
  authentication_types = each.value.authentication_types
  passphrase           = data.onepassword_item.wifi[each.key].password
  disable_pmkid        = true
  wps                  = "disable"
}

resource "routeros_wifi_configuration" "this" {
  for_each = local.networks

  name    = each.key
  ssid    = each.value.ssid
  country = "United States"
  mode    = "ap"

  datapath = {
    config = routeros_wifi_datapath.this[each.key].name
  }
  security = {
    config = routeros_wifi_security.this[each.key].name
  }
}

resource "routeros_wifi_channel" "wifi1" {
  name      = "5ghz"
  band      = "5ghz-ax"
  frequency = ["5745"]
  width     = "20/40/80mhz"
}

resource "routeros_wifi" "trusted" {
  for_each = local.radios

  name     = each.key
  disabled = false

  configuration = {
    config = routeros_wifi_configuration.this["trusted"].name
  }
  channel = (
    each.key == "wifi1" ? { config = routeros_wifi_channel.wifi1.name } : null
  )
}

resource "routeros_wifi" "untrusted" {
  for_each = local.radios

  name             = "${each.key}-untrusted"
  master_interface = routeros_wifi.trusted[each.key].name
  disabled         = false

  configuration = {
    config = routeros_wifi_configuration.this["untrusted"].name
  }
}
