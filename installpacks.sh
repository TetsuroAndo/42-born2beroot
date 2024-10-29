# su

apt-mark hold apache2
apt-mark hold nginx
apt-mark hold apache2-utils
apt-mark hold apache2-bin
apt-mark hold apache2-data
apt-mark hold libapache2-mod-php8.2

apt update && apt upgrade -y && \
apt install -y 	sudo \                # 管理者権限を付与するツール
                wget \                # ファイルをダウンロードするツール
                curl \                # データを転送するツール
                git \                 # バージョン管理システム
                vim \                 # テキストエディタ
                lvm2 \                # 論理ボリューム管理ツール
                ufw \                 # ファイアウォール管理ツール
                openssh-server \      # SSHサーバー
                libpam-pwquality \    # パスワード品質を管理するライブラリ
                cron \                # 定期的なタスクを実行するデーモン
                net-tools \           # ロギングのためのネットワークツール
                bc                    # ロギングのための算出用ツール

# bonus
apt install -y 	lighttpd \            # 軽量なWebサーバー
                mariadb-server \      # オープンソースのデータベースサーバー
                php \                 # サーバーサイドスクリプト言語
                php-mysql \           # PHP用のMySQLモジュール
                php-cgi \             # PHPのCGI実行モジュール
                php-fpm               # PHPのFastCGIプロセスマネージャー

# sudoパッケージのパスを読み込む
source /etc/profile
# visudo
# YOU_USERNAME ALL=(ALL) ALL