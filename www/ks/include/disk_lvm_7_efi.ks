# Automatic Disk partitioning using LVM
# A single large root partition

clearpart --all --initlabel
part /boot/efi --fstype efi --size=200
part /boot --fstype ext4 --size=500
part pv.01 --size=1 --grow
volgroup sysvg pv.01
logvol  /  --vgname=sysvg  --size=4096  --grow --name=lv_root
logvol	swap --vgname=sysvg --size=2048 --name=lv_swap
