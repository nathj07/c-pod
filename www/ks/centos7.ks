# Minimal file for CentOS 7
# Without Network Manager or firewall or SE Linux

install
lang en_GB.UTF-8
keyboard us
timezone America/Los_Angeles
auth --useshadow --enablemd5
selinux --disabled
firewall --disabled
#services --enabled=NetworkManager,sshd
services --enabled=sshd
eula --agreed
ignoredisk --only-use=sda
reboot
 
network --device eth0 <!--#exec cgi="/bin/netcfg.centos.cgi" -->

zerombr
<!--#include virtual="include/disk_lvm_7.ks" -->
 
<!--#include virtual="include/rootpw_secret.ks" -->
 
<!--#include virtual="include/install_repos7.ks" -->

<!--#include virtual="include/dvdimage-centos7.ks" -->
 
%packages --nobase --ignoremissing
@core
%end
