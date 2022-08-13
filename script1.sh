#!/bin/bash

cfdisk /dev/nvme0n1
cryptsetup luksFormat --type luks1 /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 void
vgcreate void /dev/mapper/void

lvcreate --name swap -L 23G void
lvcreate --name root -l 100%FREE void

# lvcreate --name root -L 10G void
# lvcreate --name home -l 100%FREE void

# mkfs.ext4 -L home /dev/void/home
mkfs.ext4 -L root /dev/void/root
mkswap /dev/void/swap

mount /dev/void/root /mnt
for dir in dev proc sys run; do 
	mkdir -p /mnt/$dir ; mount --rbind /$dir /mnt/$dir ; mount --make-rslave /mnt/$dir ; 
done

# mkdir -p /mnt/home
# mount /dev/void/home /mnt/home

mkfs.vfat /dev/nvme0n1p1
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi

mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

xbps-install -Sy -R https://repo-default.voidlinux.org/current -r /mnt base-system cryptsetup grub-x86_64-efi lvm2 vim micro

chroot /mnt
