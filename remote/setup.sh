#!/bin/bash

sudo apt install dnsutils openvpn
mkdir -p /etc/openvpn/server
echo "" > /etc/openvpn/server/routes.conf
nslookup youtube.com | grep -E "Address: ([[:digit:]]){1,3}\." | grep -Eo "([[:digit:]]){1,3}\.([[:digit:]]){1,3}\.([[:digit:]]){1,3}\.([[:digit:]]){1,3}" | sed -e 's/^/push "route /' | sed -e 's/$/"/' >> /etc/openvpn/server/routes.conf
