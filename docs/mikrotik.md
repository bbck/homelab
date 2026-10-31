# MikroTik

Each device is managed by its OpenTofu project in `terraform/`.

## Bootstrap

1. Suspend the project in tofu-controller.

   ```sh
   flux suspend kustomization tofu-controller-config
   kubectl -n flux-system patch terraform <project> --type merge \
     -p '{"spec":{"suspend":true}}'
   ```

2. Back up with `/system backup save name=pre-reset`, then reset with
   `/system reset-configuration no-defaults=yes skip-backup=yes`.
3. Plug a laptop into the breakglass port, `ether8` on the RB5009. Open the
   device in Winbox by its MAC address from the Neighbors tab, and log in as
   `admin` with the password on the sticker.
4. If `/system/device-mode/print` doesn't show `mode: home`, run
   `/system/device-mode/update mode=home`, then press the reset or mode button
   or unplug the power within 5 minutes.
5. Run the commands from the device's section below.
6. Create the Terraform user with the password from the `routeros-terraform`
   1Password item.

   ```
   /certificate add name=MikroTik-CA common-name=MikroTik-CA days-valid=3650 key-usage=key-cert-sign,crl-sign
   /certificate sign MikroTik-CA
   /certificate sign MikroTik ca=MikroTik-CA
   /ip service set api-ssl certificate=MikroTik disabled=no
   /user group add name=terraform policy=read,write,policy,password,sensitive,api
   /user add name=terraform group=terraform
   ```

7. From the project directory, empty the state and apply.

   ```sh
   mise run tofu -- state list | xargs -r -d '\n' mise run tofu -- state rm
   mise run tofu -- apply
   ```

8. Check that `mise run tofu -- plan` shows no changes. If you applied code
   that isn't on master yet, merge it and wait for the Terraform workflow to
   finish, then resume tofu-controller.

   ```sh
   kubectl -n flux-system patch terraform <project> --type merge \
     -p '{"spec":{"suspend":false}}'
   flux resume kustomization tofu-controller-config
   ```

## cap-ax

```
/interface bridge add name=bridge1 vlan-filtering=yes auto-mac=no admin-mac=[/interface ethernet get ether1 orig-mac-address]
/interface bridge port add bridge=bridge1 interface=ether1
/ip address add address=192.168.88.3/24 interface=bridge1
/ip route add dst-address=0.0.0.0/0 gateway=192.168.88.2
/certificate add name=MikroTik common-name=192.168.88.3 days-valid=3650 key-usage=digital-signature,key-encipherment,tls-server
```
