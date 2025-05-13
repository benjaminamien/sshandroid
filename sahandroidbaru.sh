#!/data/data/com.termux/files/usr/bin/sh

#update
pkg update

# Install OpenSSH
pkg install -y openssh

pkg install git

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

# git clone
git clone https://github.com/benjaminamien/toolandroid.git

# chmod
chmod +x ~/toolandroid/gps.sh
chmod +x ~/toolandroid/serveo.sh
chmod +x ~/toolandroid/notification.sh

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
bash ~/toolandroid/serveo.sh
EOF

# Beri izin eksekusi ke start.sh
chmod +x ~/.termux/boot/start.sh

# beri izin autoserveo
chmod +x ~/.termux/boot/autoserveo.sh

# Ubah prompt Termux menjadi custom_name@termux
echo 'export PS1="benjamin@termux:~$ "' >> ~/.bashrc

# Muat ulang file konfigurasi bash untuk menerapkan perubahan
. ~/.bashrc

# Menyampaikan bahwa setup telah selesai
echo "Setup selesai! SSH siap digunakan."
