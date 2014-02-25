# Setup the C-Pod repositories

# Set multilibs_policy to best

ex /etc/yum.conf <<YUMCONF
1
/\[main\]/a
multilib_policy=best
.
x
YUMCONF

# Disable the installed CentOS repositories by moving them out of the directory
# (Too complex to just set enabled=0 as some aren't explicit- they default to enabled)
# Note that these have to use IP address as yum won't resolve .local names

mkdir /root/saved.repos.d
mv /etc/yum.repos.d/*  /root/saved.repos.d/

cat > /etc/yum.repos.d/c-pod.repo <<'CPOD'
[unstable]
name=Custom RPMs for CentOS $releasever - $basearch
baseurl=http://<!--#echo var=SERVER_ADDR -->/yum_repos/custom/$releasever/unstable/
enabled=0
gpgcheck=0
priority=10

[stable]
name=Custom RPMs for CentOS $releasever - $basearch
baseurl=http://<!--#echo var=SERVER_ADDR -->/yum_repos/custom/$releasever/stable/
enabled=1
gpgcheck=0
priority=20

[lifted]
name=Lifted RPMs for CentOS $releasever - $basearch
baseurl=http://<!--#echo var=SERVER_ADDR -->/yum_repos/lifted/$releasever/
enabled=1
gpgcheck=0
priority=30

[centos]
name=CentOS $releasever Linux Distribution DVD - x86_64
baseurl=http://<!--#echo var=SERVER_ADDR -->/osdisks/centos$releasever
enabled=1
gpgcheck=1
gpgkey=http://<!--#echo var=SERVER_ADDR -->/RPM-GPG-KEY-CentOS-$releasever
priority=40
CPOD
