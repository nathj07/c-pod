# Post-install kickstart fragment to create ST Yum Repository
# Note that puppet will update these once it is run.

cat <<'STREPO' > /etc/yum.repos.d/st.repo
[st]
name=Sye Custom Packages for RedHat Linux $releasever - $basearch
enabled=1
baseurl=http://<!--#echo var=SERVER_NAME -->/repos/st/$releasever/stable/
failovermethod=priority
gpgcheck=0

[osdvd]
name=RedHat Enterprise Linux $releasever - Distribution DVD - $basearch
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
exclude=postgresql*
baseurl=http://<!--#echo var=SERVER_NAME -->/repos/rhel/$releasever/repo/
exclude=postgresql* ghostscript* ImageMagick*

[updates]
name=RedHat Enterprise Linux $releasever - Updates - $basearch
baseurl=http://<!--#echo var=SERVER_NAME -->/repos/rhel/$releasever/updates/
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
exclude=postgresql* ghostscript* ImageMagick*
STREPO

chmod 644 /etc/yum.repos.d/st.repo
