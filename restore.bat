netsh inter ipv4 delete dnsservers "��������" all
netsh inter ipv4 add dnsservers "��������" 192.168.1.234 index=1
route -p add 0.0.0.0/0 192.168.1.1
