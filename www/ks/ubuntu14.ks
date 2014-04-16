#Generated by Kickstart Configurator
#Not working yet
#platform=x86

#System language
lang en_US.UTF-8
#Language modules to install
langsupport en_HK.UTF-8 en_DK.UTF-8 en_IN en_ZM en_ZW.UTF-8 en_NZ.UTF-8 en_PH.UTF-8 en_NG en_GB.UTF-8 en_AU.UTF-8 en_SG.UTF-8 en_BW.UTF-8 en_AG en_ZA.UTF-8 en_CA.UTF-8 en_IE.UTF-8 en_US.UTF-8 --default=en_US.UTF-8
#System keyboard
keyboard us
#System mouse
mouse
#System timezone
timezone America/Los_Angeles
#Root password
rootpw --iscrypted $1$Ih5pLngr$/boiJHqKbQm9AP/QQyq0b1
#Initial user
user --disabled
#Install OS instead of upgrade
install
#Use CDROM installation media
#cdrom
url --url http://<!--#echo var=SERVER_ADDR -->/osdisks/ubuntu14/ubuntu

network --device eth0 <!--#exec cgi="/bin/netcfg.centos.cgi" -->

# Disk Setup

#Clear the Master Boot Record

zerombr yes
clearpart --all --drives=vda --initlabel msdos
part /boot --fstype ext3 --size=150
part pv.01 --size=1 --grow
volgroup vg00 pv.01
logvol  /  --vgname=vg00  --size=4096  --grow --name=lv_root
logvol  swap --vgname=vg00 --size=2048 --name=lv_swap
bootloader --location=mbr --driveorder=vda --append="console=tty0 console=ttyS0,115200"

#Firewall configuration
firewall --disabled --trust=eth0 --ssh

#Do not configure the X Window System
skipx

#Package install information
%packages
accountsservice
acpid
adduser
apache2
apache2-bin
apache2-data
apache2-mpm-prefork
apparmor
apport
apport-symptoms
apt
apt-transport-https
apt-utils
apt-xapian-index
aptitude
aptitude-common
at
avahi-daemon
base-files
base-passwd
bash
bash-completion
bc
bind9-host
biosdevname
bsdmainutils
bsdutils
busybox-initramfs
busybox-static
byobu
bzip2
ca-certificates
command-not-found
command-not-found-data
console-setup
coreutils
cpio
crda
cron
curl
dash
dbus
debconf
debconf-i18n
debianutils
dh-python
diffutils
dmidecode
dmsetup
dnsutils
dosfstools
dpkg
e2fslibs
e2fsprogs
ed
eject
ethtool
file
findutils
fonts-ubuntu-font-family-console
friendly-recovery
ftp
fuse
gawk
gcc-4.8-base
gcc-4.9-base
geoip-database
gettext-base
gir1.2-glib-2.0
gnupg
gpgv
grep
groff-base
grub-common
grub-gfxpayload-lists
grub-pc
grub-pc-bin
grub2-common
gzip
hdparm
hicolor-icon-theme
hostname
hwdata
ifupdown
info
init-system-helpers
initramfs-tools
initramfs-tools-bin
initscripts
insserv
install-info
installation-report
iproute2
iptables
iputils-ping
iputils-tracepath
irqbalance
isc-dhcp-client
isc-dhcp-common
iso-codes
isoquery
kbd
keyboard-configuration
klibc-utils
kmod
krb5-locales
landscape-common
language-pack-en
language-pack-en-base
language-selector-common
laptop-detect
less
libaccountsservice0
libacl1
libaio1
libapache2-mod-php5
libapparmor-perl
libapparmor1
libapr1
libaprutil1
libaprutil1-dbd-sqlite3
libaprutil1-ldap
libapt-inst1.5
libapt-pkg4.12
libarchive-extract-perl
libasn1-8-heimdal
libasprintf0c2
libattr1
libaudit-common
libaudit1
libavahi-client3
libavahi-common-data
libavahi-common3
libavahi-core7
libbind9-90
libblkid1
libboost-iostreams1.54.0
libbsd0
libbz2-1.0
libc-bin
libc6
libcap-ng0
libcap2
libcap2-bin
libck-connector0
libclass-accessor-perl
libcomerr2
libcurl3
libcurl3-gnutls
libcwidget3
libdaemon0
libdb5.3
libdbd-mysql-perl
libdbi-perl
libdbus-1-3
libdbus-glib-1-2
libdebconfclient0
libdevmapper-event1.02.1
libdevmapper1.02.1
libdns100
libdrm2
libedit2
libelf1
libept1.4.12
libestr0
libevent-2.0-5
libexpat1
libffi6
libfreetype6
libfribidi0
libfuse2
libgc1c2
libgcc1
libgck-1-0
libgcr-3-common
libgcr-base-3-1
libgcrypt11
libgdbm3
libgeoip1
libgirepository-1.0-1
libglib2.0-0
libglib2.0-data
libgnutls-openssl27
libgnutls26
libgpg-error0
libgpm2
libgssapi-krb5-2
libgssapi3-heimdal
libhcrypto4-heimdal
libheimbase1-heimdal
libheimntlm0-heimdal
libhtml-template-perl
libhx509-5-heimdal
libidn11
libio-string-perl
libisc95
libisccc90
libisccfg90
libiw30
libjson-c2
libjson0
libk5crypto3
libkeyutils1
libklibc
libkmod2
libkrb5-26-heimdal
libkrb5-3
libkrb5support0
libldap-2.4-2
liblocale-gettext-perl
liblockfile-bin
liblockfile1
liblog-message-simple-perl
liblwres90
liblzma5
libmagic1
libmodule-pluggable-perl
libmount1
libmpdec2
libmysqlclient18
libncurses5
libncursesw5
libnewt0.52
libnfnetlink0
libnih-dbus1
libnih1
libnl-3-200
libnl-genl-3-200
libnss-mdns
libnuma1
libp11-kit0
libpam-cap
libpam-modules
libpam-modules-bin
libpam-runtime
libpam-systemd
libpam0g
libparse-debianchangelog-perl
libparted0debian1
libpcap0.8
libpci3
libpcre3
libpcsclite1
libpipeline1
libplymouth2
libpng12-0
libpod-latex-perl
libpolkit-agent-1-0
libpolkit-backend-1-0
libpolkit-gobject-1-0
libpopt0
libprocps3
libpython-stdlib
libpython2.7
libpython2.7-minimal
libpython2.7-stdlib
libpython3-stdlib
libpython3.4-minimal
libpython3.4-stdlib
libreadline5
libreadline6
libroken18-heimdal
librtmp0
libsasl2-2
libsasl2-modules
libsasl2-modules-db
libselinux1
libsemanage-common
libsemanage1
libsepol1
libsigc++-2.0-0c2a
libsigsegv2
libslang2
libsqlite3-0
libss2
libssl1.0.0
libstdc++6
libsub-name-perl
libsystemd-daemon0
libsystemd-login0
libtasn1-6
libterm-readkey-perl
libterm-ui-perl
libtext-charwidth-perl
libtext-iconv-perl
libtext-soundex-perl
libtext-wrapi18n-perl
libtimedate-perl
libtinfo5
libudev1
libusb-0.1-4
libusb-1.0-0
libustr-1.0-1
libuuid1
libwind0-heimdal
libwrap0
libx11-6
libx11-data
libxapian22
libxau6
libxcb1
libxdmcp6
libxext6
libxml2
libxmuu1
libxtables10
linux-firmware
linux-generic
linux-headers-3.13.0-19
linux-headers-3.13.0-19-generic
linux-headers-generic
linux-image-3.13.0-19-generic
linux-image-extra-3.13.0-19-generic
linux-image-generic
locales
lockfile-progs
login
logrotate
lsb-base
lsb-release
lshw
lsof
ltrace
lvm2
makedev
man-db
manpages
mawk
memtest86+
mime-support
mlocate
module-init-tools
mount
mountall
mtr-tiny
multiarch-support
mysql-client-5.5
mysql-client-core-5.5
mysql-common
mysql-server
mysql-server-5.5
mysql-server-core-5.5
nano
ncurses-base
ncurses-bin
ncurses-term
net-tools
netbase
netcat-openbsd
ntfs-3g
ntpdate
openssh-client
openssh-server
openssh-sftp-server
openssl
os-prober
parted
passwd
patch
pciutils
perl
perl-base
perl-modules
php5-cli
php5-common
php5-json
php5-mysql
php5-readline
plymouth
plymouth-theme-ubuntu-text
policykit-1
popularity-contest
powermgmt-base
ppp
pppconfig
pppoeconf
procps
psmisc
python
python-apt
python-apt-common
python-chardet
python-configobj
python-debian
python-gdbm
python-minimal
python-openssl
python-pam
python-pkg-resources
python-requests
python-serial
python-six
python-twisted-bin
python-twisted-core
python-urllib3
python-xapian
python-zope.interface
python2.7
python2.7-minimal
python3
python3-apport
python3-apt
python3-commandnotfound
python3-dbus
python3-distupgrade
python3-gdbm
python3-gi
python3-minimal
python3-newt
python3-problem-report
python3-pycurl
python3-software-properties
python3-update-manager
python3.4
python3.4-minimal
readline-common
resolvconf
rsync
rsyslog
run-one
screen
sed
sensible-utils
sgml-base
shared-mime-info
software-properties-common
ssh-import-id
ssl-cert
strace
sudo
systemd-services
systemd-shim
sysv-rc
sysvinit-utils
tar
tasksel
tasksel-data
tcpd
tcpdump
telnet
time
tmux
tzdata
ubuntu-keyring
ubuntu-minimal
ubuntu-release-upgrader-core
ubuntu-standard
ucf
udev
ufw
unattended-upgrades
update-manager-core
update-notifier-common
upstart
ureadahead
usbutils
util-linux
uuid-runtime
vim
vim-common
vim-runtime
vim-tiny
w3m
watershed
wget
whiptail
wireless-regdb
wireless-tools
wpasupplicant
xauth
xkb-data
xml-core
xz-utils
zlib1g