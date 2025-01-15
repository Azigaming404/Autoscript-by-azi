#!/bin/bash

# Fungsi untuk mencetak pesan sukses
success_message() {
    echo -e "\e[32m[SUKSES]: $1\e[0m"
}

# Fungsi untuk mencetak pesan error
error_message() {
    echo -e "\e[31m[ERROR]: $1\e[0m"
}

# Path konfigurasi Apache
APACHE_CONF="/etc/apache2/ports.conf"
APACHE_SSL_CONF="/etc/apache2/sites-available/default-ssl.conf"

# Periksa apakah skrip dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
    error_message "Skrip ini harus dijalankan sebagai root!"
    exit 1
fi

# Instalasi paket yang diperlukan
PACKAGES=("php" "php-curl" "python3" "python3-pip" "apache2")
for package in "${PACKAGES[@]}"; do
    if apt-get install -y "$package"; then
        success_message "Paket $package berhasil diinstal."
    else
        error_message "Gagal menginstal paket $package."
        exit 1
    fi
done

# Instalasi Flask
if pip3 install flask; then
    success_message "Flask berhasil diinstal."
else
    error_message "Gagal menginstal Flask."
    exit 1
fi

# Periksa file konfigurasi Apache
if [ ! -f "$APACHE_CONF" ] || [ ! -f "$APACHE_SSL_CONF" ]; then
    error_message "File konfigurasi Apache tidak ditemukan!"
    exit 1
fi

# Ubah port di konfigurasi Apache
sed -i 's/^Listen 80$/Listen 8000/' "$APACHE_CONF" && \
    success_message "Port HTTP (80) diubah menjadi 8000."
sed -i 's/^Listen 443$/Listen 8443/' "$APACHE_CONF" && \
    success_message "Port HTTPS (443) diubah menjadi 8443."
sed -i 's/<VirtualHost \*:443>/<VirtualHost \*:8443>/' "$APACHE_SSL_CONF" && \
    success_message "VirtualHost HTTPS diubah menjadi 8443."

# Restart Apache
if systemctl restart apache2; then
    success_message "Layanan Apache berhasil direstart."
else
    error_message "Gagal me-restart layanan Apache!"
    exit 1
fi

# Set izin dan kepemilikan direktori
DIRECTORIES=("/etc/xray" "/etc/vmess" "/etc/vless" "/etc/trojan" "/etc/")
for dir in "${DIRECTORIES[@]}"; do
    sudo chown -R www-data:www-data "$dir"
    sudo chmod -R 755 "$dir"
    success_message "Izin dan kepemilikan untuk $dir berhasil diatur."
done

# Tambahkan www-data ke grup sudo
sudo usermod -aG sudo www-data && \
    success_message "Pengguna www-data berhasil ditambahkan ke grup sudo."

# Download file dan atur izin
FILES=(
    "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/tes/addssh:/usr/bin/addssh"
    "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/tes/vmess:/usr/bin/vmess"
    "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/tes/trojan:/usr/bin/trojan"
    "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/tes/api.php:/var/www/html/api.php"
    "https://raw.githubusercontent.com/Azigaming404/Autoscript-by-azi/refs/heads/main/api.service:/etc/systemd/system/api.service"
)
for file in "${FILES[@]}"; do
    URL="${file%%:*}"
    DEST="${file##*:}"
    wget -q -O "$DEST" "$URL" && chmod 777 "$DEST" && \
        success_message "File $URL berhasil diunduh ke $DEST."
done

# Reload dan aktifkan layanan API
systemctl daemon-reload
systemctl enable api.service
if systemctl restart api.service; then
    success_message "Layanan API berhasil diaktifkan dan direstart."
else
    error_message "Gagal mengaktifkan dan me-restart layanan API!"
    exit 1
fi

echo -e "\e[32m[SUKSES]: Proses selesai. Apache sekarang menggunakan port 8000 (HTTP) dan 8443 (HTTPS).\e[0m"
