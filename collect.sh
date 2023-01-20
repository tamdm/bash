#!/usr/bin/env bash

CPU=$(uptime | awk -F ":" {'print $5'} | awk '{print $2}'| rev | cut -c2- | rev)
vCORE=$(lscpu | head -n 5 | grep -w "CPU(s):" | awk '{print $2}')
RAM=$(free -h | grep -vE "total|Swap" | awk {'print $3"/"$2'})
DISK=$(df -hF zfs | grep -w "/" |  awk {'print $3"/"$2" ~ "$5'})

echo "CPU: ${CPU}"
echo "vCORE: ${vCORE}"
echo "RAM: ${RAM}"
echo "DISK: ${DISK}"
