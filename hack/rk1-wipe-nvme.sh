#!/usr/bin/env bash
#
# Wipe the partition tables on a Turing RK1's NVMe from u-boot, through the
# Turing Pi BMC, so nothing old on the drive can be booted or picked up by
# Talos. Only the BMC is needed: no OS has to boot on the node.
#
# Power-cycles the node, stops autoboot on its serial console, zeroes the first
# and last MiB of the NVMe (protective MBR, primary and backup GPT), checks that
# sectors 0-1 read back as zeros, then powers the node off.
#
# Usage: hack/rk1-wipe-nvme.sh <node 1-4>
#
# tpi comes from mise. Point it at the BMC with TPI_HOSTNAME, TPI_USERNAME and
# TPI_PASSWORD.

set -euo pipefail

if [[ $# -ne 1 || ! $1 =~ ^[1-4]$ ]]; then
  echo "usage: $(basename "$0") <node 1-4>" >&2
  exit 1
fi

node=$1
buf=0x02000000   # u-boot's kernel_addr_r, free memory to build the zeros in
check=0x03000000 # where sectors 0-1 are read back to

die() {
  echo "node $node: $1" >&2
  tpi power off -n "$node" >/dev/null
  exit 1
}

console() {
  tpi uart -n "$node" get | tr -d '\r'
}

# Run a u-boot command and print its output. The command is followed by an
# echo of a unique marker, which shows where its output ends in the console.
uboot() {
  local marker="done-$RANDOM$RANDOM"
  tpi uart -n "$node" set -c "$1; echo $marker" >/dev/null
  for _ in $(seq 30); do
    sleep 1
    if console | grep -x "$marker" >/dev/null; then
      console | awk -v cmd="$1; echo $marker" -v end="$marker" \
        'index($0, cmd) { found = 1 } found { print } $0 == end { exit }'
      return
    fi
  done
  die "timed out running: $1"
}

# Stop autoboot. The default delay is 2 seconds, so keep sending Ctrl+C until
# well past it, then check there's a prompt answering.
tpi power off -n "$node" >/dev/null
sleep 3
tpi power on -n "$node" >/dev/null
end=$((SECONDS + 20))
while ((SECONDS < end)); do
  tpi uart -n "$node" set -c $'\x03' >/dev/null
done
uboot "version" >/dev/null
echo "node $node: at the u-boot prompt"

uboot "pci enum" >/dev/null
uboot "nvme scan" >/dev/null
blocks=$(uboot "nvme info" | sed -n 's/.*(\([0-9]*\) x 512).*/\1/p' | sort -u)
[[ -n $blocks ]] || die "no NVMe found"
last=$(printf '%#x' $((blocks - 2048)))

uboot "mw.b $buf 0 0x100000" >/dev/null
uboot "nvme write $buf 0 0x800" | grep "blocks written: OK" >/dev/null ||
  die "writing the start of the disk failed"
uboot "nvme write $buf $last 0x800" | grep "blocks written: OK" >/dev/null ||
  die "writing the end of the disk failed"

# Fill a buffer with 0xff, read sectors 0-1 over it, and check the MBR
# signature and GPT header came back as zeros
uboot "mw.b $check 0xff 0x400" >/dev/null
uboot "nvme read $check 0 2" >/dev/null
mbr_line=$(printf '%x' $((check + 0x1f0)))
gpt_line=$(printf '%x' $((check + 0x200)))
zeros=$(uboot "md.b 0x$mbr_line 0x20" | grep -E "^0*($mbr_line|$gpt_line):" | grep -o ' 00' | wc -l) || zeros=0
[[ $zeros -eq 32 ]] || die "sectors 0-1 did not read back as zeros"

tpi power off -n "$node" >/dev/null
echo "node $node: NVMe partition tables wiped ($blocks blocks), powered off"
