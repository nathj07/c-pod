# Post-install kickstart fragment to create Custom Yum Repository
#
cat <<'CUSTOM_REPO' > /etc/yum.repos.d/custom.repo
[custom]
name=Custom Packages for CentOS Linux $releasever - $basearch
enabled=1
baseurl=http://<!--#echo var=SERVER_NAME -->/yum_repos/custom/$releasever/stable/
failovermethod=priority
gpgcheck=0
priority=10

# Include this repo at lower priority so if package not available above then it looks here

[custom5]
name=Custom Packages for CentOS Linux 5 - $basearch
enabled=1
baseurl=http://<!--#echo var=SERVER_NAME -->/yum_repos/custom/5/stable/
failovermethod=priority
gpgcheck=0
priority=15

CUSTOM_REPO

chmod 644 /etc/yum.repos.d/custom.repo
