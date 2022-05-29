#!/bin/bash -x
source /var/lib/cloud/instance/scripts/variables.sh run
source /var/lib/cloud/instance/scripts/packages.sh run
source /var/lib/cloud/instance/scripts/certificates.sh run

cat <<'EOF' >> /etc/openvpn/server.conf

push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 1.1.1.1"
duplicate-cn
auth SHA512
tls-version-min 1.2
tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256
ncp-ciphers AES-256-GCM:AES-256-CBC
EOF

echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/10-ipv4_ip_forward.conf
sysctl -w net.ipv4.ip_forward=1

if [ "$CERTSRV" = "true" ]; then
  cp "${CERTPATH}"/certs/ca.crt /tmp/certs/ovpn/
  cp "${CERTPATH}"/certs/ca.crt /etc/openvpn/
  cp "${CERTPATH}"/certs/amazonaws.com.crt /etc/openvpn/server.crt
  cp "${CERTPATH}"/private/amazonaws.com.key /etc/openvpn/server.key
  cp "${CERTPATH}"/certs/client.amazonaws.com.crt /tmp/certs/ovpn/client.crt
  cp "${CERTPATH}"/private/client.amazonaws.com.key /tmp/certs/ovpn/client.key
fi

sed -i 's/^remote my-server-1/remote '$(curl -s curl http://169.254.169.254/latest/meta-data/public-ipv4)'/g' /tmp/certs/ovpn/client.conf
echo "auth SHA512" >> /tmp/certs/ovpn/client.conf

openvpn --genkey --secret /etc/openvpn/ta.key
cp /etc/openvpn/ta.key /tmp/certs/ovpn/
openssl dhparam -out /etc/openvpn/dh2048.pem 2048
systemctl enable --now openvpn@server
systemctl enable --now xrdp

if ! (id "$USER" &>/dev/null); then
  useradd -m -p $(openssl passwd -1 $PASSWORD) $USER
fi

tar cvzf /tmp/certs/ovpn.tgz /tmp/certs/ovpn
