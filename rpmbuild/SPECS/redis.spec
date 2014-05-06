Summary: Redis
Name: redis
Version: 2.8.9
Release: 0%{?dist}
License: BSD-type
Group: Networking/Utilities
URL: http://redis.io
Vendor: Redis
Source: http://download.redis.io/releases/%{name}-%{version}.tar.gz
Source1: redis.init
Source2: redis.conf
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildRequires: make

%description
Redis is an open source, BSD licensed, advanced key-value store.
It is often referred to as a data structure server since keys can contain strings,
hashes, lists, sets and sorted sets.

%prep
%setup -n %{name}-%{version}

%build
%{__make}

%install
mkdir -p -m755 $RPM_BUILD_ROOT%{_bindir}
make PREFIX=$RPM_BUILD_ROOT%{_exec_prefix} install

install -d $RPM_BUILD_ROOT%{_var}/redis
install -d $RPM_BUILD_ROOT%{_initddir}
install -m644 %{SOURCE1} $RPM_BUILD_ROOT%{_initddir}/redis
install -d $RPM_BUILD_ROOT%{_sysconfdir}/redis/
install -m644 %{SOURCE2} $RPM_BUILD_ROOT%{_sysconfdir}/redis/6379.conf

%clean
%{__rm} -rf $RPM_BUILD_ROOT

%post
/sbin/chkconfig --add redis

%preun
if [ $1 = 0 ]; then
   /sbin/service redis stop > /dev/null 2>&1 || :
   /sbin/chkconfig --del redis
fi

%files
%defattr(-, root, root, 0755)
%doc README CONTRIBUTING
%dir %attr(0755,root,root) %{_var}/redis
%config %{_sysconfdir}/redis/6379.conf
%attr(0755,root,root) %{_initddir}/redis
%{_bindir}/redis-server
%{_bindir}/redis-benchmark
%{_bindir}/redis-cli
%{_bindir}/redis-check-dump
%{_bindir}/redis-check-aof

%changelog
* Tue Apr 29 2014 Nick Townsend <nick.townsend@mac.com>
- Release version 2.8.9-0

* Thu Nov 21 2013 Nick Townsend <nick.townsend@mac.com>
- Initial specfile
