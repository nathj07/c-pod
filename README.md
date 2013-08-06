Repo Repository
===============

This GIT repository contains custom RPM and Gem packages and the repository structure
(both YUM and RubyGems) to distribute them. It also serves as a Kickstart server for
rapid OS installs. PXE boot support is incomplete.

Overview
--------

The repo is designed to be used in two ways:
* As a webserver to provide the repositories and the kickstart definitions. This needs
a lot of binaries (OS distribution images, binary RPMs etc.)
* As a place to develop and test new packages. This needs just the SPEC and SOURCE files
to build.

Subdirectories
--------------
The subdirectories are:

* `bin`: containing utilities
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

In order to run this repo as a webserver you will need to check it out in a location accessible to the Apache user and group. 

Required Packages
-----------------
With `yum install`:

    httpd
    createrepo
    ruby

With `gem install`:

    builder

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
You can create these links and mount the images using the `bin/setup` command.

The Gem and Yum repository trees are held outside the repo, and populated manually. In other words
you need to copy the `.rpm` and `.gem` files into the appropriate directory after building them and then
run the command `bin/rebuild_indexes`.

Use for Build
=============
The Gem and RPM build trees are held within the repo and have `.gitignore` files to exclude the
built binaries and packaging by-products.
This means that the repo can easily be cloned onto an empty VM so that the packaging takes place in a 'pure' environment, highlighting any packaging or runtime dependencies.

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

    %_topdir <path-to-repo>/repo/rpmbuild

* Ensure that the source for the package is in the SOURCES directory (only `.patch` files are retained). You may have to read the SPEC file to see where to obtain this.
* Change to the SPEC directory and issue the command `rpmbuild -ba`

Notes
=====

Supported CentOS Versions
-------------------------

ONE point release of each Major Release of CentOS is supported at any given time
Currently we have Centos 5.9 and Centos 6.4

Naming Conventions for YUM repos
--------------------------------

The names of the YUM repositories are standardized so that we can use the $releasever variable.
This enables us to have a single /etc/yum.repos.conf/custom.repo file that automatically
points to the correct place.

The repo names are of the form:

    OSNAME/$releasever/TYPE

Where:

* OSNAME is one of:
    * 'epel', 'centos'. Epel is a partial copy of epel for the packages we require
    * 'custom' is used for our custom packages
    * $releasever is supplied by the OS - 6Server, 5Server (for RedHat), 5, 6 (for Centos) etc.
* TYPE is:
    * For the 'custom' packages we have 'stable' and 'unstable', corresponding to the environment.
