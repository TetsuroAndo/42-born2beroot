### mandate part
export SUDO_USER_NAME=$USER

sudo usermod -aG sudo $USER

# Setting SSH
sudo systemctl enable ssh
sudo systemctl start sshd
sudo sed -i 's/#Port 22/Port 4242/' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
# sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# open port ufw
sudo ufw limit 4242
sudo ufw enable
sudo ufw status #check

# Setting Password Policy
sudo sed -i '/retry=3/ s/$/ minlen=10 ucredit=-1 lcredit=-1 dcredit=-1 maxrepeat=3 reject_username difok=7 enforce_for_root/' /etc/pam.d/common-password
# パスワードポリシーの設定:
# retry=3: トライできる回数
# minlen=10: パスワードの最小長を10文字に設定
# ucredit=-1: 少なくとも1つの大文字を必要とする
# lcredit=-1: 少なくとも1つの小文字を必要とする 
# dcredit=-1: 少なくとも1つの数字を必要とする
# maxrepeat=3: 同じ文字の連続使用を3回までに制限
# reject_username: ユーザー名をパスワードに含めることを禁止
# difok=7: 新しいパスワードは古いパスワードと7文字以上異なる必要がある
# enforce_for_root: rootユーザーにもこれらのルールを適用

# Password Expiration Date
sudo sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t30/' /etc/login.defs
sudo sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t2/' /etc/login.defs

# グループの作成
sudo groupadd user42
# sudo groupadd evaluating
# getent group #check

# ユーザーの追加
#sudo adduser new_username
#sudo useradd new_username
#sudo passwd new_username

# グループにユーザーを追加
sudo usermod -aG user42 $USER
#sudo usermod -aG evaluating $USER
groups #check

# check if the password rules
chage -l $USER
#chage -l your_new_username

# sudo log
sudo mkdir -p /var/log/sudo && \
sudo touch /var/log/sudo/sudo.log

# edit /etc/sudoers
sudo EDITOR='tee -a' visudo <<EOF
Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/bin:/sbin:/bin"
Defaults	badpass_message="Password is wrong, please try again!"
Defaults	passwd_tries=3
Defaults	logfile="/var/log/sudo/sudo.log"
Defaults	log_input, log_output
Defaults	requiretty
EOF

sudo cp ./monitoring.sh /usr/local/bin/monitoring.sh
# crontabの設定を読み取り、現在のユーザーのcrontabに追加
sudo crontab -l > cron
sudo cat ./crontab-setting.txt >> cron
sudo crontab cron
sudo rm cron
# crontab check
sudo crontab -l

# Setting monitoring.sh
sudo chmod 750 /usr/local/bin/monitoring.sh
sudo chown root:root /usr/local/bin/monitoring.sh
# 1. 所有者（オーナー）: 読み取り(4) + 書き込み(2) + 実行(1) = 7
# 2. グループ: 読み取り(4) + 実行(1) = 5
# 3. その他: 権限なし = 0

# sudoersファイル書き込み monitoring.shの権限設定でパスワードなしでも実行可能にする
echo "%sudo ALL=(ALL) NOPASSWD: /usr/local/bin/monitoring.sh" | sudo EDITOR='tee -a' visudo

# change host name
# hostnamectl set-hostname new_hostname
# hostnamectl status | grep "Static hostname"
# sudo reboot
