### Bonus part

# Partition setting image
# NAME                        MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
# sr0                          11:0    1 1024M  0 rom
# vda                         254:0    0   32G  0 disk
# ├─vda1                      254:1    0  512M  0 part  /boot/efi
# ├─vda2                      254:2    0  488M  0 part  /boot
# └─vda3                      254:3    0   31G  0 part
#   └─vda3_crypt              253:0    0   31G  0 crypt
#     ├─teando42--vg-root     253:1    0  6.1G  0 lvm   /
#     ├─teando42--vg-var      253:2    0  2.4G  0 lvm   /var
#     ├─teando42--vg-swap_1   253:3    0  976M  0 lvm   [SWAP]
#     ├─teando42--vg-tmp      253:4    0  484M  0 lvm   /tmp
#     ├─teando42--vg-home     253:5    0 11.1G  0 lvm   /home
#     ├─teando42--vg-srv      253:6    0    3G  0 lvm   /srv
#     └─teando42--vg-var--log 253:7    0    4G  0 lvm   /var/log

# /srv
sudo lvcreate -L 5G -n srv teando42-vg
# /var/log
sudo lvcreate -L 5G -n var-log teando42-vg

# create file system
sudo mkfs.ext4 /dev/teando42-vg/srv
sudo mkfs.ext4 /dev/teando42-vg/var-log

# create mount point
sudo mkdir -p /srv
sudo mkdir -p /var/log

# /etc/fstabに追加するエントリ
echo "/dev/mapper/teando42--vg-srv /srv ext4 defaults 0 2" | sudo tee -a /etc/fstab
echo "/dev/mapper/teando42--vg-var--log /var/log ext4 defaults 0 2" | sudo tee -a /etc/fstab

# mount new partition
sudo mount -a

# servece port open
sudo ufw allow 80
sudo ufw allow 443

# check no Apache and Nginx
dpkg -l | grep -E 'apache2|nginx'
systemctl list-unit-files | grep -E 'apache2|nginx'
which apache2
which nginx

# Lighttpdの設定
sudo lighty-enable-mod fastcgi
sudo lighty-enable-mod fastcgi-php
sudo service lighttpd force-reload
# check
sudo systemctl status lighttpd

# MariaDBのセキュリティ設定
sudo mysql_secure_installation

# WordPressのデータベースとユーザーを作成
sudo mysql -e "CREATE DATABASE wordpress;"
sudo mysql -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'Password-Is-42';"
sudo mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# WordPressのダウンロードと展開
sudo mkdir -p /var/www/html && \
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo rm latest.tar.gz

# 権限の設定
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

# wp-config.phpの設定
cd /var/www/html/wordpress
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/wordpress/" wp-config.php
sudo sed -i "s/username_here/wpuser/" wp-config.php
sudo sed -i "s/password_here/Password-Is-42/" wp-config.php

sudo sed -i "/DB_HOST/a\
define('DB_NAME', 'wordpress');\n\
define('DB_USER', 'wpuser');\n\
define('DB_PASSWORD', 'Password-Is-42');" /var/www/html/wordpress/wp-config.php

# routing server
SERVER_IP_ADDRESS=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n1)
sudo tee /etc/lighttpd/conf-available/10-wordpress.conf > /dev/null <<EOL
\$HTTP["host"] == "$SERVER_IP_ADDRESS" {
    var.docroot = "/var/www/html/wordpress"
    server.document-root = var.docroot
    server.indexfiles    = ("index.php", "index.html")

    fastcgi.server += ( ".php" =>
        ((
            "socket" => "/var/run/php/php-fpm.sock",
            "broken-scriptfilename" => "enable"
        ))
    )
}
EOL

sudo ln -s /etc/lighttpd/conf-available/10-wordpress.conf /etc/lighttpd/conf-enabled/
sudo lighttpd -t -f /etc/lighttpd/lighttpd.conf

# service start and reload
sudo systemctl enable php8.2-fpm
sudo systemctl start php8.2-fpm
sudo systemctl restart php8.2-fpm
sudo systemctl status php8.2-fpm

sudo service lighttpd restart
sudo service lighttpd status

# wp-config.phpファイル内の認証キーとソルトを更新
# これらの手順を実行した後、ブラウザでサーバーのIPアドレスにアクセス

### bonus "Set up a service of your choice that you think is useful."
# what is wireguard: https://www.youtube.com/watch?v=grDEBt7oQho

# Install and Auth
curl -fsSL https://tailscale.com/install.sh | sh
