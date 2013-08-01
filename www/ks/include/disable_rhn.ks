# Disable RHN

ex /etc/yum/pluginconf.d/rhnplugin.conf <<RHN
%s/enabled\s*=\s*1/enabled = 0/
x
RHN
