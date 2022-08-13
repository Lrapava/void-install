#!/bin/bash

chown root:root /
chmod 755 /
passwd root
echo void > /etc/hostname
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/default/libc-locales
xbps-reconfigure -f glibc-locales

echo "# <file system>	<dir>		<type>	<options>				<dump>	<pass>" > /etc/fstab
echo "tmpfs				/tmp		tmpfs	defaults,nosuid,nodev	0		0" >> /etc/fstab
echo "/dev/void/root	/			xfs		defaults				0		0" >> /etc/fstab
# echo "/dev/void/home	/home		xfs		defaults				0		0" >> /etc/fstab
echo "/dev/void/swap	swap		swap	defaults				0		0" >> /etc/fstab
echo "/dev/nvme0n1p1	/boot/efi	vfat	defaults				0		0" >> /etc/fstab

echo "GRUB_ENABLE_CRYPTODISK=y" >> /etc/default/grub

micro /etc/default/grub

dd bs=1 count=64 if=/dev/urandom of=/boot/volume.key
cryptsetup luksAddKey /dev/nvme0n1p2 /boot/volume.key

chmod 000 /boot/volume.key
chmod -R g-rwx,o-rwx /boot

echo "void	/dev/nvme0n1p2	/boot/volume.key	luks" >> /etc/crypttab
echo "install_items+=\" /boot/volume.key /etc/crypttab \"" > /etc/dracut.conf.d/10-crypt.conf

grub-install /dev/nvme0n1
xbps-reconfigure -fa
