# openvpn-setup
利用Ubuntu1604自动化搭建openvpn

1. ./setup.sh
2. ./new_client.sh

> don't ask why, just personal experimence: when you use windows 10 ,should add following pieces in your ovpn config file
```
script-security 2
route-up 'C:\\Windows\\System32\\ROUTE.EXE delete 0.0.0.0/0 192.168.1.1'
route-pre-down 'C:\\Windows\\System32\\ROUTE.EXE -p add 0.0.0.0/0 192.168.1.1'
```
