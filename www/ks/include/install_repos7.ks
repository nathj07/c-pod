# The YUM repositories used during Kickstart

repo --name=lifted --baseurl=http://<!--#echo var=SERVER_ADDR -->/yum_repos/lifted/7/
repo --name=base --baseurl=http://<!--#echo var=SERVER_ADDR -->/osmirror/centos/7/os/x86_64/
repo --name=updates --baseurl=http://<!--#echo var=SERVER_ADDR -->/osmirror/centos/7/updates/x86_64/
