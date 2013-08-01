# Kickstart file for Repo RedHat Virtual Machine
# This requires the CD image
#
<!--#include virtual="../include/opts_vm.ks" -->

cdrom

network --device eth0 --bootproto dhcp --hostname repo.local

<!--#include virtual="../include/rootpw_secret.ks" -->

<!--#include virtual="../include/disk_single.ks" -->

%packages

<!--#include virtual="../include/pkgs_min.ks" -->

%post --interpreter /bin/bash
<!--#include virtual="../include/strepo.ks" -->
<!--#include virtual="../include/multilibs.ks" -->
<!--#include virtual="../include/config_vm.ks" -->
<!--#include virtual="setupnick.ks" -->

# Add mount entry for the RedHat DVD

mkdir -p /mnt/centos5dvd
ex /etc/fstab <<FSTAB
$
a
/dev/cdrom		/mnt/centos5dvd	iso9660	ro
.
x
FSTAB

# Add the RedHat repo entry...

cat <<RHDVDREPO > /etc/yum.repos.d/rheldvd.repo
[rheldvd]
name=RedHat Enterprise Linux 5 DVD - x86_64
enabled=1
baseurl=file:///mnt/rheldvd/Server
failovermethod=priority
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
RHDVDREPO
