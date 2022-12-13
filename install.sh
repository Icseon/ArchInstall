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
mkfs.btrfs $rootPartition -f

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
curl https://raw.githubusercontent.com/Icseon/ArchInstall/main/chroot.sh -o /mnt/chroot.sh
chmod +x /mnt/chroot.sh
arch-chroot /mnt ./mnt/chroot.sh
exit
