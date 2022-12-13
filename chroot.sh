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

clear

# Handle host configuration
echo "Please enter a hostname (Like: mato-laptop): "
read hostname

# Set hostname
echo $hostname > /etc/hostname

# Setup /etc/hosts
echo "127.0.0.1		localhost" >> /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.1.1		$hostname.localdomain	$hostname" >> /etc/hosts

# Set hostname using hostnamectl
hostnamectl set-hostname $hostname

# Install sudo
pacman -S --noconfirm sudo

clear

# Ask for root password
echo "Please enter a root password (for the root user)"
passwd

# Prompt user for their password. This will be the root and user password at the same time
echo "Hey, what's your name? (make sure this is all lower case)"
read username

# Create user and ask for its password as well
useradd -m $username
echo "Please enter your password (for your user)"
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
echo "Grub installed successfully. Let's proceed with our own packages now! (KDE and nvidia driver)"

# Ensure we're up to date
pacman -Syu

# KDE plasma and nvidia driver as well as all applications I think I'd need
pacman -S --noconfirm xorg plasma-desktop sddm networkmanager kwallet-pam konsole kate dolphin nvidia chromium spectacle

# Enable required services
systemctl enable sddm.service
systemctl enable NetworkManager.service

clear
rm /chroot.sh # clean up
read -p "Arch Linux has been installed. Reboot your computer to start using it."
