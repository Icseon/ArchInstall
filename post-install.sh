# Install yay for AUR packages we'll want to aquire
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --needed --noconfirm && cd .. && rm -rf ./yay

# Install opentabletdriver (native wacom driver is pretty terrible)
yay -Sy opentabletdriver --noconfirm
systemctl --user daemon-reload && systemctl --user enable opentabletdriver --now
echo "blacklist wacom" | sudo tee -a /etc/modprobe.d/blacklist.conf
sudo rmmod wacom

# Install streamdeck-ui so I can use my streamdeck
yay -Sy streamdeck-ui --noconfirm

# Enable streamdeck service
systemctl enable streamdeck --user

# Show Minimize and Maximize buttons
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"

# Create user directories
xdg-user-dirs-update
