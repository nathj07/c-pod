# Standard VM disk lay out for RedHat 6 on Vmware

clearpart --all --drives=sda

part /boot --fstype=ext4 --size 200
part /usr --fstype=ext4 --size=4096
part /var --fstype=ext4 --size=4096
part / --fstype=ext4 --size=2048 --asprimary
part /home --fstype=ext4 --size=1024
part /tmp --fstype=ext4 --size=1024
part swap --size=2048
part /data --fstype=ext4 --size=100 --grow

bootloader --location=mbr --driveorder=sda --append="crashkernel=auto rhgb quiet"
