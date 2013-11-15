Notes on RPM Building
=====================

Go
--
Google do not seem to provide an RPM package. We grabbed one from:

    ftp://rpmfind.net/linux/fedora/linux/development/rawhide/source/SRPMS/g/golang-1.1.2-3.fc21.src.rpm

Go also uses the Plan9 shell (!!) for some scripts - these have extension `.rc` Since this is not available in any standard distribution we packaged it ourselves from the website:

    http://tobold.org/article/rc

Also a specfile exists at: https://github.com/thecubic/golang-rpm/blob/master/golang.spec - looked ok but we did not use it.


Go Libraries
------------

We decided to use Chef to install these. RPM packaging is possible but too complex right now.
