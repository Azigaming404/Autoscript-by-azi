#!/bin/bash
echo -e cheking update
sleep 2
#hapus
rm -f /usr/bin/setting
rm -f /usr/bin/menu
rm -f /usr/bin/usernew
rm -f /usr/bin/menu-vless
#download
wget -q -O /usr/bin/menu "http://update-path.cybervpn.site:81/Autoscript-by-azi-main/menu.sh" && chmod +x /usr/bin/menu
wget -q -O /usr/bin/setting "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/main/Themes/setting.sh"
wget -q -O /usr/bin/usernew "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/main/menu/usernew.sh"
wget -q -O /usr/bin/menu-vless "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/main/tes/menu-vless.sh"
echo "*/3 * * * * root bot" >> /etc/crontab
#izin
chmod 777 /usr/bin/usernew
chmod 777 /usr/bin/menu
chmod 777 /usr/bin/setting
chmod 777 /usr/bin/menu-vless
rm -rf updateyes.sh
menu
