# openvpn-setup
利用Ubuntu1604自动化搭建openvpn

1. ./setup.sh
2. ./new_client.sh

## Personal Experimence
in windows 10, use following config to setup and restore dns and gateway  
bat files is under in windows_cli_only dir  
since the bat is called by openvpn,  
because the non-ascii char 's utf8 encoing cause problem,  
you should consider using notepad to edit the bat file and save as ascii endoing.  
```
script-security 2
route-up 'setup.bat'
down 'restore.bat'
```
