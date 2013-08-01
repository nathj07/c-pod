# Post-install kickstart fragment to create SYE Yum Repository
#
cat <<'SYE_REPO' > /etc/yum.repos.d/sye.repo
[sye]
name=SYE Custom Packages for CentOS Linux $releasever - $basearch
enabled=1
baseurl=http://<!--#echo var=SERVER_NAME -->/repos/sye/$releasever/stable/
failovermethod=priority
gpgcheck=0
priority=10

# Include this repo at lower priority so if package not available above then it looks here

[sye5]
name=SYE Custom Packages for CentOS Linux 5 - $basearch
enabled=1
baseurl=http://<!--#echo var=SERVER_NAME -->/repos/sye/5/stable/
failovermethod=priority
gpgcheck=0
priority=15

[updates]
name=CentOS Enterprise Linux $releasever - Updates - $basearch
baseurl=http://<!--#echo var=SERVER_NAME -->/repos/rhel/$releasever/updates/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
priority=20

[osdvd]
name=CentOS Enterprise Linux $releasever - Distribution DVD - $basearch
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
exclude=postgresql*
baseurl=http://<!--#echo var=SERVER_NAME -->/repos/rhel/$releasever/repo/
priority=30
STREPO

chmod 644 /etc/yum.repos.d/sye.repo
