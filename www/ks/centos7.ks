# Minimal file for CentOS 7 with MBR and classic partitions
# Without Network Manager or firewall or SE Linux

text
install
lang en_GB.UTF-8
keyboard us
timezone America/Los_Angeles
auth --useshadow --enablemd5
selinux --disabled
firewall --disabled
services --disabled=NetworkManager --enabled=network,sshd
eula --agreed
ignoredisk --only-use=sda
reboot
 
network --device eth0 <!--#exec cgi="/bin/netcfg.centos.cgi" -->

zerombr

# Setup bootloader disabling 'Predictable Network Names'
#
bootloader --location=mbr --append="console=tty0 net.ifnames=0"
<!--#include virtual="include/disk_lvm_7.ks" -->
 
<!--#include virtual="include/rootpw_secret.ks" -->
 
<!--#include virtual="include/install_repos7.ks" -->

<!--#include virtual="include/dvdimage-centos7.ks" -->
 
%packages --nobase --ignoremissing
@core
net-tools
%end

<!--#include virtual="include/yum-repo.ks" -->
