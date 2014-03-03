Name:           stallone
Version:        0.4.0
Release:        1%{?dist}
License:        LGPL - See COPYING
URL:            http://tedp.id.au/stallone/
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildRequires:  libdaemon-devel
Source0:        http://tedp.id.au/stallone/releases/stallone-0.4.0.tar.gz
Patch0:         stallone-libvirtd.patch
Summary:        A NAT-PMP daemon
Group:          Development/Languages

%description
Stallone runs on devices that perform Network Address Translation (NAT), allowing machines on private networks to request that TCP and UDP ports be forwarded to them. The protocol used is called NAT Port Mapping Protocol (NAT-PMP) which was originally implemented in Apple's AirPort devices.

It is currently written for Linux machines using IP Tables but can easily be modified to work with other routing/firewalling mechanisms.

%prep
%setup
%patch0 -p1

%build

%configure --with-natpmd-group=nobody
make %{?_smp_mflags}

%install
# installing binaries ...
make install DESTDIR=$RPM_BUILD_ROOT

#we don't want to keep the src directory
rm -rf $RPM_BUILD_ROOT/usr/src

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root, root)
/etc/stallone/natpmd.conf
/usr/sbin/stallone
/usr/share/stallone/natpmd.action

%changelog
* Sat Mar  1 2014 Nick Townsend <nick.townsend@mac.com> - 0.4.0-1
- Initial RPM packaging
