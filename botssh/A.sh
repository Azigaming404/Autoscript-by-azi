#!/bin/bash
COLOR1='\033[0;35m'
NC='\e[0m'
MYIP=$(wget -qO- ipinfo.io/ip);


domain=$(cat /etc/xray/domain)
clear
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
  echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
  echo -e "$COLOR1│${NC}             • CREATE VLESS USER •              ${NC} $COLOR1│$NC"
  echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
  echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"

  read -rp "User: " -e user
  CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

  if [[ ${CLIENT_EXISTS} == '1' ]]; then
    clear
    echo -e "\033[1;93m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[0;41;36m             VLESS ACCOUNT           \E[0m"
    echo -e "\033[1;93m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "A client with the specified name was already created, please choose another name."
    echo ""
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
  fi
done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")
sed -i '/#vless$/a\#& '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vlessgrpc$/a\#& '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json


vlesslink="vless://${uuid}@${domain}:443?path=/vless&security=tls&encryption=none&type=ws#${user}"
vlesslink1="vless://${uuid}@${domain}:80?path=%2Fvless&security=none&encryption=none&host=${domain}&type=ws&sni=bug#${user}"
vlesslink2="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${domain}#${user}"


systemctl restart xray
systemctl restart nginx

clear

echo -e "$COLOR1─────────────────────────────────────────────────${NC}" 
echo -e "    Xray/Vless Account     \E[0m"
echo -e "$COLOR1─────────────────────────────────────────────────${NC}" 
echo -e "Remarks     : ${user}"
echo -e "Domain      : ${domain}"
echo -e "port TLS    : 443"
echo -e "Port DNS    : 443"
echo -e "Port NTLS   : 80"
echo -e "User ID     : ${uuid}"
echo -e "Encryption  : none"
echo -e "Path TLS    : /vless "
echo -e "ServiceName : vless-grpc"
echo -e "$COLOR1─────────────────────────────────────────────────${NC}" 
echo -e "Link TLS    : ${vlesslink}"
echo -e "$COLOR1─────────────────────────────────────────────────${NC}" 
echo -e "Link NTLS   : ${vlesslink1}"
echo -e "$COLOR1─────────────────────────────────────────────────${NC}" 
echo -e "Link GRPC   : ${vlesslink2}"
echo -e "$COLOR1─────────────────────────────────────────────────${NC}" 
echo -e "Expired On : $exp"
echo -e "$COLOR1─────────────────────────────────────────────────${NC}" 
echo -e ""




curl -X POST "https://api.telegram.org/bot6148468890:AAFCcJwajKdLDz_Z-IR2czwuoBfIGQ4DExM/sendMessage" \
     -d "chat_id=$(cat /root/id)&text=$TEXT" >/dev/null


systemctl restart cybervpn 

read -n 1 -s -r -p "Press any key to back on menu"

menu

