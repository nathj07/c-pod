%define name rc
%define version 1.7.1
%define release 2

Summary:	rc - the Plan 9 and Tenth Edition shell
Name:	%name
Version:	%version
Release:	%{release}ip%{?dist}
Group:	Shells
License:	distributable
Source0:	http://static.tobold.org/rc/%name-%version.tar.gz
Buildroot:	/var/tmp/%{name}-rpmroot

%description
This is a reimplementation for Unix, by Byron Rakitzis, of the Plan 9
shell. rc offers much the same capabilities as a traditional Bourne
shell, but with a much cleaner syntax.

%prep
%setup

%build
sh configure --with-readline --prefix "$RPM_BUILD_ROOT" --mandir "$RPM_BUILD_ROOT/usr/share/man"
make

%install
make install

%files
/bin/rc
/usr/share/man/man1/rc.1.gz

%changelog
* Fri Aug 30 2013 Nick Townsend <ntownsend@iparadigms.com> - 1.7.1-2ip
- Repackaged for iParadigms (added dist macro)

