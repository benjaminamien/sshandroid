#!/data/data/com.termux/files/usr/bin/sh

# Update & upgrade
pkg update -y

# Install packages
pkg install -y openssh git jq python termux-api

# Setup storage
termux-setup-storage

# Atur password untuk user Termux
echo "Mengatur password user..."
printf "726785\n726785\n" | passwd

# Jalankan SSHD
sshd

# Clone repo
git clone https://github.com/benjaminamien/toolandroid.git ~/toolandroid


# chmod file di toolandroid
chmod +x ~/toolandroid/gps.sh ~/toolandroid/serveo.sh ~/toolandroid/notification.sh ~/toolandroid/notif2telegram.sh 2>/dev/null

# Buat folder boot
mkdir -p ~/.termux/boot

# Skrip start.sh
cat <<EOF > ~/.termux/boot/start.sh
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
sshd
EOF

# Skrip autoserveo.sh
cat <<EOF > ~/.termux/boot/autoserveo.sh
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
bash ~/toolandroid/notif2telegram.sh
EOF

# Beri izin eksekusi
chmod +x ~/.termux/boot/start.sh ~/.termux/boot/autoserveo.sh

# Ubah prompt (sekali saja, supaya tidak double)
echo 'export PS1="benjamin@termux:~$ "' >> ~/.bashrc

# Muat ulang konfigurasi
. ~/.bashrc

# Info selesai
echo "Setup selesai! SSH siap digunakan."
