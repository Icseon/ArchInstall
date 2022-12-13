clear
echo "- Icseon's ArchLinux Installer -"
echo "Just for when you need the bare minimum and nothing else."
echo "This installer will wipe the target disk you choose to use. Please ensure you wish to do that."

# Prompt the user for the disk they wish to install to
lsblk
echo "Enter the disk you wish to use. You'll want to format it as such: /dev/sda1"
echo "Reminder: Everything will be lost. Please stop the installation if you have important data"
read targetDisk

# Delete all partitions within the target disk
echo "Deleting all partitions ..."
dd if=/dev/zero of=$targetDisk bs=512 count=1 conv=notrunc

# Instruct the user to create a parition of 1GB for EFI and use the remaining space for the root partition
echo "In the next step, you'll have to create a new partition that's 1024M for the EFI partition and use the rest for your root partition"
read -p "Press any key once you understood the next procedure"
cfdisk $targetDisk

# List all paritions and ask the user for the EFI and root partitions
lsblk
echo "Please specify your EFI partition (like: /dev/sda1): "
read efiPartition
echo "Please specify your root partition (like: /dev/sda2): "
read rootPartition

# Format EFI partition
echo "Formatting EFI partition as F32 ..."
mkfs.fat -F32 $efiPartition

# Format root partition
echo "Formatting root partition as btrfs ..."
mkfs.btrfs $rootPartition

# Mount root partition to /mnt
mount $rootPartition /mnt

# Let the user know that the disk setup has completed
clear
read -p "Disk setup has completed. The installation will begin once you press any key"

# Begin installing the required packages
pacstrap /mnt base base-devel linux linux-firmware

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# We'll need to run this script under chroot, so we'll create a new file so we can do that under that context
sed '1,/^#chroot$/d' `basename $0` > /mnt/install-chroot.sh
chmod +x /mnt/install-chroot.sh
arch-chroot /mnt ./mnt/install-chroot.sh
exit

# chroot

# Update all packages
pacman -Syu

# Ask the user for their timezone and set their timezone
read timezone "What is your timezone? (Like: Europe/Amsterdam): "
timedatectl set-timezone $timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc

# Handle locales
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Handle host configuration
read hostname "Please enter a hostname (Like: icseon-laptop)"
echo $hostname > /etc/hostname

# Setup /etc/hosts
echo "127.0.0.1		localhost" >> /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.1.1		$hostname.localdomain	$hostname >> /etc/hosts"

# Install sudo
pacman -S --noconfirm sudo

# Prompt user for their password. This will be the root and user password at the same time
read username "Hey, what's your name? (make sure this is all lower case)"
read password "Awesome... but what will your password be?"

# Set root password
echo "$password" | passwd --stdin

# Create user and set its password as well
adduser "$username"
echo "$password" | passwd "$username" --stdin

# Add our user to the wheel group for sudo access
usermod -aG wheel $username
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Ask our user what the EFI partition is again - we're in a different context
lsblk
echo "Please specify your EFI partition (like: /dev/sda1): "
read efiPartition

# Grub installation
pacman -S --noconfirm grub efibootmgr
mkdir /boot/efi
mount $efiPartition /boot/efi
grub-install --target=x86_64-efi --bootloader-id=ArchLinux --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

clear
echo "Grub installed successfully. Let's proceed with our own packages now! (KDE and nvidia driver)"

# Ensure we're up to date
pacman -Syu

# KDE plasma and nvidia driver
pacman -S --noconfirm xorg plasma nvidia

# Enable required services
systemctl enable sddm.service
systemctl enable NetworkManager.service

# Optional: Packages I personally use, I'll make this optional so others may use this script as well
read -p "Would you like to install the packages Icseon uses?"
if [[ $REPLY =~ ^[Yy]$ ]]
then
    pacman -S --noconfirm chromium dolphin kate spectacle spotify
fi

clear
rm /mnt/install-chroot.sh # clean up
read -p "We are done here. Press any key to reboot and start using Arch Linux!"
reboot 0
