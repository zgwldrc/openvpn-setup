netsh inter ipv4 delete dnsservers %interface_index% all
netsh inter ipv4 add dnsservers %interface_index% %original_dns% index=1
route -p add 0.0.0.0/0 %original_gateway%
