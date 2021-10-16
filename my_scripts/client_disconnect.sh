#!/bin/bash

function mail_input() {
  echo "To: $1"
  echo "From: ars-spamer@yandex.ru"
  echo "Subject: ovpn-down VPS"
  echo ""
  echo "DOWN $common_name OVPN $ifconfig_local REMOTE $ifconfig_pool_remote_ip FROM $untrusted_ip"
}

# /sbin/arp -i eth0 -d $ifconfig_pool_remote_ip

mail_input ars.anosov@gmail.com | /usr/bin/msmtp --file=/etc/openvpn/msmtp.conf ars.anosov@gmail.com
