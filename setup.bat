netsh inter ipv4 delete dnsservers "本地连接" all
netsh inter ipv4 add dnsservers "本地连接" 208.67.222.222 index=1
netsh inter ipv4 add dnsservers "本地连接" 208.67.220.220 index=2
route delete 0.0.0.0/0 192.168.1.1