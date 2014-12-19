# Setup the C-Pod repositories

# Set multilibs_policy to best

ex /etc/yum.conf <<YUMCONF
1
/\[main\]/a
multilib_policy=best
.
x
YUMCONF

# Disable the installed CentOS repositories by moving them out of the directory
# (Too complex to just set enabled=0 as some aren't explicit- they default to enabled)
# Note that these have to use IP address as yum won't resolve .local names

mkdir /root/saved.repos.d
mv /etc/yum.repos.d/CentOS*  /root/saved.repos.d/
curl -f http://<!--#echo var=SERVER_ADDR -->/samples/c-pod.repo -o /etc/yum.repos.d/c-pod.repo
