#!/bin/bash

architecture=$(uname -a)
physical_cpu=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)
virtual_cpu=$(grep "^processor" /proc/cpuinfo | wc -l)
total_mem=$(free -m | awk '$1 == "Mem:" {print $2}')
used_mem=$(free -m | awk '$1 == "Mem:" {print $3}')
mem_percent=$(echo "scale=2; $used_mem / $total_mem * 100" | bc | awk '{printf("%.2f", $0)}')
total_disk=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ft += $2} END {print ft}')
used_disk=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} END {print ut}')
disk_percent=$(echo "scale=2; $used_disk / $total_disk * 100" | bc | awk '{printf("%.2f", $0)}')
cpu_load=$(top -bn1 | grep '^%Cpu' | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}')
last_boot=$(who -b | awk '$1 == "system" {print $3 " " $4}')
lvm_use=$(if [ $(lsblk | grep "lvm" | wc -l) -eq 0 ]; then echo no; else echo yes; fi)
tcp_connections=$(ss -t | grep ESTAB | wc -l)
user_log=$(who | wc -l)
ip=$(hostname -I | awk '{print $1}')
mac=$(ip link show | awk '/link\/ether/ {print $2}')
sudo_count=$(journalctl _COMM=sudo | grep COMMAND | wc -l)
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