# Automatic Disk partitioning using LVM
# Small initial sizes for standalone VM's
#
clearpart --all --drives=sda --initlabel
part /boot --fstype ext3 --size=150
part pv.01 --size=1 --grow
volgroup vg00 pv.01
logvol  /  --vgname=vg00  --size=2048  --name=lv_root
logvol	swap --vgname=vg00 --size=2048 --name=lv_swap
logvol  /var  --vgname=vg00  --size=1024  --name=lv_var
logvol  /tmp  --vgname=vg00  --size=1024  --name=lv_tmp
logvol  /home  --vgname=vg00  --size=1024  --name=lv_home
logvol  /data  --vgname=vg00  --size=1  --grow  --name=lv_data
bootloader --location=mbr --driveorder=sda --append="rhgb quiet"
