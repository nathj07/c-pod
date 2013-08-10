Repo Repository
===============

This GIT repository contains custom RPM and Gem packages and the repository structure
(both YUM and RubyGems) to distribute them. It also serves as a Kickstart server for
rapid OS installs. PXE boot support is incomplete.
It also stores Chef recipes and node definitions which it can serve up via the web
for use with `chef-solo`. This is very useful if you want to use Chef without the 
complexity of the chef-server and knife stuff.

Overview
--------

The repo is designed to be used in two ways:

* As a webserver to provide the repositories and the Kickstart and Chef definitions. This needs
a lot of binaries (OS distribution images, binary RPMs, GEMs etc.)
* As a place to develop and test new packages: 
    * For RPMs this needs just the SPEC and SOURCE files to build.
    * For GEMs
    * For Chef definitions

Subdirectories
--------------
The subdirectories are:

* `bin`: containing utilities both command line and CGI scripts
* `chef`: contains the cookbooks
* `collateral`: containing useful extra stuff
* `gembuild`: directory containing custom Gems
* `rpmbuild`: directory structure containing custom RPMs
* `www`: The DocRoot of an Apache tree
    * `downloads`: links to the downloads directory
    * `gem_repo`: links to the Gem Repository
    * `gems`: links to the raw Gem packages
    * `isos`: links to the OS distribution images
    * `ks`: Kickstart scripts
    * `osdisks`: links to the mounted DVD images
    * `yum_repos`: YUM Repositories

Use as Webserver
================

(It will shortly be possible to create this configuration using the 'repo' system itself.)

In order to run this repo as a webserver you will need to check it out in a location accessible to the Apache user and group. 

Required Packages
-----------------
With `yum install`:

    httpd
    createrepo
    ruby

With `gem install`:

    builder
    redcarpet

Installation
------------
The following setup steps are automated in the script `bin/setup_repo`

* Apache configuration is done with the Apache configuration file template `repo.conf.erb` which
is processed by ERB to create the file `/etc/httpd/conf.d/_repo.conf`. The DocumentRoot used is 
determined relative to the current repo location
* Set the permissions of the tree to be owned by the Apache user: `chown -R apache.apache /data/repo`

The large binary content required for OS installations are kept outside of the repository and accessed
via symbolic links. These links are coded to link to immediate peer directories of the main repo with 
the same name: eg. the `www/downloads` directory is linked to `../downloads` relative to the repo.
You can create these links,  mount the images and create the osdisks using the `bin/mk_osimages` command.

The Gem and Yum repository trees are held outside the repo, and populated manually. In other words
you need to copy the `.rpm` and `.gem` files into the appropriate directory after building them and then
run the command `bin/rebuild_indexes`. Note that the utility `bin/pushpkgs` will do this for custom RPMs.

Increase the number of loopback devices
---------------------------------------

[Note - this did not seem to work on CentOS 6.4 - tbi]

Create the file `/etc/modprobe.d/loops.conf` with the line:
    options loop max_loop=32

Use for Build
=============
Clone the repo and develop and test the packages on your 'home' machine. When they are ready and have been tested locally, commit the changes and spin up an empty VM. Then try the packaging again, so that it takes place in a 'pure' environment, highlighting any packaging or runtime dependencies.

To avoid storing build artifacts in the repo (despite the fact that the Gem and RPM build trees are held within it), there are `.gitignore` files that exclude the built binaries and packaging by-products.

How to build a GEM
------------------
* Change to the subdirectory containing the gem.
* Issue the command `gem build <gemname>.gemspec`
* Copy the `.gem` file into the directory `../gem_repo/gems`
* Run `rebuild_indexes`

How to build an RPM
-------------------

* Make sure that the package `rpm-build` is installed
* Establish the correct locations by creating a `~/.rpmmacros` file with the line:

    %_topdir &lt;path-to-repo&gt;/repo/rpmbuild

* __NOTE__ If packaging on CentOS 5 also add the macros `%dist .el5` and `%rhel 5`
* Ensure that the source for the package is in the SOURCES directory (only `.patch` files are retained). You may have to read the SPEC file to see where to obtain this.
* Change to the SPEC directory and issue the command `rpmbuild -bb`
* Use the `bin/pushpkgs` command to upload the package to the server. It will automatically rebuild the indices.
* You can then `yum install` the new version. You may need to do `yum clean all`

Chef
====
You can create your own Chef cookbooks under the `chef` tree. When configured as a webserver these definitions are available using the `bin/recipes.cgi` URL - this downloads the entire tree as a _tgz_ file for use by the `recipe_url` parameter of `chef-solo`.

To use chef on a new machine, simply `gem install chef` (this takes a while - it is a big package!) and create a configuration file `solo.rb`:

    root = File.absolute_path(File.dirname(__FILE__))
    file_cache_path root + '/cache'
    cookbook_path root + '/cookbooks'
    recipe_url "http://<repo webserver address>/bin/recipes.cgi"

Then a simple JSON configuration file `solo.json`:

    {
	"run_list": [ "recipe[ip::default]" ]
    }

I plan to use a similar concept to make JSON configurations for particular nodes available in future

Notes
=====

Supported CentOS Versions
-------------------------

ONE point release of each major release of CentOS is supported at any given time.
Currently these are Centos 5.9 and Centos 6.4

Naming Conventions for YUM repos
--------------------------------

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

YUM Priorities
--------------
We use them. See: http://wiki.centos.org/PackageManagement/Yum/Priorities for a description.
