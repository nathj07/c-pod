Name:           Bonjour	
Version:        320.10.80
Release:	1%{?dist}
Summary:	Apple Bonjour Distribution

Group:		Networking/Utilities
License:	APSL
URL:		http://www.macosforge.org/post/new-bonjour-releases/
Source0:        http://www.opensource.apple.com/tarballs/mDNSResponder/mDNSResponder-%{version}.tar.gz

BuildRequires:	make gcc bison

%description
A set of packages that can replace Avahi and friends. Specially for use in containers.

%package container
Summary: A lightweight Bonjour mDNS responder for containers

%description container
Just the mDNSResponderPosix component from the full Bonjour package.
This broadcasts the name of the container and advertizes an SSH service.

%package nss
Summary: The NSS component of Bonjour

%description nss
The NSS components from the full Bonjour package.

%prep
%setup -q -n mDNSResponder-%{version}

%build
cd mDNSPosix
make %{?_smp_mflags} os=linux

%clean
%{__rm} -rf $RPM_BUILD_ROOT

%install
mkdir -p -m755 $RPM_BUILD_ROOT%{_bindir}
mkdir -p -m755 $RPM_BUILD_ROOT%{_libdir}
mkdir -p -m755 $RPM_BUILD_ROOT%{_mandir}/man{1,5,8}
mkdir -p -m755 $RPM_BUILD_ROOT%{_sbindir}

install -m755 Clients/build/dns-sd $RPM_BUILD_ROOT%{_bindir}/
install -m755 mDNSPosix/build/prod/mDNSIdentify $RPM_BUILD_ROOT%{_bindir}/
install -m755 mDNSPosix/build/prod/mDNSNetMonitor $RPM_BUILD_ROOT%{_bindir}/
install -m755 mDNSPosix/build/prod/mDNSClientPosix $RPM_BUILD_ROOT%{_bindir}/

install -m755 mDNSPosix/build/prod/libnss_mdns-0.2.so $RPM_BUILD_ROOT%{_libdir}/
install -m755 mDNSPosix/build/prod/libdns_sd.so $RPM_BUILD_ROOT%{_libdir}/

install -m755 mDNSPosix/build/prod/mDNSResponderPosix $RPM_BUILD_ROOT%{_sbindir}/
install -m755 mDNSPosix/build/prod/mDNSProxyResponderPosix $RPM_BUILD_ROOT%{_sbindir}/
install -m755 mDNSPosix/build/prod/dnsextd $RPM_BUILD_ROOT%{_sbindir}/
install -m755 mDNSPosix/build/prod/mdnsd $RPM_BUILD_ROOT%{_sbindir}/

install -m644 mDNSShared/dns-sd.1 $RPM_BUILD_ROOT%{_mandir}/man1/
install -m644 mDNSShared/dnsextd.8 $RPM_BUILD_ROOT%{_mandir}/man8/
install -m644 mDNSShared/mDNSResponder.8 $RPM_BUILD_ROOT%{_mandir}/man8/

install -m644 mDNSPosix/nss_mdns.conf.5 $RPM_BUILD_ROOT%{_mandir}/man5/
install -m644 mDNSPosix/libnss_mdns.8 $RPM_BUILD_ROOT%{_mandir}/man8/

%files

%defattr(-, root, root, 0755)
%{_bindir}/dns-sd
%{_bindir}/mDNSClientPosix
%{_bindir}/mDNSIdentify
%{_bindir}/mDNSNetMonitor

%{_libdir}/libdns_sd.so
%{_libdir}/libnss_mdns-0.2.so
%{_sbindir}/dnsextd
%{_sbindir}/mdnsd
%{_sbindir}/mDNSProxyResponderPosix
%{_sbindir}/mDNSResponderPosix

%{_mandir}/man1/dns-sd.1*
%{_mandir}/man8/dnsextd.8*
%{_mandir}/man8/mDNSResponder.8*

%files container

%defattr(-, root, root, 0755)
%{_sbindir}/mDNSResponderPosix

%files nss

%defattr(-, root, root, 0755)
%{_libdir}/libnss_mdns-0.2.so
%{_mandir}/man5/nss_mdns.conf.5*
%{_mandir}/man8/libnss_mdns.8*

%changelog
* Wed Dec  3 2014 Nick Townsend <nick.townsend@mac.com>
- Release version 320.10.80-1
- First time packaged
