# The repositories used during Kickstart
# Note that these are not persisted after installation,
# for that use the Chef recipe "ip::yum_repo_conf"

repo  --name=custom --baseurl="http://<!--#echo var=SERVER_ADDR -->/yum_repos/custom/5/stable/"
repo  --name=lifted --baseurl="http://<!--#echo var=SERVER_ADDR -->/yum_repos/lifted/5/"
