# Post-install kickstart fragment to create Sye Yum Repository
# Note that puppet will update these once it is run.

cat <<'STREPO' > /etc/yum.repos.d/st.repo
[st]
name=Sye Custom Packages for RedHat Linux $releasever - $basearch
enabled=1
baseurl=http://<!--#echo var=SERVER_NAME -->/repos/st/$releasever/stable/
failovermethod=priority
gpgcheck=0
priority=10

[st5]
name=Sye Custom Packages for RedHat Linux 5 - $basearch
enabled=1
baseurl=http://<!--#echo var=SERVER_NAME -->/repos/st/5Server/stable/
failovermethod=priority
gpgcheck=0
priority=15

[updates]
name=RedHat Enterprise Linux $releasever - Updates - $basearch
baseurl=http://<!--#echo var=SERVER_NAME -->/repos/rhel/$releasever/updates/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
priority=20

[osdvd]
name=RedHat Enterprise Linux $releasever - Distribution DVD - $basearch
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
exclude=postgresql*
baseurl=http://<!--#echo var=SERVER_NAME -->/repos/rhel/$releasever/repo/
priority=30
STREPO

chmod 644 /etc/yum.repos.d/st.repo
