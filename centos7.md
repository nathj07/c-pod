# Notes on CentOS 7 Install

After a bare installation of CentOS 7 the following need to be done. They will
eventually be put into a recipe.

* Disable selinux

## Setup the firewall

Add the `/etc/firewalld/services/socks.xml` file

```bash
yum install ruby ruby-devel
firewall-cmd --set-default-zone=home
firewall-cmd --permanent --zone=home --add-service=socks
firewall-cmd --permanent --zone=home --add-service=http
firewall-cmd --reload
```

## EPEL

```bash
curl -O http://mirror.pnl.gov/epel/7/x86_64/e/epel-release-7-2.noarch.rpm
```

```bash
yum install nss-mdns
```
