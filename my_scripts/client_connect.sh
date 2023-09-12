#!/bin/bash

function mail_input() {
  echo "To: $1"
  echo "From: ars-spamer@yandex.ru"
  echo "Subject: ovpn-up VPS"
  echo ""
  echo "UP $common_name OVPN $ifconfig_local REMOTE $ifconfig_pool_remote_ip FROM $untrusted_ip"
}

# /sbin/arp -i eth0 -Ds $ifconfig_pool_remote_ip eth0 pub

# mail_input ars.anosov@gmail.com | /usr/bin/msmtp --file=/etc/openvpn/msmtp.conf ars.anosov@gmail.com
