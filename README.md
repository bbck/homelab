# homelab

## Raspberry Pi Setup
Flash with [Ubuntu Server 21.10](https://ubuntu.com/download/raspberry-pi). Once flashed copy over the contents of image/ for headless setup.

```
export IP=192.168.16.10 GW=192.168.16.1 HOST=rpi-master
diskutil mountDisk /dev/disk2
envsubst < image/config.txt > /Volumes/system-boot/config.txt
envsubst < image/network-config > /Volumes/system-boot/network-config
envsubst < image/user-data > /Volumes/system-boot/user-data
diskutil unmountDisk /dev/disk2
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
[] Better automation for image flashing

## Inspiration & Credits
* [k8s-at-home](https://github.com/k8s-at-home)
* [raspbernetes](https://github.com/raspbernetes)
* [onedr0p/home-cluster](https://github.com/onedr0p/home-cluster)
* [mjpitz/rpi-cloud-init](https://github.com/mjpitz/rpi-cloud-init)
