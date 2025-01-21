#!/bin/bash
mkdir -p /etc/cybervpn/limit/vmess/ip/
mkdir -p /etc/cybervpn/limit/vless/ip/
mkdir -p /etc/cybervpn/limit/trojan/ip/
mkdir -p /etc/cybervpn/limit/ssh/ip/
mkdir -p /etc/cybervpn/limit/noobs/ip/

mkdir -p /etc/vmess
mkdir -p /etc/vless
mkdir -p /etc/trojan
mkdir -p /etc/limit/vmess
mkdir -p /etc/limit/vless
mkdir -p /etc/limit/trojan


set -e  # Hentikan skrip jika ada error

# Fungsi untuk mencetak pesan sukses
success_message() {
    echo -e "\e[32m[SUKSES]: $1\e[0m"
}

# Fungsi untuk mencetak pesan error
error_message() {
    echo -e "\e[31m[ERROR]: $1\e[0m"
    exit 1
}

# Periksa apakah skrip dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
    error_message "Skrip ini harus dijalankan sebagai root!"
fi

# Instalasi paket yang diperlukan
PACKAGES=("php" "php-curl" "python3" "python3-pip")
for package in "${PACKAGES[@]}"; do
    if ! dpkg -l | grep -q "^ii  $package "; then
        apt-get install -y "$package" && success_message "Paket $package berhasil diinstal."
    else
        success_message "Paket $package sudah terinstal."
    fi
done
wget https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/tes/ssh.py

chmod 777 ssh.py
# Instalasi Flask jika belum ada
if ! python3 -c "import flask" &>/dev/null; then
    pip3 install flask && success_message "Flask berhasil diinstal."
else
    success_message "Flask sudah terinstal."
fi


# Restart Apache
systemctl restart apache2 && success_message "Layanan Apache berhasil direstart."

# Set izin dan kepemilikan direktori

# Download file dan atur izin

   wget -q -O /usr/bin/addssh "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/tes/addssh"
   wget -q -O /usr/bin/vmess "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/tes/vmess"
   wget -q -O /usr/bin/trojan "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/tes/trojan"
   wget -q -O /etc/systemd/system/api-xray.service "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/tes/api-xray.service"
   wget -q -O /etc/systemd/system/api.service "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/api.service"
   wget -q -O /usr/bin/vless "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/tes/vless"
    


    

    
# Beri izin eksekusi untuk file di /usr/bin/
chmod +x /usr/bin/addssh
chmod +x /usr/bin/vmess 
chmod +x /usr/bin/trojan

# Reload dan aktifkan layanan API
systemctl daemon-reload
systemctl enable api.service
systemctl restart api.service && success_message "Layanan API berhasil diaktifkan dan direstart."
systemctl enable api-xray.service
systemctl restart api-xray.service && success_message "Layanan API berhasil diaktifkan dan direstart."



echo -e "\e[32m[SUKSES]: Proses selesai. Apache sekarang menggunakan port 8000 (HTTP) dan 8443 (HTTPS).\e[0m"
