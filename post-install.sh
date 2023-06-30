# Install yay for AUR packages we'll want to aquire
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --needed --noconfirm && cd .. && rm -rf ./yay

# Install opentabletdriver (native wacom driver is pretty terrible)
yay -Sy opentabletdriver --noconfirm
systemctl --user daemon-reload && systemctl --user enable opentabletdriver --now
echo "blacklist wacom" | sudo tee -a /etc/modprobe.d/blacklist.conf
sudo rmmod wacom

# Install Streamdeck interface
sudo pacman -S hidapi python-pip qt6-base
python -m pip install --upgrade pip --break-system-packages
python -m pip install setuptools --break-system-packages
sudo sh -c 'echo "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"0fd9\", TAG+=\"uaccess\"" > /etc/udev/rules.d/70-streamdeck.rules'
sudo udevadm trigger
python -m pip install streamdeck-ui --user --break-system-packages

# Create .desktop file for streamdeck (easy ui access)
curl https://raw.githubusercontent.com/Icseon/ArchInstall/main/applications/streamdeck-ui.desktop -o ~/.local/share/applications/streamdeck-ui.desktop

# Install Discord and create .desktop files for Wayland and X11
yay -Sy discord
curl https://raw.githubusercontent.com/Icseon/ArchInstall/main/applications/discord-wayland.desktop -o ~/.local/share/applications/discord-wayland.desktop
curl https://raw.githubusercontent.com/Icseon/ArchInstall/main/applications/discord-x11.desktop -o ~/.local/share/applications/discord-x11.desktop

# Make sure Streamdeck autostarts once GNOME is initialised
mkdir ~/.config/autostart
curl https://raw.githubusercontent.com/Icseon/ArchInstall/main/applications/streamdeck-autostart.desktop -o ~/.config/autostart/streamdeck-autostart.desktop

# Show Minimize and Maximize buttons
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"

# Create user directories
xdg-user-dirs-update
