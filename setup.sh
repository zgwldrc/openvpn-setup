CA_DIR=/etc/openvpn/ca
OVPN_PORT=4430
apt-get update && apt-get install openvpn easy-rsa
make-cadir $CA_DIR
cd $CA_DIR
# country code refers to https://www.countrycode.org/
cat >> vars <<-EOF
export KEY_COUNTRY="CN"
export KEY_PROVINCE="GuangDong"
export KEY_CITY="ShenZhen"
export KEY_ORG="ZGWLDRC"
export KEY_EMAIL="zgwldrc@163.com"
export KEY_OU="DEVOPS"
EOF

. vars && ./clean-all && ./pkitool --initca && \ 
  ./pkitool --server server && ./build-dh && openvpn --genkey --secret keys/ta.key  && \
  cd $KEY_DIR && cp ca.crt server.crt server.key ta.key dh2048.pem /etc/openvpn && \
  gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz | tee /etc/openvpn/server.conf && \
  sed -i -e "/^port/s/.*/port $OVPN_PORT/" \
      -e '/proto tcp/s/.*/proto tcp/'  \
      -e '/proto udp/s/.*/;proto udp/' \
      -re 's/^;(tls-auth.*)/\1/' \
      -e '/^tls-auth/a key-direction 0' \
      -e 's/^;(cipher AES-128-CBC.*)/\1/' \
      -e '/^cipher AES-128-CBC/a auth SHA256' \
      -e 's/^;(user.*|group.*)/\1/' \
      -e 's/^;(push.*(dhcp-option|redirect-gateway).*)/\1/' \
      /etc/openvpn/server.conf

# adjust linux core args to allow ip_forwading
sed -i -re 's/^#(net\.ipv4\.ip_forward.*)/\1/' /etc/sysctl.conf
sysctl -p


# adjust ufw rules to role a nat gateway
IF_OUT=`ip route | grep default| awk '{print \$5}'`
tmpfile=`mktemp`

cat > $tmpfile <<-EOM
# START OPENVPN RULES
# NAT table rules
*nat
:POSTROUTING ACCEPT [0:0] 
# Allow traffic from OpenVPN client to $IF_OUT (change to the interface you discovered!)
-A POSTROUTING -s 10.8.0.0/8 -o $IF_OUT -j MASQUERADE
COMMIT
# END OPENVPN RULES
EOM

sed -i "10 r $tmpfile
" /etc/ufw/before.rules
rm -f $tmpfile

ufw allow $OVPN_PORT/tcp
ufw allow OpenSSH
ufw disable && echo y|ufw enable
systemctl start openvpn@server && systemctl status openvpn@server && systemctl enable openvpn@server
