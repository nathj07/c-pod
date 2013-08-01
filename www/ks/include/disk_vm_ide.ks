# Simple partitioning on first IDE drive
# (autopart creates an LVM setup which is overkill for a VM)

clearpart --all --drives=hda
part /boot --fstype ext3 --size=100 --ondisk=hda
part swap --fstype swap --size 1024
part /	--fstype ext3 --size=2048 --grow 

bootloader --location=mbr --driveorder=hda --append="rhgb quiet"
