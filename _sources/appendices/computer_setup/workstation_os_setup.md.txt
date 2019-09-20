# Workstation operating system setup

## BIOS

TODO

## OS Installation

Boot into Kubuntu 18.04 x86_64 install media and select `Try Kubuntu`.

## Create RAID devices

```

sudo su
apt install mdadm

for drive in /dev/sda /dev/sdb; do
    parted -s $device -- mklabel msdos
    parted -s $device -- mkpart primary 2MiB 500MiB
    parted -s $device -- mkpart primary 500MiB 100%
done
mdadm --create /dev/md/boot --level=1 --raid-devices=2 /dev/sda1 /dev/sdb1
# answer yes at prompt about metadata on boot device
mdadm --create /dev/md/root --level=1 --raid-devices=2 /dev/sda2 /dev/sdb2
# answer yes at prompt about metadata on boot device
```

## Install Kubuntu

Open 'Install Kubuntu' from the dekstop icon and proceed with interactive installation following these choices.

### Language

English

### Keyboard

English (US)

### Software

Check "Minimal Installation"
Check "Download updates while installing Kubuntu"
Do not check "Install third-party software..." as we will install nVIDIA drivers manually.

### Disk Setup

Choose "Manual"

Select /dev/md126, click continue on prompt about creating a new partition table.

Device for boot loader installation: `/dev/sda`

### Timezone

Phoenix time



## Return to the [main setup guide](computer_setup.md)
