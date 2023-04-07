#!/usr/bin/env bash

# CPU=$( awk '{print $1}' < /proc/loadavg )
# vCORE=$( /usr/bin/lscpu | grep -w "CPU(s):" | awk 'NR==1 { print $2 }' )
# #RAM=$( free -h | grep -vE "total|Swap" | awk '{ print $3 "/" $2 }' )
# RAM=$( free -h | awk '/^Mem/ { print $3 " / " $2 }' )
# DISK=$( df -hF zfs | grep -w "/" |  awk '{ print $3 "/" $2 " ~ " $5 }' )
# #DISK=$(zfs list | grep -w "/" | awk '{print $3"/"$2}')

# echo "CPU: ${CPU}"
# echo "vCORE: ${vCORE}"
# echo "RAM: ${RAM}"
# echo "DISK: ${DISK}"

# ---------------------------------------------------------------------------
# install.sh - Bash shell script
# Copyright 2012-2020, Tam Do Minh <dominhtam.94@gmail.com> - Skype <dominhtam.94>

# This program is free software: you can redistribute it and/or modify 
# it under the terms of GNU General Public License as plblished by 
# the Free Software Foundation,either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.

# Revision history:
# 2023-01-01	Created
# ---------------------------------------------------------------------------

CPU_USAGE=$( top -b -n 1 | grep 'Cpu' | awk '{printf "%.2f", $2 + $4}' )
RAM=$( free -h | awk '/^Mem/ {print $3 "/" $2}' )
DISK=$( zpool list | awk '/^rpool/ {print $3 "/" $2 " ~ " $8}' )
FRAGMENT=$( zpool list | awk '/^rpool/ {print $7}' )
#DISK=$(df -Th | grep -w "/" | awk '{print $4 "/" $3 " ~ " $6}')
#FRAGMENT="None check"


echo "CPU: $CPU_USAGE"
echo "RAM: ${RAM}"
echo "DISK: ${DISK}"
echo "FRAGMENT: ${FRAGMENT}"
