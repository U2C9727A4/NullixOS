#!/bin/bash


if [ $(whoami) = root ]; then
  echo "\n"
else
  echo "Youre gonna need root permission with this."
  exit 1
fi

getuuid() {
  returnuuid=$(blkid -s UUID -o export ${1} | grep -v ${1})
  echo $returnuuid
}

getfstype() {
  returntype=$(blkid -s TYPE -o export ${1} | grep TYPE | sed 's/.*=//')
  echo $returntype
}

installi3wm() {
xbps-install gdm i3 i3status dmenu alacritty firefox xorg pulseaudio pavucontrol
ln -s /etc/sv/elogind/ /etc/runsvdir/default/
ln -s /etc/sv/gdm/ /etc/runsvdir/default/
ln -s /etc/sv/pulseaudio/ /etc/runsvdir/default/

}

echo "THIS SCRIPT ASSUMES YOURE IN A CHROOT OF THE NULLIXOS ROOTFS IMAGE!"
echo "ALL RELATED PARTITIONS MUST BE UNMOUNTED BEFORE USING THIS SCRIPT!"
echo "All partitions that are to be used with Nullix must be made before running the script!"
echo ""
echo "Please make all changes to the rootfs BEFORE running this script!"
echo "Welcome to NullixOS! This script should take you through the process of installin' the system!"
echo "So, What should be the root password buddy?\n"
passwd root
echo "Got the root password!"
echo "Next, Select a user name. (Password will be asked later on)"
echo "User name: "
read username
echo "User is set! Now lets talk about partitions bud."
echo "NullixOS requires 3 partitions. One for boot related stuff, One for the root and another for home."
echo "Everything on those partitions will be removed. Please backup important data before using this script."
gum confirm "Have you created the necesarry partitions?" || echo "Please create all partitions first, and then re-run the script." && exit
echo "So, Whats the boot partition? (NullixOS currently works ONLY on UEFI. x86_64)""
echo "Boot Partition location (Eg. /dev/sda1): "
read bootpart
echo "Boot partition number (If your boot partition is /dev/sda1, your partition number is 1.):\n"
read bootpartnum
echo "What about home?"
echo "Home partition location: "
read homepart
echo "Now the last part (pun intended) Wheres the root partition? Please do not specify a root partition that is not the partition that NullixOS rootfs tarball lives on, as this part is only needed for fstab configuration."
echo "Root partition location: "
read rootpart

echo "Well, Everything should be set at this point. I will start working on setting up the system!"
rm -rf /boot
mkfs.vfat -F 32 ${bootpart}
mkdir /boot
mount ${bootpart} /boot
cp -r /bootfs/* /boot/
grub-install --target=x86_64-efi --efi-directory=/boot/efi bootloader-id="NullixOS"
grub-mkconfig -o /bootfs/grub/grub.cfg
grub-mkconfig -o /boot/grub/grub.cfg
bootdev=$(lsblk -no pkname ${bootpart})
efibootmgr --create --disk /dev/${bootdev} --part ${bootpartnum} --loader /efi/EFI/Void/grubx64.efi --label "NullixOS"
xbps-install -Syu linux
echo "Boot setup done!"
mkfs.ext4 ${homepart}
mount ${homepart} /home
useradd -m ${username}
usermod -aG audio ${username}
usermod -aG video ${username}
echo "What should be the password for ${username}?"
passwd ${username}

bootuuid=$(getuuid ${bootpart})
homeuuid=$(getuuid ${homepart})
rootuuid=$(getuuid ${rootpart})
roottype=$(getfstype ${rootpart})

echo "${rootuuid} / ${roottype} ro,defaults 0 1" >> /etc/fstab
echo "${bootuuid} /boot vfat ro,defaults 0 1" >> /etc/fstab
echo "${homeuuid} /home ext4 defaults 0 1" >> /etc/fstab


gum confirm "Wanna install a basic desktop with i3wm,xorg and pulseaudio?" && installi3wm
echo "Well, Everything should be set! Have fun doing what you want! (Please reboot)"

