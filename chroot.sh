clear

# Ask the user for their timezone and set their timezone
echo "What is your timezone? (Like: Europe/Amsterdam): "
read timezone
timedatectl set-timezone $timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc

# Handle locales
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Handle host configuration
echo "Please enter a hostname (Like: mato-laptop): "
read $hostname
echo $hostname > /etc/hostname

# Setup /etc/hosts
echo "127.0.0.1		localhost" >> /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.1.1		$hostname.localdomain	$hostname >> /etc/hosts"

# Install sudo
pacman -S --noconfirm sudo

# Prompt user for their password. This will be the root and user password at the same time
echo "Hey, what's your name? (make sure this is all lower case)"
read username

# Ask for root password
echo "Please enter a root password (for the root user)"
passwd

# Create user and ask for its password as well
useradd -m $username
echo "Please enter your password (for your user)"
passwd "$username"

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
pacman -S --noconfirm xorg plasma-desktop networkmanager konsole kate dolphin nvidia chromium spectacle

# Enable required services
systemctl enable sddm.service
systemctl enable NetworkManager.service

clear
rm /chroot.sh # clean up
read -p "We are done here. Press any key to reboot and start using Arch Linux!"
reboot now
