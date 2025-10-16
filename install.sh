#!/bin/bash

# More of documentation of installed modules than a script

#sudo pacman -S openvpn dnsutils easy-rsa

# A section where I should probably copy files

sudo mkdir -p /etc/openvpn
sudo mkdir -p /etc/openvpn/client
sudo mkdir -p /etc/openvpn/server
sudo mkdir -p /etc/openvpn/remote

sudo cp ./remote/routes.sh /etc/openvpn/remote/routes.sh
sudo cp ./gen-configs.sh /etc/openvpn/gen-configs.sh
sudo cp ./cattlevpn /bin/cattlevpn
sudo /etc/openvpn/gen-configs.sh
