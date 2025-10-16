#!/bin/bash
# A script to generate certificates for OpenVPN server
# Requires Easy-RSA

# Nuke and pave any old certs
rm -r /etc/openvpn/ca
mkdir -p /etc/openvpn/ca
cd /etc/openvpn/ca
export EASYRSA=/etc/openvpn/ca

# Generate the certificate authority cert
easyrsa --batch init-pki
easyrsa --batch build-ca nopass

# Generate server cert
easyrsa --batch gen-req server nopass
easyrsa --batch sign-req server server

# Generate client certs
easyrsa --batch gen-req client nopass
easyrsa --batch sign-req client client

# Generate some Diffie-Helman keys (hope I spelled that right)
easyrsa --batch gen-dh 

# Make the certs accessible
sudo chmod -R go+rx /etc/openvpn/ca/pki

# Create server config
serverPath=/etc/openvpn/ca/server.conf
echo "port 1194" > ${serverPath}
echo "proto udp" >> ${serverPath}
echo "dev tun" >> ${serverPath}
echo "server 172.16.0.0 255.255.255.0" >> ${serverPath}
echo "persist-key" >> ${serverPath}
echo "persist-tun" >> ${serverPath}
echo "user nobody" >> ${serverPath}
echo "group nogroup" >> ${serverPath}
echo "verb 3" >> ${serverPath}
echo "status /var/log/openvpn-status.log" >> ${serverPath}
echo "log-append /var/log/openvpn.log" >> ${serverPath}
echo "include /etc/openvpn/server/routes.conf" >> ${serverPath}
echo "<ca>" >> ${serverPath}
cat ./pki/ca.crt >> ${serverPath}
echo -e "</ca>\n<cert>" >> ${serverPath}
cat ./pki/issued/server.crt >> ${serverPath}
echo -e "</cert>\n<key>" >> ${serverPath}
cat ./pki/private/server.key >> ${serverPath}
echo -e "</key>\n<dh>" >> ${serverPath}
cat ./pki/dh.pem >> ${serverPath}
echo "</dh>" >> ${serverPath}

# Create setup script
mkdir -p /etc/openvpn/remote
cat /etc/openvpn/remote/routes.sh > /etc/openvpn/remote/setup.sh
cat ${serverPath} | sed -r 's/^.+$/echo \"&\" >> \/etc\/openvpn\/server.conf/g' >> /etc/openvpn/remote/setup.sh
echo "openvpn /etc/openvpn/server/server.conf" >> /etc/openvpn/remote/setup.sh

# Create client config
clientPath=/etc/openvpn/client/client.ovpn
echo "client" > ${clientPath}
echo "dev tun" >> ${clientPath}
echo "proto udp" >> ${clientPath}
echo "nobind" >> ${clientPath}
echo "resolv-retry infinite" >> ${clientPath}
echo "persist-key" >> ${clientPath}
echo "persist-tun" >> ${clientPath}
echo "verb 3" >> ${clientPath}
echo "dhcp-option DNS 1.1.1.1" >> ${clientPath}
echo "dhcp-option DNS 8.8.8.8" >> ${clientPath}
echo "<ca>" >> ${clientPath}
cat ./pki/ca.crt >> ${clientPath}
echo -e "</ca>\n<cert>" >> ${clientPath}
cat ./pki/issued/client.crt >> ${clientPath}
echo -e "</cert>\n<key>" >> ${clientPath}
cat ./pki/private/client.key >> ${clientPath}
echo "</key>" >> ${clientPath}
