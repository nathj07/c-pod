# C-Pod Repository
------------------

This GIT repository contains a system for automatically installing, configuring and running CentOS machines. When the repository is configured with webserving capabilities it becomes a _C-Pod_. When running on hardware capable of virtualization it facilitates the easy creation and access to Virtual Machines using KVM.

## Overview

It is designed to be used in two ways:

* As a *C-Pod* - a webserver to serve up various content (including this README!)
    * [Kickstart](/ks) definitions for automated installs of standard CentOS configurations
    * The [CentOS 5](/osdisks/centos5) and [CentOS 6](/osdisks/centos6) distribution DVDs
    * [YUM repositories](/yum_repos) for distributed, lifted and custom RPMs
    * A [GEM repository](/gem_repo/gems)
    * [Chef cookbooks](/chef/cookbooks) for use with `chef-solo`. This is a simple way to use Chef without the complexity of a `chef-server` and `knife` style installation.
* As a repository within which to develop and test extensions to the system. To assist with this it contains:
    * A `bin` directory containing scripts useful in building and deploying 
    * An `rpmbuild` directory for packaging RPMs 
    * A `gembuild` directory for packaging Ruby GEMs
    * A `chef` directory for creating Chef cookbooks and recipes

## Use as a C-Pod Webserver

C-Pod be used to configure itself with a simple bootstrapping operation in two ways:

### From an existing C-Pod

Use `chef-solo` with the runlist override and remote recipe URL parameters:

    chef-solo -o recipe[c-pod::setup] -r http://<%= cgi.server_name %>/bin/recipes.cgi

### From a cloned repository

Use `chef-solo` with the runlist override and local cookbooks, from the root of the cloned repository:

    cd chef
    chef-solo -c config.rb -o recipe[c-pod::setup]

Note that after this configuration you still have to configure the large binaries. See the [Notes](#binaries) section at the end

## Use for Building Packages

Clone the repository and develop and test the packages on your 'home' machine. When they are ready and have been tested locally, commit the changes and spin up an empty VM. Then try the packaging again, so that it takes place in a 'pure' environment, highlighting any packaging or runtime dependencies.

To avoid storing build artifacts in the repo (despite the fact that the Gem and RPM build trees are held within it), there are `.gitignore` files that exclude the built binaries and packaging by-products.

### How to build a GEM

* Change to the subdirectory containing the gem.
* Issue the command `gem build <gemname>.gemspec`
* Use the `bin/pushpkg` command to upload the package to the server. It will automatically rebuild the indices.
* You can then `gem install` the new version.

### How to build an RPM

* Make sure that the package `rpm-build` is installed
* Establish the correct locations by creating a `~/.rpmmacros` file with the line:

    %_topdir &lt;path-to-repo&gt;/repo/rpmbuild

* __NOTE__ If packaging on CentOS 5 also add the macros `%dist .el5` and `%centos 5`. These are automatically defined in CentOS 5.
* Ensure that the source for the package is in the SOURCES directory (only `.patch` files are retained). You may have to read the SPEC file to see where to obtain this.
* Change to the SPEC directory and issue the command `rpmbuild -bb`
* Use the `bin/pushpkg` command to upload the package to the server. It will automatically rebuild the indices.
* You can then `yum install` the new version. You may need to do `yum clean all`

When creating new specfiles that have different structure depending on CentOS 5 or 6, use the following conditional macro structure:

        %if 0%{?centos} == 6
            Do CentOS 6 specific stuff
        %else
            Do CentOS 5 specific stuff
        %endif

#### RPM Package Names

To distinguish between packages such as ruby or openssh, which are simply repackages of existing ones, and truly custom stuff we will adopt the RPMforge convention of using a dot-delimited release qualifier for the former. So our repackaged builds will be 'el6.ip'. and custom packages will be 1ip.el6.

#### Building RPM Packages

Certain packages (such as, remarkably, *git*) have an EPEL version for CentOS 5 that is later than anything in CentOS 6. Since we would like to keep versions the same (as much as we can) for such important packages, we download the SRPM, tweak the SPECfile to contain an *.ip* release suffix and build our own RPMs. Note that the package release is dot-delimited to match they style of RPMforge and EPEL. If the *ip* was part of the release number that would signify that we actually changed something in the package.

## Using Kickstart to install CentOS 5 or 6

First download an image file to boot the OS for a networked install. These image files are available in the [downloads](/downloads/) directory for each supported OS:

* A [CentOS 5](/downloads/CentOS-5.9-x86_64-netinstall.iso) boot image (~15Mb). At the boot prompt type 

    linux ks=http://<%= cgi.server_name %>/ks/c5-vm.ks?host=&lt;enter desired fqdn&gt;

* A [CentOS 6](/downloads/CentOS-6.4-x86_64-netinstall.iso) boot image (~240Mb). At the boot prompt hit `tab` then *add* the following to the existing grub command

    ks=http://<%= cgi.server_name %>/ks/c6-vm.ks?host=&lt;enter desired fqdn&gt;

In both cases the desired FQDN (fully qualified domain name) can be an existing name or an mDNS name (ending in `.local`). If the name exists in the DNS system then the IP address will be configured, otherwise the network will use DHCP.

### Notes on VM types
* Prefixes indicate the CentOS version: `c6` for CentOS 6, and `c5` for CentOS 5
* Kickstart definitions suffixed with `-kvm` are for KVM based Virtual Machines
* Those suffixed with `-vm` are for VMware and include an installation of VMware tools
* The standard install is extremely bare - to include developer tools use the `-dev-` versions

## GEM Repository

We have created some of our own GEMS, so a GEM repository has been setup. To use this add the `source` option to your GEM installs:

    gem install --source http://<%= cgi.server_name %>/gem_repo <gem-name>

Or you can [download them directly](/gems) and install locally.

## YUM Repositories

We have created YUM repositories to contain all the required packages 'locally'. In order to use them you will need to create the file /etc/yum.repos.d/c-pod.repo with a named section for each one, as described below.

### Custom RPMs (Stable)
This is for the current production version of internally developed or modified packages.

    [stable]
    name=Custom RPMs for CentOS $releasever - $basearch
    baseurl=http://<%= cgi.server_name %>/yum_repos/custom/$releasever/stable/
    enabled=1
    gpgcheck=0

### Unstable Custom RPMs for Testing

When developing a new release of a custom RPM this repository is used. Because YUM repos do not readily support multiple versions we use the yum priorities package to prioritize this repo over the stable one on test machines.

    [unstable]
    name=Unstable Custom RPMs for CentOS $releasever - $basearch
    baseurl=http://<%= cgi.server_name %>/yum_repos/custom/$releasever/unstable/
    enabled=1
    gpgcheck=0

### RPMs lifted from other repositories

This repository contains RPMs normally found on other repositories, EPEL or RPM Forge for example. To avoid having to be connected to the Internet during installs these can be downloaded using `yumdownloader` and stored in this repository. It also contains packages that may not be customized or altered in any way, but are just built and deployed here. They are considered stable and are used as part of the base Kickstart builds.

    [lifted]
    name=Lifted RPMs for CentOS $releasever - $basearch
    baseurl=http://<%= cgi.server_name %>/yum_repos/lifted/$releasever/
    enabled=1
    gpgcheck=0

## CentOS Distribution Package Repositories

To save bandwidth and speed-up networked installs the Distribution repositories are available. In order to use them create the file `/etc/yum.repos.d/centosdvd.repo` with the following contents:
    [centos_repo]
    name=CentOS $releasever Linux Distribution DVD - x86_64
    baseurl=http://<%= cgi.server_name %>/osdisks/centos$releasever
    enabled=1
    gpgcheck=1
    gpgkey=http://<%= cgi.server_name %>/RPM-GPG-KEY-CentOS-$releasever

## Serving Chef Recipes

You can create your own Chef cookbooks under the [chef](/chef) subdirectory. When configured as a webserver these definitions are available using the `bin/recipes.cgi` URL - this downloads the entire tree as a _tgz_ file for use by the `recipe_url` parameter of `chef-solo`. By default the definitions are downloaded from the master branch. You can select any desired branch by adding a Git tree-ish as additional path information, eg:

    recipe_url      'http://<%= cgi.server_name %>/bin/recipes.cgi/production'

To use chef on a new machine, simply `gem install chef` (this takes a while - it is a big package!). Create the following configuration file [/etc/gemrc](/samples/gemrc) to search our local gem repository:

    gem: -N --clear-sources --source http://<%= cgi.server_name %>/gem_repo

Then create a configuration file [/etc/chef/solo.rb](/samples/solo.rb):

    file_cache_path '/var/chef/cache'
    cookbook_path   '/var/chef/cookbooks'
    # By default fetch recipes from the master (development) branch.
    # This should be changed to production on production machines.
    recipe_url      'http://<%= cgi.server_name %>/bin/recipes.cgi/master'
    json_attribs    '/etc/chef/runtime.json'

Then a simple JSON configuration file [/etc/chef/runtime.json](/samples/runtime.json):

    {
        "run_list": [ "recipe[c-pod::yum_repo_conf]", "recipe[c-pod::default]" ]
    }

Then run the command `chef-solo` which will (using the above defaults) configure the SEU runtime. To add your own recipes you can run a command like:

    chef-solo -o recipe[c-pod::townsen],recipe[c-pod::mediawiki]

Alternatively use a non-default JSON file with the `-f` option.

## Accessing via Proxy
The C-Pod configures a SOCKS5 Proxy via which you can get network access to the services.
### SSH Access
For the names that you wish to access, create entries in your local `.ssh/config` file as follows:

    Host nixvm*.local nvm*.local kvm*.local dvm*.local tvm*.local cvm*.local
    ProxyCommand /usr/bin/nc -X 5 -x <%= cgi.server_name %>:1080 %h %p

The `nc` command is standard under MacOS - you may need to install it if using another OS.

### Web Access

A Proxy Access File (or 'pac' file) has been created that will direct your browser to use the SOCKS proxy for `.local` requests. Enable this by configuring your browser proxy to use:

    http://<%= cgi.server_name %>/c-pod.pac

Safari, Firefox and Chrome have all be tested. Note that at time of writing Cisco AnyConnect VPN is incompatible with the native Mavericks proxy support. Use Firefox as a workaround.

# Notes

## Supported CentOS Versions

ONE point release of each major release of CentOS is supported at any given time.
Currently these are Centos 5.9 and Centos 6.4

## Naming Conventions for YUM repos

The names of the YUM repositories are standardized so that we can use the $releasever variable.
This enables us to have a single /etc/yum.repos.conf/custom.repo file that automatically
points to the correct place.

The repo names are of the form:

    OSNAME/$releasever/TYPE

Where:

* OSNAME is one of:
    * 'lifted': Lifted contains packages from Epel and RPMforge that we use
    * 'centos': A copy of the distributed packages
    * 'custom' is used for our custom packages
* $releasever is supplied by the OS: 6Server, 5Server (for RedHat), 5, 6 (for Centos) etc.
* TYPE is only used for the 'custom' packages:
    * 'stable': tested and 'in production'
    * 'unstable': under development/testing

## What to do when packages are missing

Neither EPEL nor RPMforge repos are automatically installed on the machines. This is to avoid dependency resolution just happening invisibly and pulling in unknown versions of new packages. All required packages (not shipped in the base or updates repos) should be in the _lifted_ repository for installs. If a package is not available, then activate either EPEL or RPMforge, download the required RPMs and place them in the _lifted_ repository. This is done as follows:

* `yum install epel-release rpmforge-release`
* `yumdownloader <packages>` to obtain local copies
* `/data/repo/bin/pushpkg -f -t lifted <packages>` which uploads them to the lifted repo
* disable the epel and rpmforge repositories by either `rpm -e epel-release rpmforge-release`, or edit the `/etc/yum.repos.d/{epel,rpmforge}.repo` files and set `enabled=0`
* `yum clean all` to install the new packages from _lifted_
* `yum install <packages>`  to install the new packages from _lifted_

## If the above gets tiresome

Edit the file `/etc/yum.conf` to set `keepcache=1`. Enable EPEL and RPMforge then `yum install` packages as you need. When complete upload all the packages from the cache directory (`/var/cache/yum`) to the _lifted_ repo using something like the following on CentOS 5:

    find /var/cache/yum/{epel,rpmforge} | xargs /data/repo/bin/pushpkg -t lifted -f 

or, for CentOS 6:

    find /var/cache/yum/x86_64/6/{epel,rpmforge} | xargs /data/repo/bin/pushpkg -t lifted -f 

## YUM Priorities

See [YUM Priorities](http://wiki.centos.org/PackageManagement/Yum/Priorities) for a description. In order to allow unstable packages to be deployed in preference to stable ones, even when the version is the same, we define them to have the highest priority (of 10). The stable ones are 20.

## Apache configuration

The following setup steps are automated in the script `bin/setup_repo` executed as part of the recipe:

* Apache configuration is done with the Apache configuration file template `c-pod.conf.erb` which
is processed by ERB to create the file `/etc/httpd/conf.d/_c-pod.conf`. The _DocumentRoot_ used is
determined by the current repository location
* Set the permissions of the tree to be owned by the Apache user: `chown -R apache.apache /data/c-pod`

## Keeping large binaries out!
<a id=binaries></a>
The large binary content required for OS installations are kept outside of the repository and accessed
via symbolic links. These links are coded to link to immediate peer directories of the main repo with 
the same name: eg. the `www/downloads` directory is linked to `../downloads` relative to the repo.
You can create these links,  mount the images and create the osdisks using the `bin/mk_osimages` command.

The Gem and Yum repository trees are also held outside the repo, and populated manually. In other words
you need to copy the `.rpm` and `.gem` files into the appropriate directory after building them and then
run the command `bin/rebuild_indexes`. The utility `bin/pushpkg` will do this using HTTP allowing you to push locally made packages directly to the (remote) C-Pod, automatically rebuilding the indexes.
