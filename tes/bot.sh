IP=$(echo $SSH_CLIENT | awk '{print $1}')
TMPFILE='/tmp/ipinfo-$DATE_EXEC.txt'
curl http://ipinfo.io/$IP -s -o $TMPFILE
ORG=$(cat $TMPFILE | jq '.org' | sed 's/"//g')
domain=$(cat /etc/xray/domain)
LocalVersion=$(cat /root/versi)
IPVPS=$(curl -s ipinfo.io/ip )
ISPVPS=$( curl -s ipinfo.io/org )
token=5922026926:6226368145:AAGaFLgpYKcH7JppfHptqyWowndyO_IENEU
chatid=1106186898
ttoday="$(vnstat | grep today | awk '{print $8" "substr ($9, 1, 3)}' | head -1)"
tmon="$(vnstat -m | grep `date +%G-%m` | awk '{print $8" "substr ($9, 1 ,3)}' | head -1)"
DATE_EXEC="$(date "+%d %b %Y %H:%M")"
CITY=$(cat $TMPFILE | jq '.city' | sed 's/"//g')
REGION=$(cat $TMPFILE | jq '.region' | sed 's/"//g')
COUNTRY=$(cat $TMPFILE | jq '.country' | sed 's/"//g')
curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" -d chat_id="$chatid" -d text="$IPVPS domain $domain telah install XrayCol pada $DATE_EXEC di $CITY, $REGION via $ORG" > /dev/null 2>&1
clear
