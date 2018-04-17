#!/bin/bash
set -e
CA_DIR=/etc/openvpn/ca
KEY_DIR=$CA_DIR/keys
OUT_DIR=/etc/openvpn/clients
mkdir -p $OUT_DIR
print_usage() {
    cat <<-EOM
Usage:
    $0 client_name
EOM
    exit 0
}

[ $# -eq 0 ] && print_usage

cwd=`pwd`

tmpdir=`mktemp -d -p ./ openvpn-client.XXX`


cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf $tmpdir/base.conf
server_ip=`curl -s ipecho.net/plain`
server_port=`grep '^port' /etc/openvpn/server.conf |awk '{print \$2}'`
sed -i -e "/proto udp/s/.*/;proto udp/" \
        -e '/proto tcp/s/.*/proto tcp/'  \
       -e "/^remote /s/.*/remote $server_ip $server_port/" \
       -re 's/^;(user.*|group.*)/\1/' \
       -e 's/^(ca.*|cert.*|key.*)/#\1/' \
       -e 's/^;cipher.*/cipher AES-128-CBC/' \
       -e '/^cipher AES-128-CBC/a auth SHA256' \
       -e 's/^;(tls-auth.*)/\1/' \
       -e '/^tls-auth/a key-direction 1' \
       $tmpdir/base.conf

cd $CA_DIR
. vars && ./pkitool $1

cd $cwd
cat $tmpdir/base.conf \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${1}.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    > $OUT_DIR/${1}.ovpn
rm -rf $tmpdir
cd $OUT_DIR && ls


