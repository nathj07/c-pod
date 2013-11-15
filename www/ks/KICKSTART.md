# Using Kickstart

You can use kickstart to build a VM very quickly by downloading a network boot image appropriate to the release of CentOS you want to install. Attach it as a CDrom ISO image to your Virtual Machine and boot off it. You then start an unattended network install by typing the following line at the `boot:` prompt:

    linux ks=http://<%= q.server_name %>/ks/<file>.ks

Where `<file>` is the name of the machine type you want to create. This will remote boot and install a bare system, with Ruby, Chef and Git installed.

The files are kickstart configurations for various types of machines.

## References

* All of the predefined kickstart definitions are available [here](/ks)
* In order to make it easier to create kickstart configurations you can use server-side includes. These have been enabled for files with an extension of 'ks'. Kickstart definitions can now include standard components using the syntax:

    &lt;!--#include virtual="include/opts_std.ks" --&gt;

* This is recursive!
* Refer to the [Kickstart Options Ref](https://access.redhat.com/site/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/s1-kickstart2-options.html) for CentOS 6
