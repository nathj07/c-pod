# Setup VMware tools

cd /root
curl -f http://<!--#echo var=SERVER_ADDR -->/downloads/VMwareTools.tgz -o vmw.tgz
tar xzvf vmw.tgz
rm vmw.tgz
cd vmware-tools-distrib
./vmware-install.pl --default
