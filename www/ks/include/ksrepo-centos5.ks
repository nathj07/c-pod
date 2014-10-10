# The repositories used during Kickstart
# Note that these are not persisted after installation,
# for that use the Chef recipe "ip::yum_repo_conf"

repo  --name=stable --baseurl="http://<!--#echo var=SERVER_ADDR -->/yum_repos/stable/5/"
repo  --name=lifted --baseurl="http://<!--#echo var=SERVER_ADDR -->/yum_repos/lifted/5/"
