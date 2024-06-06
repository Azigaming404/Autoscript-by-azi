#!/bin/bash
# Script  By CyberVPN
# 2023 SLOWDNS
# ===============================================
sudo apt install squid -y
mkdir /var/lib/ssnvpn-pro/
rm -f /usr/bin/menu-ssh

hosting=$(curl -sS https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/main/domain)
wget -q -O /var/lib/ssnvpn-pro/ipvps.conf "https://$hosting/Autoscript-by-azi-main/ipvps.conf"
wger -q -O /usr/bin/tendang "https://$hosting/Autoscript-by-azi-main/limit/tendang.sh"
#wget -q -O /usr/bin/autokill "https://$hosting/Autoscript-by-azi-main/limit/autokill.sh"
wget -q -O /usr/bin/menu-ssh "https://$hosting/Autoscript-by-azi-main/menu-ssh.sh"
wget -q -O /usr/bin/restart "https://$hosting/Autoscript-by-azi-main/menu/restart.sh"
chmod +x /usr/bin/restart
wget -q -O /usr/bin/bot "https://$hosting/Autoscript-by-azi-main/Finaleuy/bot.sh"
wget -q -O /root/chat "https://$hosting/Autoscript-by-azi-main/Finaleuy/chatid.sh"
chmod 777 /root/chat
chmod 777 /usr/bin/bot

chmod +x /usr/bin/tendang
chmod +x /usr/bin/autokill
chmod +x /usr/bin/menu-ssh
#setting IPtables
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
netfilter-persistent save
netfilter-persistent reload



#delete directory
rm -rf /root/nsdomain
rm nsdomain

#input nameserver manual to cloudflare

clear
figlet "slowdns" | lolcat
read -rp "Masukkan Nameserver: " -e sub
SUB_DOMAIN=${sub}
NS_DOMAIN=${SUB_DOMAIN}
echo $NS_DOMAIN > /root/nsdomain

nameserver=$(cat /root/nsdomain)
apt update -y
apt install -y python3 python3-dnslib net-tools
apt install dnsutils -y
#apt install golang -y
apt install git -y
apt install curl -y
apt install wget -y
apt install screen -y
apt install cron -y
apt install iptables -y
apt install -y git screen whois dropbear wget
#apt install -y pwgen python php jq curl
apt install -y sudo gnutls-bin
#apt install -y mlocate dh-make libaudit-dev build-essential
apt install -y dos2unix debconf-utils
service cron reload
service cron restart




#konfigurasi slowdns
rm -rf /etc/slowdns
mkdir -m 777 /etc/slowdns
wget -q -O /etc/slowdns/server.key "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/main/slowdns/server.key"
wget -q -O /etc/slowdns/server.pub "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/main/slowdns/server.pub"
wget -q -O /etc/slowdns/sldns-server "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/main/slowdns/sldns-server"
wget -q -O /etc/slowdns/sldns-client "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/main/slowdns/sldns-client"
cd
chmod +x /etc/slowdns/server.key
chmod +x /etc/slowdns/server.pub
chmod +x /etc/slowdns/sldns-server
chmod +x /etc/slowdns/sldns-client

cd
#wget -q -O /etc/systemd/system/client-sldns.service "http://sgpx.cybervpn.site:81/Autoscript-by-azi-main/SLDNS/client-sldns.service"
#wget -q -O /etc/systemd/system/server-sldns.service "http://sgpx.cybervpn.site:81/Autoscript-by-azi-main/SLDNS/server-sldns.service"

cd
#install client-sldns.service
cat > /etc/systemd/system/client-sldns.service << END
[Unit]
Description=Client SlowDNS By CyberVPN
Documentation=https://www.xnxx.com
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/etc/slowdns/sldns-client -udp 8.8.8.8:53 --pubkey-file /etc/slowdns/server.pub $nameserver 127.0.0.1:58080
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

cd
#install server-sldns.service
cat > /etc/systemd/system/server-sldns.service << END
[Unit]
Description=Server SlowDNS By Cybervpn
Documentation=https://xhamster.com
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/etc/slowdns/sldns-server -udp :5300 -privkey-file /etc/slowdns/server.key $nameserver 127.0.0.1:22
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

#permission service slowdns
cd
chmod +x /etc/systemd/system/client-sldns.service

chmod +x /etc/systemd/system/server-sldns.service
pkill sldns-server
pkill sldns-client

systemctl daemon-reload
systemctl stop client-sldns
systemctl stop server-sldns

systemctl enable client-sldns
systemctl enable server-sldns

systemctl start client-sldns
systemctl start server-sldns

systemctl restart client-sldns
systemctl restart server-sldns
