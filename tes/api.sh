#!/bin/bash
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
PACKAGES=("php" "php-curl" "python3" "python3-pip" "apache2")
for package in "${PACKAGES[@]}"; do
    if ! dpkg -l | grep -q "^ii  $package "; then
        apt-get install -y "$package" && success_message "Paket $package berhasil diinstal."
    else
        success_message "Paket $package sudah terinstal."
    fi
done

# Instalasi Flask jika belum ada
if ! python3 -c "import flask" &>/dev/null; then
    pip3 install flask && success_message "Flask berhasil diinstal."
else
    success_message "Flask sudah terinstal."
fi

# Path konfigurasi Apache
APACHE_CONF="/etc/apache2/ports.conf"
APACHE_SSL_CONF="/etc/apache2/sites-available/default-ssl.conf"

# Periksa file konfigurasi Apache
if [ ! -f "$APACHE_CONF" ] || [ ! -f "$APACHE_SSL_CONF" ]; then
    error_message "File konfigurasi Apache tidak ditemukan!"
fi

# Ubah port di konfigurasi Apache
sed -i 's/^Listen 80$/Listen 8000/' "$APACHE_CONF" && success_message "Port HTTP diubah ke 8000."
sed -i 's/^Listen 443$/Listen 8443/' "$APACHE_CONF" && success_message "Port HTTPS diubah ke 8443."
sed -i 's/<VirtualHost \*:443>/<VirtualHost \*:8443>/' "$APACHE_SSL_CONF" && success_message "VirtualHost HTTPS diubah ke 8443."

# Restart Apache
systemctl restart apache2 && success_message "Layanan Apache berhasil direstart."

# Set izin dan kepemilikan direktori
DIRECTORIES=("/etc/xray" "/etc/vmess" "/etc/vless" "/etc/trojan" "/etc/")
for dir in "${DIRECTORIES[@]}"; do
    chown -R www-data:www-data "$dir"
    chmod -R 755 "$dir"
    success_message "Izin dan kepemilikan untuk $dir berhasil diatur."
done

# Tambahkan www-data ke grup sudo
usermod -aG sudo www-data && success_message "Pengguna www-data berhasil ditambahkan ke grup sudo."

# Download file dan atur izin
URLS=(
    "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/tes/addssh"
    "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/tes/vmess"
    "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/tes/trojan"
    "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/tes/api.php"
    "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/api.service"
)

DESTS=(
    "/usr/bin/addssh"
    "/usr/bin/vmess"
    "/usr/bin/trojan"
    "/var/www/html/api.php"
    "/etc/systemd/system/api.service"
)

for i in "${!URLS[@]}"; do
    wget -q -O "${DESTS[$i]}" "${URLS[$i]}" && success_message "File ${URLS[$i]} berhasil diunduh ke ${DESTS[$i]}."
done

# Beri izin eksekusi untuk file di /usr/bin/
chmod +x /usr/bin/addssh /usr/bin/vmess /usr/bin/trojan

# Reload dan aktifkan layanan API
systemctl daemon-reload
systemctl enable api.service
systemctl restart api.service && success_message "Layanan API berhasil diaktifkan dan direstart."

echo -e "\e[32m[SUKSES]: Proses selesai. Apache sekarang menggunakan port 8000 (HTTP) dan 8443 (HTTPS).\e[0m"
