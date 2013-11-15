# build ids are not currently generated:
# https://code.google.com/p/go/issues/detail?id=5238
#
# also, debuginfo extraction currently fails with
# "Failed to write file: invalid section alignment"
%global debug_package %{nil}

# we are shipping the full contents of src in the data subpackage, which
# contains binary-like things (ELF data for tests, etc)
%global _binaries_in_noarch_packages_terminate_build 0

# Do not check any files in doc or src for requires
%global __requires_exclude_from ^(%{_datadir}|%{_libdir})/%{name}/(doc|src)/.*$

# Don't alter timestamps of especially the .a files (or else go will rebuild later)
# Actually, don't strip at all since we are not even building debug packages and this corrupts the dwarf testdata
%global __strip /bin/true

Name:		golang
Version:	1.1.2
Release:	4ip%{?dist}
Summary:	The Go Programming Language

License:	BSD
URL:		http://golang.org/
Source0:	https://go.googlecode.com/files/go%{version}.src.tar.gz

BuildRequires:	/bin/hostname
BuildRequires:	rc = 1.7.1

Patch0:		golang-1.1-verbose-build.patch

# Having godoc and the documentation separate was broken
Obsoletes:	%{name}-godoc < 1.1-4
Obsoletes:	%{name}-docs < 1.1-4

# RPM can't handle symlink -> dir with subpackages, so merge back
Obsoletes:  	%{name}-data < 1.1.1-4

ExclusiveArch:	%{ix86} x86_64 %{arm}

Source100:	golang-gdbinit
Source101:	golang-prelink.conf

%description
%{summary}.


# Restore this package if RPM gets fixed (bug #975909)
#%package data
#Summary: Required architecture-independent files for Go
#Requires:	%{name} = %{version}-%{release}
#BuildArch:	noarch
#Obsoletes:	%{name}-docs < 1.1-4
#
#%description data
#%{summary}.


%package vim
Summary: Vim plugins for Go
Requires:    vim-filesystem
BuildArch:   noarch

%description vim
%{summary}.

# Workaround old RPM bug of symlink-replaced-with-dir failure
%pretrans -p <lua>
for _,d in pairs({"api", "doc", "include", "lib", "src"}) do
  path = "%{_libdir}/%{name}/" .. d
  if posix.stat(path, "type") == "link" then
    os.remove(path)
    posix.mkdir(path)
  end
end


%prep
%setup -q -n go

# increase verbosity of build
%patch0 -p1


%build
# create a gcc wrapper to allow us to build with our own flags
mkdir zz
cd zz
echo -e "#!/bin/sh\n/usr/bin/gcc $RPM_OPT_FLAGS $RPM_LD_FLAGS \"\$@\"" > mygcc
chmod +x mygcc
export CC="$(pwd -P)/mygcc"
cd ..

# set up final install location
export GOROOT_FINAL=%{_libdir}/%{name}

# TODO use the system linker to get the system link flags and build-id
# when https://code.google.com/p/go/issues/detail?id=5221 is solved
#export GO_LDFLAGS="-linkmode external -extldflags $RPM_LD_FLAGS"

# build
cd src
./make.bash
cd ..

# build static version of documentation
export GOROOT=$(pwd -P)
export PATH="$PATH":"$GOROOT"/bin
cd doc
make
cd ..

%check
export GOROOT=$(pwd -P)
export PATH="$PATH":"$GOROOT"/bin
cd src
./run.bash --no-rebuild
cd ..


%install
rm -rf $RPM_BUILD_ROOT

# create the top level directories
mkdir -p $RPM_BUILD_ROOT%{_bindir}
mkdir -p $RPM_BUILD_ROOT%{_libdir}/%{name}

# install everything into libdir (until symlink problems are fixed)
# https://code.google.com/p/go/issues/detail?id=5830
cp -av api bin doc favicon.ico include lib pkg robots.txt src \
   $RPM_BUILD_ROOT%{_libdir}/%{name}

# remove the unnecessary zoneinfo file (Go will always use the system one first)
rm -rfv $RPM_BUILD_ROOT%{_libdir}/%{name}/lib/time

# remove the doc Makefile
rm -rfv $RPM_BUILD_ROOT%{_libdir}/%{name}/doc/Makefile

# add symlinks for binaries
pushd $RPM_BUILD_ROOT%{_bindir}
for z in $RPM_BUILD_ROOT%{_libdir}/%{name}/bin/*
  do ln -s %{_libdir}/%{name}/bin/$(basename $z)
done
popd

# misc/bash
mkdir -p $RPM_BUILD_ROOT%{_datadir}/bash-completion/completions
cp -av misc/bash/go $RPM_BUILD_ROOT%{_datadir}/bash-completion/completions
for z in 8l 6l 5l 8g 6g 5g gofmt gccgo
  do ln -s go $RPM_BUILD_ROOT%{_datadir}/bash-completion/completions/$z
done

# misc/vim
mkdir -p $RPM_BUILD_ROOT%{_datadir}/vim/vimfiles
cp -av misc/vim/* $RPM_BUILD_ROOT%{_datadir}/vim/vimfiles
rm $RPM_BUILD_ROOT%{_datadir}/vim/vimfiles/readme.txt

# misc/zsh
mkdir -p $RPM_BUILD_ROOT%{_datadir}/zsh/site-functions
cp -av misc/zsh/go $RPM_BUILD_ROOT%{_datadir}/zsh/site-functions

# gdbinit
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/gdbinit.d
cp -av %{SOURCE100} $RPM_BUILD_ROOT%{_sysconfdir}/gdbinit.d/golang

# prelink blacklist
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/prelink.conf.d
cp -av %{SOURCE101} $RPM_BUILD_ROOT%{_sysconfdir}/prelink.conf.d/golang.conf


%files
%doc AUTHORS CONTRIBUTORS LICENSE PATENTS VERSION

# go files
%{_libdir}/%{name}

# bin symlinks
%{_bindir}/go
%{_bindir}/godoc
%{_bindir}/gofmt

# autocomplete
%{_datadir}/bash-completion
%{_datadir}/zsh

# gdbinit (for gdb debugging)
%{_sysconfdir}/gdbinit.d

# prelink blacklist
%{_sysconfdir}/prelink.conf.d


%files vim
%doc AUTHORS CONTRIBUTORS LICENSE PATENTS
%{_datadir}/vim/vimfiles/*


%changelog
* Thu Aug 29 2013 Nick Townsend <ntownsend@iparadigms.com> - 1.1.2-4ip
- Removed emacs stuff to allow build on Centos 5/6 for iParadigms

* Tue Aug 27 2013 Adam Miller <maxamillion@fedoraproject.org> - 1.1.2-3
- Revert incorrect merged changelog

* Tue Aug 27 2013 Adam Miller <maxamillion@fedoraproject.org> - 1.1.2-2
- This was reverted, just a placeholder changelog entry for bad merge

* Tue Aug 20 2013 Adam Miller <maxamillion@fedoraproject.org> - 1.1.2-1
- Update to latest upstream

* Sat Aug 03 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.1.1-7
- Rebuilt for https://fedoraproject.org/wiki/Fedora_20_Mass_Rebuild

* Wed Jul 17 2013 Petr Pisar <ppisar@redhat.com> - 1.1.1-6
- Perl 5.18 rebuild

* Wed Jul 10 2013 Adam Goode <adam@spicenitz.org> - 1.1.1-5
- Blacklist testdata files from prelink
- Again try to fix #973842

* Fri Jul  5 2013 Adam Goode <adam@spicenitz.org> - 1.1.1-4
- Move src to libdir for now (#973842) (upstream issue https://code.google.com/p/go/issues/detail?id=5830)
- Eliminate noarch data package to work around RPM bug (#975909)
- Try to add runtime-gdb.py to the gdb safe-path (#981356)

* Wed Jun 19 2013 Adam Goode <adam@spicenitz.org> - 1.1.1-3
- Use lua for pretrans (http://fedoraproject.org/wiki/Packaging:Guidelines#The_.25pretrans_scriptlet)

* Mon Jun 17 2013 Adam Goode <adam@spicenitz.org> - 1.1.1-2
- Hopefully really fix #973842
- Fix update from pre-1.1.1 (#974840)

* Thu Jun 13 2013 Adam Goode <adam@spicenitz.org> - 1.1.1-1
- Update to 1.1.1
- Fix basically useless package (#973842)

* Sat May 25 2013 Dan Horák <dan[at]danny.cz> - 1.1-3
- set ExclusiveArch

* Fri May 24 2013 Adam Goode <adam@spicenitz.org> - 1.1-2
- Fix noarch package discrepancies

* Fri May 24 2013 Adam Goode <adam@spicenitz.org> - 1.1-1
- Initial Fedora release.
- Update to 1.1

* Thu May  9 2013 Adam Goode <adam@spicenitz.org> - 1.1-0.3.rc3
- Update to rc3

* Thu Apr 11 2013 Adam Goode <adam@spicenitz.org> - 1.1-0.2.beta2
- Update to beta2

* Tue Apr  9 2013 Adam Goode <adam@spicenitz.org> - 1.1-0.1.beta1
- Initial packaging.
