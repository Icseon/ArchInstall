# Install yay for AUR packages we'll want to aquire.
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --needed --noconfirm && cd .. && rm -rf ./yay

# Install opentabletdriver.
yay -Sy opentabletdriver --noconfirm
# systemctl --user daemon-reload && systemctl --user enable opentabletdriver --now
# echo "blacklist wacom" | sudo tee -a /etc/modprobe.d/blacklist.conf
sudo mkinitcpio -P
sudo rmmod wacom
sudo rmmod hid_uclogic

# Install Streamdeck interface.
sudo pacman -S hidapi python-pip qt6-base
python -m pip install --upgrade pip --break-system-packages
python -m pip install setuptools --break-system-packages
sudo sh -c 'echo "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"0fd9\", TAG+=\"uaccess\"" > /etc/udev/rules.d/70-streamdeck.rules'
sudo udevadm trigger
python -m pip install streamdeck-ui --user --break-system-packages

# Make sure Streamdeck autostarts once the desktop is initialised.
mkdir ~/.config/autostart
curl https://raw.githubusercontent.com/Icseon/ArchInstall/main/applications/streamdeck-autostart.desktop -o ~/.config/autostart/streamdeck-autostart.desktop
chmod +x ~/.config/autostart/streamdeck-autostart.desktop