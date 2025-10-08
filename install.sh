#!/bin/bash

# More of documentation of installed modules than a script

sudo pacman -S openvpn dnsutils easyrsa

# A section where I should probably copy files

sudo mkdir /etc/openvpn
sudo mkdir /etc/openvpn/server
sudo mkdir /etc/openvpn/client

sudo cp ./routes.sh /etc/openvpn/server/routes.sh
sudo cp ./gen-config.sh /etc/openvpn/server/gen-config.sh