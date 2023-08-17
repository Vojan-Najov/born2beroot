#!/usr/bin/bash

ARCH=$(uname --all)

PCPU=$(grep 'physical id' /proc/cpuinfo | sort | uniq | wc -l)

VCPU=$(grep '^processor' /proc/cpuinfo | wc -l)

MEM=$(free -m | grep '^Mem')
MEMU=$(echo "$MEM" | awk '{ print $3 }')
MEMT=$(echo "$MEM" | awk '{ print $2 }')
MEMP=$(echo "$MEM" | awk '{ printf("%.2f", 100.0 * $3 / $2) }')

DT=$(df -BG | grep '^/dev/' | grep -v 'boot' | \
							awk '{ dt += $2 } END { print dt }')
DS=$(df -BM | grep '^/dev/' | grep -v 'boot')
DU=$(echo "$DS" | awk '{ du += $3 } END { print du }')
DP=$(df -k | grep '^/dev/' | grep -v 'boot' \
	| awk '{ dt += $2 } { du += $3 } END { printf("%.0f", 100.0 * du / dt) }')

CPUL=$(top -b -n 1 | grep '^%Cpu' | tr -s "," " " | \
					awk '{ printf("%.1f", 100.0 - $8) }')

LASTBOOT=$(who -b | awk '{ print $3 " " $4 }')

if [[ $(lsblk | grep 'lvm' | wc -l) -eq 0 ]]
then
	LVM="no"
else
	LVM="yes"
fi

TCPN=$(ss --tcp state established | tail -n +2 | wc -l)

#USERN=$(who | awk '{ print $1 }' | wc -l)
USERUN=$(who | awk '{ print $1 }' | sort | uniq | wc -l)

IPV4=$(ip -4 address | head -n 4 | grep 'scope global enp0s3' | \
	awk '{ split($2, a, "/"); print a[1]}')
MAC=$(ip -0 address | grep 'link/ether' | awk '{ print $2 }')

CMDS=$(grep 'COMMAND' /var/log/sudo/sudo.log | wc -l)

echo "#Architecture: $ARCH"
echo "#CPU physical : $PCPU"
echo "#vCPU : $VCPU"
echo "#Memory Usage: $MEMU/${MEMT}MB ($MEMP%)"
echo "#Disk Usage: $DU/${DT}Gb ($DP%)"
echo "#CPU load: $CPUL%"
echo "#Last boot: $LASTBOOT"
echo "#LVM use: $LVM"
echo "Connexions TCP : $TCPN ESTABLISHED"
echo "User log: $USERUN"
echo "#Network: IP $IPV4 ($MAC)"
echo "#Sudo : $CMDS cmd"
