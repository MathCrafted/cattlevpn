#!/bin/bash
# A script to generate certificates for OpenVPN server
# Requires Easy-RSA

# Configure serverCount based on first positional parameter
if [[ $1 -gt 0 ]]; then
   serverCount=$1
else
   serverCount=2
fi

# Configure clientCount based on second positional parameter
if [[ $2 -gt 0 ]]; then
   clientCount=$2
else
   clientCount=2
fi

# Nuke and pave any old certs
rm -r /etc/openvpn/server/ca
make-cadir /etc/openvpn/server/ca
cd /etc/openvpn/server/ca

# Generate the certificate authority cert
./easyrsa init-pki
./easyrsa build-ca nopass

# Generate server cert
for (( i=1; i<=${serverCount}; i++))
do
   ./easyrsa gen-req server nopass
   ./easyrsa sign-req server server
done

# Generate client certs
for (( i=1; i<=${clientCount} ; i++ ));
do
   ./easyrsa gen-req client${i} nopass
   ./easyrsa sign-req client client${i}
done

# Generate some Diffie-Helman keys (hope I spelled that right)
./easyrsa gen-dh

# Create server config
for (( i=1 ; i<=${serverCount} ; i++ ));
do
   serverPath=/etc/openvpn/server/server${i}.conf
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
   echo "</ca>\n<cert>" >> ${serverPath}
   cat ./pki/issued/client${i}.crt >> ${serverPath}
   echo "</cert>\n<key>" >> ${serverPath}
   cat ./pki/private/client${i}.key >> ${serverPath}
   echo "</key>\n<dh>" >> ${serverPath}
   cat ./pki/dh.pem >> ${serverPath}
   echo "</dh>" >> ${serverPath}
done

# Create client config
for (( i=1 ; i<=${clientCount} ; i++ ));
do
   clientPath=/etc/openvpn/client/client${i}.ovpn
   echo "client" > ${clientPath}
   echo "dev tun" >> ${clientPath}
   echo "proto udp" >> ${clientPath}
   echo "nobind" >> ${clientPath}
   echo "resolv-retry infinite" >> ${clientPath}
   echo "persist-key" >> ${clientPath}
   echo "persist-tun" >> ${clientPath}
   echo "verb 3" >> ${clientPath}
   echo "dhcp-options DNS 1.1.1.1" >> ${clientPath}
   echo "dhcp-options DNS 8.8.8.8" >> ${clientPath}
   echo "<ca>" >> ${clientPath}
   cat ./pki/ca.crt >> ${clientPath}
   echo "</ca>\n<cert>" >> ${clientPath}
   cat ./pki/issued/client${i}.crt >> ${clientPath}
   echo "</cert>\n<key>" >> ${clientPath}
   cat ./pki/private/client${i}.key >> ${clientPath}
   echo "</key>" >> ${clientPath}
done
