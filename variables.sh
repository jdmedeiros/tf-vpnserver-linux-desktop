#!/usr/bin/bash -x

if [ "$1" = "run" ];then
  LOGFILE="/var/log/cloud-config-detail"
  SCRIPT_LOG_DETAIL="${LOGFILE}"_$(basename "$0").log

  # Reference: https://serverfault.com/questions/103501/how-can-i-fully-log-all-bash-scripts-actions
  exec 3>&1 4>&2
  trap 'exec 2>&4 1>&3' 0 1 2 3
  exec 1>$SCRIPT_LOG_DETAIL 2>&1

  # If false then it will use Ubuntu
  DISTRO_EC2=${distro_ec2}

  # User and password for the Desktop GUI user - look at the logfile to find out the password and change it after
  USER=luxuser
  PASSWORD=$(xxd -l8 -ps /dev/urandom)

  # Create a temporary web server on port 8888 to allow download of the certificates and openvpn client configuration
  CERTSRV=true
  if [ "$DISTRO_EC2" = true ] ; then
    CERTPATH="/etc/pki/tls"
  else
    CERTPATH="/etc/ssl"
  fi
  CERTSRVPORT=8888

  # Protect the certificate with the same password
  PASSFILE="pk12password"
  PK12Password="${PASSWORD}"
  echo $PK12Password > $PASSFILE
  PASSFILE=$(pwd)/$PASSFILE
fi

