# C-Pod Repository
------------------

This GIT repository contains a system for automatically installing, configuring
and running CentOS and Ubuntu machines. When the repository is configured with webserving
capabilities it becomes a _C-Pod_. When running on hardware capable of
virtualization it facilitates the easy creation and access to Virtual Machines
using KVM and LXC Containers using Docker.

There are three flavours of C-Pod:

* A Repository Host:
    This uses webserver to host Kickstart scripts, Yum and Gem repositories, and Chef Solo recipes
    Build using the recipe 'c-pod::repo_host'

* A Virtual Machine Host:
    This uses KVM to host Virtual Machines. Note that it needs a Repository Host to create the VM's
    Build using the recipe 'c-pod::kvm_host'

* A Docker Container Host:
    This uses [Docker](http://docker.com) to host LXC Containers.
    Currently this is automatically done by the Vagrant provisioning, and a Chef recipe 'c-pod::docker_host'.

These may be combined together as shown by the default Chef recipe 'c-pod'

## Overview

The Git repository is designed to be used in two ways:

* As the source of the content and code for a *C-Pod*:
    * This [README](README.md)
    * [Kickstart](/ks) definitions for automated installs of standard CentOS
      configurations
    * A Mirror of the [CentOS](#os_mirror) distributions together with a script
      `centos_mirror` to keep it up-to-date. 
    * [YUM repositories](/yum_repos) for distributed, lifted and custom RPMs. There
      is a script `pushpkg` to keep these up-to-date.
    * A [GEM repository](/gem_repo/gems) (`pushpkg` also works for Gems).
    * Chef cookbooks for use with `chef-solo`. This is a
      simple way to use Chef without the complexity of a `chef-server` and
`knife` style installation.

* As a repository within which to develop and test extensions to the system. To
  assist with this it contains:
    * A `bin` directory containing scripts useful in building and deploying
    * An `rpmbuild` directory for packaging RPMs
    * A `gembuild` directory for packaging Ruby GEMs
    * A `chef` directory for creating Chef cookbooks and recipes

This latter function is greatly facilitated by the provision of a
[Docker image](DOCKER.md) for RPM building: `townsen-rpmbuild`.

## Use as a C-Pod Webserver

C-Pod be used to configure itself with a simple bootstrapping operation in three
ways:

### Using Vagrant

Currently the base boxes exist for VMware Fusion only. So you will need to install:
* VMware Fusion, and 
* the Vagrant VMware Fusion provider.

To create a repository host execute:

    vagrant up

You may need to add `--provider=vmware_fusion`

Note that in the Vagrantfile the hostname must be specified. If you want to use
a `.local` name then use just a simple name with no dots. This will
automatically be suffixed by Avahi. If you do suffix it a loopback interface
entry will be generated in `/etc/hosts`. That will interfere with Docker
container setup on the same machine.

### From an existing C-Pod

Login as _root_ to the machine you wish to setup.  It is usually preferable to
use Public Key authentication with an SSH key that is valid for the C-Pod
repository. Make sure you have _AgentForwarding_ setup.

Firstly you'll need to install Git and Ruby, so begin by
[setting up the C-Pod yum repositories](#yum_setup) and running:

    yum install git ruby diffutils

Then follow the steps to [install chef](#chef_install). Then use `chef-solo`
with the runlist override and remote recipe URL parameters:

    chef-solo -o recipe[c-pod] -r http://<%= cgi.server_name %>/bin/recipes.cgi

You may be prompted to confirm the RSA Key fingerprint of GitHub if this is the
first time it has been accessed from this host. 

Note that this installs a dual-function C-Pod as described above. Use the recipes
'c-pod::repo\_host' or 'c-pod::kvm\_host' if required.

### From a cloned repository

Use `chef-solo` with the runlist override and local cookbooks, from the root of
the cloned repository:

    cd chef && chef-solo -c solo.rb -o recipe[c-pod::repo_host]

Note that after this configuration you still have to configure the data
directory that contains large binaries, recipes and packages. See the
[Notes](#cpoddata) section at the end

## Use for Building Packages

Clone the repository and develop and test the packages on your 'home' machine.
You can easily do this by doing `vagrant up` to start a VM, and then creating
one of the provided Docker Images. These are structured so that the rpmbuild
directory is mounted all the way to the container, so changes that are made
during the packaging are easy to commit back.

To avoid storing build artifacts in the repo (despite the fact that the Gem and
RPM build trees are held within it), there are `.gitignore` files that exclude
the built binaries and packaging by-products.

When the packages are ready you can `pushpkg` them to the C-Pod itself, spin up
a fresh container and install them in a 'clean' environment, highlighting any
packaging or runtime dependencies.


### How to build a GEM

* Change to the subdirectory containing the gem.
* Issue the command `gem build <gemname>.gemspec`
* Use the `bin/pushpkg` command to upload the package to the server. It will
  automatically rebuild the indices.
* You can then `gem install` the new version.

### How to build an RPM

* Make sure that the package `rpm-build` is installed
* Establish the correct locations by creating a `~/.rpmmacros` file with the
  line:

    %_topdir &lt;path-to-repo&gt;/repo/rpmbuild

* __NOTE__ If packaging on CentOS 5 also add the macros `%dist .el5` and
  `%centos 5`. These are automatically defined in CentOS 5.
* Ensure that the source for the package is in the SOURCES directory (only
  `.patch` files are retained). You may have to read the SPEC file to see where
to obtain this.
* Change to the SPEC directory and issue the command `rpmbuild -bb`
* Use the `bin/pushpkg` command to upload the package to the server. It will
  automatically rebuild the indices.
* You can then `yum install` the new version. You may need to do `yum clean all`

When creating new specfiles that have different structure depending on CentOS 5
or 6, use the following conditional macro structure:

```
%if 0%{?centos} == 6 Do CentOS 6 specific stuff %else Do CentOS 5 specific stuff %endif
```

#### RPM Package Names

To distinguish between packages such as ruby or openssh, which are simply
repackages of existing ones, and truly custom stuff we will adopt the RPMforge
convention of using a dot-delimited release qualifier for the former. So our
repackaged builds will contain 'el6.cp'. and custom packages '_N_cp.el6' (where
N is the release number).

A convention with many RPM packages is to use '.el6' or '.rhel5' in the name to
indicate which OS release. This value is used by `pushpkg` to determine the right
repository tree. For packages that don't contain such an indicator you can now
specify the version as an option.

#### Building RPM Packages

Certain packages (such as, remarkably, *git*) have an EPEL version for CentOS 5
that is later than anything in CentOS 6. Since we would like to keep versions
the same (as much as we can) for such important packages, we download the SRPM,
tweak the SPECfile to contain an *.ip* release suffix and build our own RPMs.
Note that the package release is dot-delimited to match they style of RPMforge
and EPEL. If the *ip* was part of the release number that would signify that we
actually changed something in the package.

## Creating Machine Images
Note that the use of Docker containers is recommended but legacy methods of creating machine images are provided.

### Remote Install Using Kickstart

First download an image file to boot the OS for a networked install. These image
files are available in the [downloads](/downloads/) directory for each supported
OS:

* A [CentOS 5](/downloads/CentOS-5.9-x86_64-netinstall.iso) boot image (~15Mb).
  At the boot prompt type

    linux ks=http://<%= cgi.server_name %>/ks/c5-vm.ks?host=&lt;enter desired fqdn&gt;

* A [CentOS 6](/downloads/CentOS-6.4-x86_64-netinstall.iso) boot image (~240Mb).
  At the boot prompt hit `tab` then *add* the following to the existing grub
command

    ks=http://<%= cgi.server_name %>/ks/c6-vm.ks?host=&lt;enter desired fqdn&gt;

In both cases the desired FQDN (fully qualified domain name) can be an existing
name or an mDNS name (ending in `.local`). If the name exists in the DNS system
then the IP address will be configured, otherwise the network will use DHCP.

Notes on VM types:

* Prefixes indicate the CentOS version: `centosN` where N is the major release.
* Kickstart definitions are suffixed to denote Virtualization technology:
    * `-kvm` denotes KVM based Virtual Machines (and uses device `vda`)
    * `-vm` denotes VMware, uses device `sda` and include an installation of VMware tools

### Creating Virtual Machines

The script `mk_kvm` can be used by the root user on a C-Pod host to create a
KVM.  In order to correctly determine the network parameters from the hostname
given, a site-specific mapping table must be provided in the file
`bin/netmask_table`. A sample file is provided. Note that this file is backed
up by the `update_repo` script.


### Creating Docker Containers

By default the C-Pod runs a Docker server unsecured on port 2375. To access this
use:

    export DOCKER_HOST=tcp://<c-pod-server-fqdn>:2375

See [the Docker notes](DOCKER.md) for details

<a name="gem_setup"></a>
## GEM Repository

The C-Pod contains it's own GEM repository. This serves two purposes:

*   It allows us to determine exactly the set of GEMs that we will use, without
    needing to use Bundler or similar. This guarantees stability in a production
    environment.
*   It allows us to host private GEMS that are not public.
*   It allows us to create ''binary'' GEMs for situations where we don't want
    production machines to have a compiler or build tools.

To restrict access to only these GEMs, Kickstart automatically creates
[/etc/gemrc](/samples/gemrc):

    gem: --no-document --source http://<%= cgi.server_name %>/gem_repo

Alternatively you can [download them directly](/gems) and install locally.

<a name="os_mirror"></a>
## OS Mirror

The C-Pod server contains mirrors of the distributions to allow easy install and update

### CentOS 5

* The [CentOS 5](/osmirror/centos/5/os/x86_64) distribution DVD
* The current [updates](/osmirror/centos/5/updates)
* [ISO Images](/osmirror/centos/5/isos/x86_64)

### CentOS 6

* The [CentOS 6](/osmirror/centos/6/os/x86_64) distribution DVD
* The current [updates](/osmirror/centos/6/updates)
* [ISO Images](/osmirror/centos/6/isos/x86_64)

### CentOS 7

* The [CentOS 7](/osmirror/centos/7/os/x86_64) distribution DVD
* The current [updates](/osmirror/centos/7/updates)
* [ISO Images](/osmirror/centos/7/isos/x86_64)

<a name="yum_setup"></a>
## YUM Repositories

The following setup is done automatically on Kickstarted machines. You will need
to do this manually when bootstrapping a C-Pod or doing a non-Kickstart install.

YUM repositories have been created to contain all required packages 'locally'
and the location of these are defined in the file `/etc/yum.repos.d/c-pod.repo`.
To avoid conflicts the standard install repositories (beginning with _CentOS-_)
are moved to `/root/saved.repos.d/`. Since `yum` is currently unable to resolve
`.local` names this file will need to use [the address](samples/c-pod.repo) for
the C-Pod host unless a DNS entry exists when [the
name](samples/c-pod-name.repo) can be used.  (Click on the links for a sample
for this server).

### Priorities

See [YUM Priorities](http://wiki.centos.org/PackageManagement/Yum/Priorities)
for a description.  In order to allow unstable packages to be deployed in
preference to stable ones, even when the version is the same, we define them to
have the a lower priority (ie. higher precedence). Install one of the following
packages to enable this:

    yum install yum-plugin-priorities   # For CentOS 6 yum install
    yum install yum-priorities          # For CentOS 5

### Repositories

A C-Pod has at least four repositories (and more may be added for installation
specific packages outside the scope of C-Pod). These are:

*  Custom RPMs (Unstable)

   When developing a new release of a custom RPM this repository is used. This
repository is disabled by default and should only be enabled on test machines.

*  Custom RPMs (Stable)

   This is for the current production version of
internally developed or modified packages.

*  Lifted RPMs

   This repository contains RPMs normally found on other repositories, EPEL or RPM
Forge for example. To avoid having to be connected to the Internet during
installs these can be downloaded using `yumdownloader` and stored in this
repository. It also contains packages that may not be customized or altered in
any way, but are just built and deployed here. They are considered stable and
are used as part of the base Kickstart builds.

*  CentOS Distribution and Updates

   To save bandwidth and speed-up networked installs the Distribution repositories
are available, both original and updates.

### Naming Conventions

The names of the YUM repositories on disk are standardized so that we can use
the $releasever variable.  This enables us to have a single repository
configuration [file](/samples/c-pod.repo) that automatically points to the
correct place.

The repo names are modeled on the CentOS mirror layout and are of the form:

    TYPE/$releasever

Where:

* TYPE is one of:
    * 'lifted': Useful and required packages from Epel and RPMforge
    * 'stable': Custom packages tested and 'in production'
    * 'unstable': Custom packages under development/testing
* $releasever is supplied by the OS: 5Server, 6Server, 7Server (for RedHat), 5, 6, 7
    (for CentOS).


### Missing Packages

If you require packages that are not currently in the C-Pod then you should
download them and add them to the appropriate C-Pod yum repository. Typically
this is the _lifted_ repository. This is to avoid dependency resolution just
happening invisibly and pulling in unknown versions of new packages. For example
to obtain packages from either EPEL or RPMforge firstly:

    yum install epel-release rpmforge-release

Then download the required RPMs and place them in the _lifted_ repository.
This can be done in two ways:

#### One by One

Do the following:

* `yumdownloader <packages>` to obtain local copies
* `/data/c-pod/bin/pushpkg -f -t lifted <packages>` which uploads them to the
  lifted repo
* disable the epel and rpmforge repositories by either `rpm -e epel-release
  rpmforge-release`, or edit the `/etc/yum.repos.d/{epel,rpmforge}.repo` files
and set `enabled=0`
* `yum clean all` to force a refresh
* `yum install <packages>`  to install the new packages from _lifted_

#### All at Once

Edit the file `/etc/yum.conf` to set `keepcache=1`. Enable EPEL and RPMforge
then `yum install` packages as you need. When complete upload all the packages
from the cache directory (`/var/cache/yum`) to the _lifted_ repo using something
like the following on CentOS 5:

    find /var/cache/yum/{epel,rpmforge} | xargs /data/c-pod/bin/pushpkg -t lifted -f

or, for CentOS 6:

    find /var/cache/yum/x86_64/6/{epel,rpmforge} | xargs /data/c-pod/bin/pushpkg -t lifted -f

## Chef

This repository contains a Chef cookbook (in the [chef](/chef)
subdirectory) that is used to configure and setup a C-Pod and it's clients.
This cookbook (_c-pod_) is symbolically linked into a directory named `cookbooks`
at the same level as the repository. You should create your own Chef cookbooks
and recipes there (and not in the main repository). From there they may be used
with `chef-solo` either in local or remote mode. Local mode is typically used
when developing and testing recipes and remote mode when configuring machines
with existing recipes. To facilitate the latter case the Kickstart process
automatically installs a stable binary version of `chef` on a new machine
together with all the necessary configuration files to retrieve recipes from the
C-Pod server.

### Using Recipes Locally

Clone the repository and make the appropriate modification. Run `chef-solo` with
a configuration file that points to the local filesystem. A working sample with
instructions is in the file [solo.rb](/chef/solo.rb).  Note that you should make
changes to the repository using your real username (and SSH key) but then run
`chef-solo` as root if you are making system level changes.

### Serving Recipes Remotely

When configured as a webserver the Chef definitions are available remotely using
the `bin/recipes.cgi` URL - this downloads the entire tree as a _tgz_ file for
use by the `recipe_url` parameter of `chef-solo`.

<a name="chef_install"></a>
### Manual Installation

The easiest way is to download and install a pre-built package from [Chef](https://downloads.chef.io).

Note that the gem `ruby-shadow` is required to allow Chef to set passwords.

    gem install ruby-shadow chef

Create a configuration file [/etc/chef/solo.rb](/samples/solo.rb):

``` ruby
    file_cache_path '/var/chef/cache'
    cookbook_path   '/var/chef/cookbooks'
    recipe_url      'http://<%= cgi.server_name %>/bin/recipes.cgi'
    json_attribs '/etc/chef/cpod.json'
```
Create a simple JSON configuration file [/etc/chef/cpod.json](/samples/cpod.json):

``` json
    { "run_list": [ "recipe[c-pod::client]" ] }
```

### Running Chef Solo

Then run the command `chef-solo` which will (using the above defaults) configure
the C-Pod default client. To add your own recipes you can run a command like:

    chef-solo -o recipe[c-pod::townsen],recipe[c-pod::mediawiki]

Alternatively use a non-default JSON file with the `-f` option. Set the
'run_list' value appropriately.

## Accessing Servers

Since the C-Pod runs entirely on an RFC1918 private network inside the machine,
network services are not normally available from the outside world. However, the
C-Pod configures a SOCKS5 Proxy to overcome this.

### SSH Access

For the names that you wish to access, create entries in your
local `.ssh/config` file as follows:

    Host ds*.local cpod*.local
    ProxyCommand /usr/bin/nc -X 5 -x <%= cgi.server_name %>:1080 %h %p

If you want most `.local` names to reside on the C-Pod, but have some that do not
(for example a C-Pod running inside a virtual machine `cpod.local`) you can invert this using:

    Host cpod.local
    ProxyCommand none

    Host *.local
    ProxyCommand /usr/bin/nc -X 5 -x <%= cgi.server_name %>:1080 %h %p

The `nc` command is standard under MacOS - you may need to install it if using
another OS.

If you need to connect via a bastion host, then use a command like:

    ssh -L 0.0.0.0:1080:<%= cgi.server_name%>:1080 -N bastion.host.com &

with this in your SSH configuration:

    ProxyCommand /usr/bin/nc -X 5 -x localhost:1080 %h %p


### Web Access

A Proxy Access File (or 'pac' file) has been created that will direct your
browser to use the SOCKS proxy for `.local` requests. Enable this by configuring
your browser proxy to use:

    http://<%= cgi.server_name %>/c-pod.pac

Safari, Firefox and Chrome have all be tested. Note that at time of writing
Cisco AnyConnect VPN is incompatible with the native Mac OS X proxy support.
Use Firefox as a workaround.

Note that this is a *default* file. The recommended practice is for the site
maintainer to construct a `cpod.pac` file. This file will be ignored by git,
and will be replicated by `update_repo`.

### Advanced Web Proxying

If you are an 'advanced' user and wish to access multiple servers across C-Pods,
or proxy to many locations, then you should create and maintain your own PAC file.
Here is a sample:

```js
function FindProxyForURL(url, host) {
  recpod = /(ds.*|ub\d+)\.local/;
  if (recpod.test(host)) {
      return "SOCKS5 cpod.local:1080 ; SOCKS cpod.local:1080 ";
  }
  rebuild2 = /bs\d+\.local/;
  if (rebuild2.test(host)) {
      return "SOCKS5 ip-cpod2.oak.iparadigms.com:1080 ; SOCKS ip-cpod2.oak.iparadigms.com:1080 ";
  }
  if (dnsDomainIs(host, ".netflix.com")) {
    return "PROXY quithutu.proxysolutions.net:40004";
  }
  return "DIRECT";
}
```

Since Safari on Mac OSX will only accept _http_ hosted PAC files, install it on the Apache
server built into Mac OSX (Paths for Mavericks)

```bash
sudo cp <pacfile.pac> /Library/WebServer/Documents
sudo apachectl start
```

Then you can configure the proxy file as 'http://localhost/pacfile.pac'. Note:
* Use the file extension `.pac` for the PAC file to correctly set the mime-type
* Safari requires a restart to pick up changes to this.

### Server Port Access

Directly Accessing Server Ports from Outside the C-Pod.

The C-Pod server is configured as a NAT-PMP gateway. So if you have no ability
to configure a system to use the SOCKS Proxy to access C-Pod then you can use
NAT-PMP to do this. Upon request it can open either a UDP or TCP port on the
C-Pod host and forward traffic to a specific cp-pod server. A suitable command
line interface is available `gem install natpmp`. You should use at least
version 0.9. Type `natpmp -?` for the syntax.

The C-Pod socks setup recipe will install and configure `stallone` for this purpose.
An appropriate RPM is available in the lifted repository for this. This has been
built with changes appropriate to the C-Pod's use of libvirtd's network setup.

## Notes

### Supported OS Versions

One point release of each major release of various Operating Systems is supported at any given
time. Currently these are:

* Centos 5.9
* Centos 6.6
* Centos 7.0
* Ubuntu 14.10

### Apache Configuration

The following setup steps are automated in the script `bin/setup_repo` executed
as part of the recipe:

* Apache configuration is done with the Apache configuration file template
  `c-pod.conf.erb` which is processed by ERB to create the file
`/etc/httpd/conf.d/_c-pod.conf`. The _DocumentRoot_ used is determined by the
current repository location

* Set the permissions of the tree to be owned by the Apache user: `chown -R
  apache.apache /data/c-pod`

<a id=cpoddata></a>
### C-Pod Data

The bulk of a C-Pod installation consists of site-specific Chef recipes,
downloads, RPM and GEM packages, ISO images and OS installation trees etc.
This data is kept outside of the repository in a separat directory by default
named '/srv/cpoddata', although this can be changed.  It contains the following
subdirectories:

* `cookbooks`: Chef recipes.
* `downloads`: Any sort of useful file
* `gem_repo`: A GEM repository
* `osmirror`: A mirror of various Operating Systems
* `yum_repos`: YUM repositories

These are accessed from the webserver via symbolic links that are setup by the
`c-pod::repo_structure` recipe at installation time. For example the repository
`www/downloads` directory is linked to `/srv/cpoddata/downloads`.

Although the structure is setup at installation, the content isn't. If you have an existing C-Pod
that you wish to keep up to date with use the `update_repo` script.

Content is added in the following ways:

#### Chef Recipes

Clone a Git repository containing cookbooks into `/srv/cpoddata`. The first
level will be the cookbook name.

#### OS Mirror

Create the OS mirror using the `bin/mk_osmirror` command. Which requires you
have ISO images.  Alternatively you can create this tree from a mirror site
using the `centos_mirror` script.

#### GEM and YUM Repositories

These can be populated manually in two ways:

* On the server by copying the `.rpm` and `.gem` files into the appropriate
  directory (after building them) and then running the script
`rebuild_indexes`.

* On your local machine by using the script `bin/pushpkg` to upload packages
  using HTTP.  This will initiate an index rebuild automatically after upload.

#### Downloads

These must be copied manually into the downloads directory.
