#!/bin/bash

# More of documentation of installed modules than a script

#sudo pacman -S openvpn dnsutils easyrsa

# A section where I should probably copy files

sudo mkdir /etc/openvpn
sudo mkdir /etc/openvpn/client

sudo cp ./remote /etc/openvpn/remote
sudo cp ./gen-config.sh /etc/openvpn/gen-configs.sh
sudo cp ./cattlevpn /bin/cattlevpn
sudo /etc/openvpn/gen-configs.sh
