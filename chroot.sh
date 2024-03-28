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
locale-gen
clear

# Handle host configuration
echo "Please enter a hostname (Like: icseon-pc): "
read hostname

# Set hostname
echo $hostname > /etc/hostname

# Setup /etc/hosts
echo "127.0.0.1		localhost" >> /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.1.1		$hostname.localdomain	$hostname" >> /etc/hosts
hostnamectl set-hostname $hostname

# Install sudo
pacman -S --noconfirm sudo

clear

# Ask for root password
echo "Enter a root password"
passwd

# Prompt user for their password. This will be the root and user password at the same time
echo "What's your name? (make sure this is all lower case)"
read username

# Create user and ask for its password as well
useradd -m $username
echo "Enter your password"
passwd "$username"

# Add our user to the wheel group for sudo access
usermod -aG wheel $username
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Grub installation
pacman -S --noconfirm grub efibootmgr
mkdir /boot/efi
mount $1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=ArchLinux --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

clear
echo "grub installed successfully. let's proceed with our own packages now."

# Enable multilib (32-bit packages eg.: wine32)
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

# Ensure we're up to date
pacman -Syu --noconfirm

# nvidia: fixes err:vulkan:wine_vkcreateinstance failed to create instance, res=-1
pacman -S --noconfirm nvidia-utils lib32-nvidia-utils

# Applications I just want
pacman -S --noconfirm git chromium nano wine # steam

# Ensure removal of lib32-amdvlk and amdvlk
pacman -Rs amdvlk lib32-amdvlk

# nvidia: driver and settings applet
pacman -S --noconfirm nvidia nvidia-settings

# GNOME Desktop
pacman -S --noconfirm gnome-browser-connector gnome-shell nautilus gnome-terminal gnome-control-center gnome-screenshot gedit

# Display server (xorg)
pacman -S --noconfirm --needed sddm xorg

# Fonts and emoji
pacman -S --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji

# Networking
pacman -S --noconfirm networkmanager

# Bluetooth
pacman -S --noconfirm bluez bluez-utils bluedevil
modprobe btusb

# Configure the grub bootloader
sed -i 's/loglevel=3 quiet/loglevel=3 quiet nvidia-drm.modeset=1/g' /etc/default/grub # kernel flag for nvidia
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub # remove the 5 second wait time
grub-mkconfig -o /boot/grub/grub.cfg

# This solves a problem with tearing. You may not need it, I do.
sed -i '$i\    Option "TripleBuffer" "true"' /usr/share/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf

# Enable services
systemctl enable sddm.service
systemctl enable NetworkManager.service
systemctl enable bluetooth.service

clear
rm /chroot.sh # clean up - we no longer require this file
read -p "Arch Linux has been setup successfully. Reboot to continue."
