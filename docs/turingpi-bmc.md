# Turing Pi BMC

By default the BMC bridges all six ports of the board's switch (`node1`-`node4`, `ge0` and `ge1`) into
`br0`, so connecting both front ports to the same network creates a loop. Splitting them into two bridges
gives each pair of nodes its own uplink:

| Bridge | Nodes | Uplink |
| - | - | - |
| `br0` | `node1`, `node2` | `ge0` |
| `br1` | `node3`, `node4` | `ge1` |

It has to be two bridges. The BMC's
[switch driver](https://github.com/turing-machines/BMC-Firmware/blob/master/tp2bmc/patches/linux/realtek-switch.patch)
isolates each bridge in hardware, but doesn't offload VLAN filtering or STP.

## Steps

1. Leave `ge1` unplugged.
2. SSH to the BMC as `root` and replace `/etc/network/interfaces` with the file below. The edit is saved to
   the BMC's persistent overlay.
3. Reboot the BMC. Check that `bridge link` shows `node1`, `node2` and `ge0` with `master br0`, and
   `node3`, `node4` and `ge1` with `master br1`.
4. Plug in `ge1`.

```
auto lo
iface lo inet loopback

# Nodes 1-2, uplinked through ge0. The BMC keeps its address here.
auto br0
iface br0 inet dhcp
  bridge-ports node1 node2 ge0
  pre-up /etc/network/nfs_check
  wait-delay 15
  hostname $(hostname)

# Nodes 3-4, uplinked through ge1. Each bridge gets its own isolation mask and
# FDB in the switch chip, so ge0 and ge1 never forward to each other.
# No address, and no IPv6, so the BMC MAC (shared by every port) is never
# sourced from ge1 and the upstream switch only ever learns it through ge0.
auto br1
iface br1 inet manual
  bridge-ports node3 node4 ge1
  pre-up sysctl -qw net.ipv6.conf.ge1.disable_ipv6=1
  pre-up sysctl -qw net.ipv6.conf.br1.disable_ipv6=1
```
