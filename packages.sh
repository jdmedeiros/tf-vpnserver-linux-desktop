#!/bin/bash -x
if [ "$1" = "run" ]; then
  SCRIPT_LOG_DETAIL="${LOGFILE}"_$(basename "$0").log

  # Reference: https://serverfault.com/questions/103501/how-can-i-fully-log-all-bash-scripts-actions
  exec 3>&1 4>&2
  trap 'exec 2>&4 1>&3' 0 1 2 3
  exec 1>"$SCRIPT_LOG_DETAIL" 2>&1

  if [ "$CERTSRV" = "true" ]; then
    mkdir -p /tmp/certs/ovpn
    chmod -R +r /tmp/certs/
    cd /tmp/certs/
    nohup python3 -m http.server $CERTSRVPORT  >/dev/null 2>&1 &
  fi

  if [ "$DISTRO_EC2" = true ] ; then
    yum clean metadata
    yum -y update
    amazon-linux-extras install epel -y
    yum-config-manager --enable epel
    yum group install -y "Development Tools" "MATE Desktop"
    yum install -y openvpn easy-rsa xrdp chromium filezilla gkrellm
    amazon-linux-extras install -y libreoffice
    bash -c 'echo PREFERRED=/usr/bin/mate-session > /etc/sysconfig/desktop'
    cp /usr/share/doc/$(ls /usr/share/doc/ |grep '^openvpn')/sample/sample-config-files/server.conf /etc/openvpn
    cp /usr/share/doc/$(ls /usr/share/doc/ |grep '^openvpn')/sample/sample-config-files/client.conf /tmp/certs/ovpn/

    # Do not indent the following block
cat <<'EOF' > /etc/firewalld/services/rdp.xml
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>SSH</short>
  <description>Remote Desktop Protocol (RDP) is a proprietary protocol developed by Microsoft which provides a user with a graphical interface to connect to another computer.</description>
  <port protocol="tcp" port="3389"/>
</service>
EOF

    systemctl enable --now firewalld
    firewall-cmd --permanent --add-masquerade
    firewall-cmd --permanent --add-service=rdp
    firewall-cmd --permanent --add-service=openvpn
    firewall-cmd --reload
    firewall-cmd --add-port=8888/tcp
  else
    # Debconf needs to be told to accept that user interaction is not desired
    export DEBIAN_FRONTEND=noninteractive
    export DEBCONF_NONINTERACTIVE_SEEN=true
    apt-get -o DPkg::Options::=--force-confdef update
    apt-get -o DPkg::Options::=--force-confdef upgrade
    apt-get -o DPkg::Options::=--force-confdef dist-upgrade
    apt-get -o DPkg::Options::=--force-confdef install -y build-essential netfilter-persistent iptables-persistent ubuntu-desktop chromium-browser filezilla libreoffice openvpn easy-rsa xrdp gkrellm
    adduser xrdp ssl-cert
    cp /usr/share/doc/$(ls /usr/share/doc/ |grep '^openvpn')/examples/sample-config-files/server.conf /etc/openvpn
    cp /usr/share/doc/$(ls /usr/share/doc/ |grep '^openvpn')/examples/sample-config-files/client.conf /tmp/certs/ovpn/
    iptables -t nat -A POSTROUTING -o $(basename /sys/class/net/en*) -j MASQUERADE
    netfilter-persistent save
  fi
fi
