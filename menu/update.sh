#!/bin/bash
LocalVersion=$(cat /root/versi)
Version=$(curl -sS https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/main/versi | awk '{print $2}')
if [ $LocalVersion = $Version ]; then
echo -e "Script Sudah Versi Terbaru..." | lolcat
else
echo -e "Update tersedia!!";
wget -q -O updateyes.sh https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/main/updateyes.sh && chmod +x updateyes.sh && ./updateyes.sh
rm -f updateyes.sh
fi
