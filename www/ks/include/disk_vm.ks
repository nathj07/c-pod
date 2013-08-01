# Standard VM disk lay out for Vmware

clearpart --all --drives=sda

part /boot --fstype ext3 --size 200
part /usr --fstype ext3 --size=4096
part /var --fstype ext3 --size=4096
part / --fstype ext3 --size=2048 --asprimary
part /home --fstype ext3 --size=1024
part /tmp --fstype ext3 --size=1024
part swap --size=2048
part /data --fstype ext3 --size=100 --grow

bootloader --location=mbr --driveorder=sda --append="rhgb quiet"
