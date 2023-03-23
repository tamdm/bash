#!/usr/bin/env bash


CPU=$( awk '{print $1}' < /proc/loadavg )
vCORE=$( /usr/bin/lscpu | grep -w "CPU(s):" | awk 'NR==1 { print $2 }' )
#RAM=$( free -h | grep -vE "total|Swap" | awk '{ print $3 "/" $2 }' )
RAM=$( free -h | awk '/^Mem/ { print $3 " / " $2 }' )
DISK=$( df -hF zfs | grep -w "/" |  awk '{ print $3 "/" $2 " ~ " $5 }' )
#DISK=$(zfs list | grep -w "/" | awk '{print $3"/"$2}')

echo "CPU: ${CPU}"
echo "vCORE: ${vCORE}"
echo "RAM: ${RAM}"
echo "DISK: ${DISK}"
