#!/bin/bash -x
if [ "$1" = "run" ]; then
  CURRENTDIR=$(pwd)
    
  cd /etc/
  git clone https://github.com/OpenVPN/easy-rsa.git
  cd /etc/easy-rsa/easyrsa3
  ./easyrsa init-pki

  ./easyrsa \
    --batch \
    --dn-mode=org \
    --req-c=PT \
    --req-st=Azores \
    --req-city="Ponta Delgada" \
    --req-org="Entidade Certificadora Nacional" \
    --req-email=webmaster@entcert.pt \
    --req-ou="Departamento de Certificados" \
    --req-cn=www.entacert.pt \
    build-ca nopass

  ./easyrsa \
    --batch \
    --dn-mode=org \
    --req-c=PT \
    --req-st=Azores \
    --req-city="Ponta Delgada" \
    --req-org="ENTA - Escola de Novas Tecnologias" \
    --req-email=webmaster@enta.pt \
    --req-ou="Departamento de Informatica" \
    --req-cn="*.amazonaws.com" \
    --subject-alt-name="DNS:*.amazonaws.com" \
    build-server-full amazonaws.com nopass

  ./easyrsa \
    --batch \
    --dn-mode=org \
    --req-c=PT \
    --req-st=Azores \
    --req-city="Ponta Delgada" \
    --req-org="ENTA - Escola de Novas Tecnologias" \
    --req-email=webmaster@enta.pt \
    --req-ou="Departamento de Informatica" \
    --req-cn="*.amazonaws.com" \
    --subject-alt-name="DNS:*.amazonaws.com" \
    build-client-full client.amazonaws.com nopass

  ./easyrsa --passout=file:$PASSFILE export-p12 client.amazonaws.com

  cp pki/ca.crt "${CERTPATH}"/certs/
  cp pki/issued/amazonaws.com.crt "${CERTPATH}"/certs/
  cp pki/private/amazonaws.com.key "${CERTPATH}"/private/
  cp pki/issued/client.amazonaws.com.crt "${CERTPATH}"/certs/
  cp pki/private/ca.key "${CERTPATH}"/private/
  cp pki/private/client.amazonaws.com.key "${CERTPATH}"/private/

fi
