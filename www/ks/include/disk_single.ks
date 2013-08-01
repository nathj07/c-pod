# Simple small partitioning on first SCSI drive

clearpart --all --drives=sda
part /boot --fstype ext3 --size=100 --ondisk=sda
part swap --fstype swap --size 1024
part /	--fstype ext3 --size=2048 --grow 

bootloader --location=mbr --driveorder=sda --append="rhgb quiet"
