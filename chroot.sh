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
echo "grub installed successfully. let's proceed with our own packages now."

# Ensure we're up to date
pacman -Syu

# nvidia
pacman -S --noconfirm nvidia nvidia-settings

# Plasma and its components
pacman -S --noconfirm sddm xorg plasma-desktop plasma-pa kscreen kwallet-pam konsole kate dolphin spectacle

# Fonts and emoji
pacman -S --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji

# Networking
pacman -S --noconfirm networkmanager

# Other applications I just want
pacman -S --noconfirm chromium nano

# Enable services
systemctl enable sddm.service
systemctl enable NetworkManager.service

# let's install yay, too.
pacman -S --noconfirm git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf ./yay

clear
rm /chroot.sh # clean up
read -p "Arch Linux has been installed. Now, you just reboot. Have fun, future me."
