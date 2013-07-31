Repository for Systems Team
===========================

This GIT repository contains all the required packages for our software as well
as the repository structure (both YUM and RubyGems) to distribute them.
It also serves as a Pixieboot (incomplete) and Kickstart server for rapid OS installs.

The subdirectories are:

* bin: containing utilities
* collateral: containing useful extra stuff
* gemrepo: containing the actual Gem repository
* gembuild: a place to store Gems to build
* rpmbuild: a place to store RPM builds
* www: The DocRoot of an Apache tree for all the artifacts:
** downloads: Useful downloads
** repos: YUM Repositories
** dvds: links to the mounted DVD image
** gem_repo: Gem Repository
** gems: The raw gemfiles
** ks: Kickstart scripts

Most of the configuration is done with the Apache configuration file repo.conf which is symlinked into
the /etc/httpd/conf.d/ directory as the file _repo.conf. All the layout assumes that this repo is cloned at the
location /data/repo

Notes
-----

1. Document root is /data/repo/www
This provides more control over what is accessible - executable scripts are now not 

2. ISO images are outside the source tree in their own subdirectory: /data/isoimages
These are mounted (by /etc/fstab) to /mnt/osimages where Apache can serve them from.

3. Only ONE point release of each Major Release of an OS is supported at any given time
Currently we have Centos 5.9 and Centos 6.3

Naming Conventions for YUM repos
--------------------------------
	
The names of the YUM repositories are standardized so that we can use the $releasever variable.
This enables us to have a single /etc/yum.repos.conf/sye.repo file that automatically
points to the correct place.

The repo names are of the form:

OSNAME/$releasever/TYPE

Where:

* OSNAME is one of:
** 'rhel', 'centos', 'fedora' etc.  (We only use centos right now)
** 'sye' is used for our custom packages
* $releasever is supplied by the OS - 6Server, 5Server (for RedHat), 5, 6 (for Centos) etc.
* TYPE is:
** 'dvd' for the whole DVD, 'repo' for the original packages, 'updates' for updates. Note 
the last two are not implemented - you can just go out to the web.
** For the 'sye' packages we have 'stable' and 'unstable', corresponding to the environment.
