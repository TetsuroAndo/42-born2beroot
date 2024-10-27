#!/bin/bash

# システムのアーキテクチャ情報を取得
# uname -a: カーネル名、ホスト名、カーネルリリース、カーネルバージョン、マシンハードウェア名、プロセッサタイプ、OSを表示
architecture=$(uname -a)

# 物理CPUの数を取得
# /proc/cpuinfoから"physical id"を含む行を抽出し、重複を除いて数える
physical_cpu=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)

# 仮想CPUの数を取得
# /proc/cpuinfoから"processor"で始まる行の数をカウント
virtual_cpu=$(grep "^processor" /proc/cpuinfo | wc -l)

# 全メモリ量をMB単位で取得
# free -mの出力からMem:行の2列目（合計メモリ）を抽出
total_mem=$(free -m | awk '$1 == "Mem:" {print $2}')

# 使用中のメモリ量をMB単位で取得
# free -mの出力からMem:行の3列目（使用中メモリ）を抽出
used_mem=$(free -m | awk '$1 == "Mem:" {print $3}')

# メモリ使用率を計算（小数点2桁まで）
# bcコマンドで計算し、awkで小数点以下2桁にフォーマット
mem_percent=$(echo "scale=2; $used_mem / $total_mem * 100" | bc | awk '{printf("%.2f", $0)}')

# 全ディスク容量をMB単位で取得
# df -Bmの出力から/dev/で始まり/bootで終わらない行を抽出し、2列目（合計サイズ）の合計を計算
total_disk=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ft += $2} END {print ft}')

# 使用中のディスク容量をMB単位で取得
# df -Bmの出力から/dev/で始まり/bootで終わらない行を抽出し、3列目（使用量）の合計を計算
used_disk=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} END {print ut}')

# ディスク使用率を計算（小数点2桁まで）
# bcコマンドで計算し、awkで小数点以下2桁にフォーマット
disk_percent=$(echo "scale=2; $used_disk / $total_disk * 100" | bc | awk '{printf("%.2f", $0)}')

# CPU負荷を取得
# topコマンドの出力から%Cpuで始まる行を抽出し、ユーザー時間とシステム時間を合計して小数点1桁にフォーマット
cpu_load=$(top -bn1 | grep '^%Cpu' | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}')

# 最後の起動時刻を取得
# who -bの出力からsystem行の3列目と4列目（日付と時刻）を抽出
last_boot=$(who -b | awk '$1 == "system" {print $3 " " $4}')

# LVMの使用状況を確認
# lsblkの出力からlvmを含む行があればyes、なければnoを出力
lvm_use=$(if [ $(lsblk | grep "lvm" | wc -l) -eq 0 ]; then echo no; else echo yes; fi)

# 確立されたTCP接続の数を取得
# ssコマンドの出力からESTAB（確立済み）状態の接続数をカウント
tcp_connections=$(ss -t | grep ESTAB | wc -l)

# ログイン中のユーザー数を取得
# whoコマンドの出力行数をカウント
user_log=$(who | wc -l)

# IPアドレスを取得
# hostname -Iの出力から最初のIPアドレスを抽出
ip=$(hostname -I | awk '{print $1}')

# MACアドレスを取得
# ip link showの出力からlink/etherを含む行のMACアドレス部分を抽出
mac=$(ip link show | awk '/link\/ether/ {print $2}')

# sudoコマンドの実行回数を取得
# journalctlの出力からsudoコマンドのCOMMANDを含む行数をカウント
sudo_count=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

# 以下の情報をwall命令でログインしている全ユーザーに表示
wall "
    #Architecture: $architecture
    #CPU physical : $physical_cpu
    #vCPU : $virtual_cpu
    #Memory Usage: $used_mem/${total_mem}MB ($mem_percent%)
    #Disk Usage: $used_disk/${total_disk}MB ($disk_percent%)
    #CPU load: $cpu_load
    #Last boot: $last_boot
    #LVM use: $lvm_use
    #Connections TCP : $tcp_connections ESTABLISHED
    #User log: $user_log
    #Network: IP $ip ($mac)
    #Sudo : $sudo_count cmd
"