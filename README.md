# homelab

## Raspberry Pi Setup
Run the flash script with an [Ubuntu Server 22.04](https://ubuntu.com/download/raspberry-pi) image. Once flashed copy over the contents of image/ for headless setup.

```
❯ ./image/flash.sh $HOME/Downloads/ubuntu-22.04-preinstalled-server-arm64+raspi.img
Password:
HOSTNAME: rpi-node-01
TAILSCALE AUTH KEY:
Unmount of all volumes on disk2 was successful
Flashing onto /dev/disk2
..........
3755+0 records in
3755+0 records out
3937402880 bytes transferred in 300.710638 secs (13093660 bytes/sec)
re-mounting disk...
One or more volume(s) failed to mount
copying files...
unmounting disk...
Unmount of all volumes on disk2 was successful
```

## Ansible

```
ansible-galaxy install -r requirements.yml
ansible-playbook main.yml
```

## Bootstraping Flux

Create an [age](https://age-encryption.org) key and
```
age-keygen -o age.agekey

cat age.agekey |
kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=/dev/stdin
```

## ToDo
- [ ] Better automation for image flashing
- [ ] Automated k3s upgrade PRs

## Inspiration & Credits
* [k8s-at-home](https://github.com/k8s-at-home)
* [raspbernetes](https://github.com/raspbernetes)
* [onedr0p/home-cluster](https://github.com/onedr0p/home-cluster)
* [mjpitz/rpi-cloud-init](https://github.com/mjpitz/rpi-cloud-init)
