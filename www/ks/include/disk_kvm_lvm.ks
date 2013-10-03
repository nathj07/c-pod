# Automatic Disk partitioning for KVM using LVM
# A single large root partition
# Setup bootloader with serial console
#
clearpart --all --drives=vda --initlabel msdos
part /boot --fstype ext3 --size=150
part pv.01 --size=1 --grow
volgroup vg00 pv.01
logvol  /  --vgname=vg00  --size=4096  --grow --name=lv_root
logvol	swap --vgname=vg00 --size=2048 --name=lv_swap
bootloader --location=mbr --driveorder=vda --append="console=tty0 console=ttyS0,115200"
