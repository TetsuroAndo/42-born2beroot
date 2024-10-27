su
apt update && apt upgrade -y && \
apt install -y sudo wget git vim openssh-server ufw libpam-pwquality lvm2 cron net-tools

# bonus
apt install -y lighttpd mariadb-server php php-mysql php-cgi

### additional php package
## apt install php-gd php-xml php-mbstring php-curl
