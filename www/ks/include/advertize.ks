# Advertize SSH to make it easy to connect
# Note that as of CentOS 6.5 this is supplied by default

cat > /etc/avahi/services/ssh.service <<SERVICE
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<!-- See avahi.service(5) for more information about this configuration file -->

<service-group>
  <name replace-wildcards="yes">SSH on %h</name>
  <service>
    <type>_ssh._tcp</type>
    <port>22</port>
  </service>
</service-group>
SERVICE
