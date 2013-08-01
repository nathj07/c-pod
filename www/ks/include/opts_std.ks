# Standard kickstart options for a production server
# See: http://www.redhat.com/docs/manuals/enterprise/RHEL-5-manual/Installation_Guide-en-US/s1-kickstart2-options.html

install
text
key --skip
lang en_US.UTF-8
keyboard us
firewall --enabled --port=22:tcp
authconfig --enableshadow --enablemd5
selinux --disabled
timezone --utc America/Los_Angeles
