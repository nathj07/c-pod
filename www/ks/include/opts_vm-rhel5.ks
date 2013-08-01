# Standard kickstart options for a bare virtual machine
# See: http://www.redhat.com/docs/manuals/enterprise/RHEL-5-manual/Installation_Guide-en-US/s1-kickstart2-options.html

install
text
reboot
key --skip
lang en_US.UTF-8
keyboard us
firewall --disabled
authconfig --enableshadow --enablemd5
selinux --disabled
timezone --utc America/Los_Angeles
