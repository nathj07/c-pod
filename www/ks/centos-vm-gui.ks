# Kickstart file for a Gnome Desktop Virtual Machine
# Nick Townsend, April 2010
#

<!--#include virtual="include/opts_vm.ks" -->

xconfig --defaultdesktop=GNOME --resolution=1024x768 --startxonboot --depth=24

<!--#include virtual="include/dvdimage.ks" -->

network --device eth0 --bootproto dhcp --hostname centos-vm.local

<!--#include virtual="include/rootpw_secret.ks" -->

<!--#include virtual="include/disk_vm.ks" -->

<!--#include virtual="include/ksrepo.ks" -->

%packages
<!--#include virtual="include/pkgs_min.ks" -->
@base-x
@gnome-desktop

%post --interpreter /bin/bash
<!--#include virtual="include/strepo.ks" -->
<!--#include virtual="include/multilibs.ks" -->
<!--#include virtual="include/vmware_tools.ks" -->
