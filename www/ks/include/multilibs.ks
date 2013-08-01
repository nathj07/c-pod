# Set multilibs_policy to best

ex /etc/yum.conf <<YUMCONF
1
/\[main\]/a
multilib_policy=best
.
x
YUMCONF
