# Post-install kickstart fragment to create Custom Yum Repository
# Note these are in priority sequence
#
cat <<'CUSTOM_REPO' > /etc/yum.repos.d/custom.repo
[custom]
name=Custom Packages for CentOS Linux $releasever - $basearch
enabled=1
baseurl=http://<!--#echo var=SERVER_NAME -->/yum_repos/custom/$releasever/stable/
failovermethod=priority
gpgcheck=0
priority=10

[lifted]
name=Lifted Packages for CentOS Linux $releasever - $basearch
enabled=1
baseurl=http://<!--#echo var=SERVER_NAME -->/yum_repos/lifted/$releasever/
failovermethod=priority
gpgcheck=0
priority=15

[centos]
name=Copy of Distribution Packages for CentOS Linux $releasever - $basearch
enabled=1
baseurl=http://<!--#echo var=SERVER_NAME -->/osdisks/centos$releasever/
failovermethod=priority
gpgcheck=0
priority=20

[custom5]
name=Custom Packages for CentOS Linux 5 - $basearch
enabled=1
baseurl=http://<!--#echo var=SERVER_NAME -->/yum_repos/custom/5/stable/
failovermethod=priority
gpgcheck=0
priority=25

CUSTOM_REPO

chmod 644 /etc/yum.repos.d/custom.repo
