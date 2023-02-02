#!/usr/bin/env bash

CPU=$(cat /proc/loadavg | awk '{print $1}')
vCORE=$(/usr/bin/lscpu | grep "CPU(s):" | grep -v "NUMA" | awk '{print $2}')
RAM=$(free -h | grep -vE "total|Swap" | awk {'print $3"/"$2'})
DISK=$(df -hF zfs | grep -w "/" |  awk {'print $3"/"$2" ~ "$5'})
#DISK=$(zfs list | grep -w "/" | awk '{print $2"/"$3}')

echo "CPU: ${CPU}"
echo "vCORE: ${vCORE}"
echo "RAM: ${RAM}"
echo "DISK: ${DISK}"
