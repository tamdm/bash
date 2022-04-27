#!/usr/bin/env bash

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
# 2022-03-31	Created
# ---------------------------------------------------------------------------
PROGNAME=${0##*/}
VERSION="3.5"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'
ORANGE='\033[38;5;202m'


function get_opsy() 
{
	[ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
	[ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
	[ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

function Menulist_updateOS()
{
	select opt in Ubuntu Debian Centos Proxmox Back; do
		case $opt in 
			Ubuntu)
				printf "RUNNING UPDATE OS\n"
				$(( which apt-get || which apt )&>/dev/null)
				if [[ $? -eq 0 ]]
				then
					# printf "apt-get update -y && apt-get upgrade -y\n"
					# printf "apt-get install wget -y || apt install wget -y\n"
					apt-get update -y && apt-get upgrade -y
					apt-get install wget -y || apt install wget -y
				else
					printf "${RED}Error: ${PLAIN}Cannot run update OS\n"	
					printf "${RED}Error: ${PLAIN}Please try manual update instead of!\n"
					break
				fi
				;;
			Debian)
				printf "RUNNING UPDATE OS\n"
				$(( which apt-get || which apt )&>/dev/null)
				if [[ $? -eq 0 ]]
				then
					# printf "apt-get update -y && apt-get upgrade -y\n"
					# printf "apt-get install wget -y || apt install wget -y\n"
					apt-get update -y && apt-get upgrade -y
					apt-get install wget -y || apt install wget -y
				else
					printf "${RED}Error: ${PLAIN}Cannot run update OS\n"	
					printf "${RED}Error: ${PLAIN}Please try manual update instead of!\n"
					break
				fi
				;;
			Centos)
				printf "RUNNING UPDATE OS\n"
				$( which yum &>/dev/null )
				if [[ $? -eq 0 ]]
				then
					yum update -y && yum upgrade -y 
					yum install wget -y
				else
					printf "${RED}Error: ${PLAIN}Cannot run update OS\n"	
					printf "${RED}Error: ${PLAIN}Please try manual update instead of!\n"
					break
				fi
				;;
			Proxmox)
				printf "RUNNING UPDATE OS\n"
				$(( which apt-get || which apt ) &>/dev/null )
				if [[ $? -eq 0 ]]
				then
					# printf "apt-get update -y && apt-get upgrade -y\n"
					# printf "apt-get install wget -y || apt install wget -y\n"
					apt-get update -y && apt-get upgrade -y
					apt-get install wget -y || apt install wget -y
				else
					printf "${RED}Error: ${PLAIN}Cannot run update OS\n"	
					printf "${RED}Error: ${PLAIN}Please try manual update instead of!\n"
					break
				fi
				;;
			Back)
				printf "Back to main menu list.\n"
				break
				;;
			*)
				printf "Invalid option $REPLY\n"
				;;
			esac
		done
}

function get_hdsentinel()
{
	local -r HOME_FOLDER="/vinahost"
	#local -r URL="http://210.211.122.233/files/Checkdisk/hdsentinel-019c-x64"
	local -r URL="https://github.com/tamdm/bash/raw/master/hdsentinel"
	if [[ ! -f "${HOME_FOLDER}/hdsentinel" ]]
	then
		$( curl -m 5 -L ${URL} --output ${HOME_FOLDER}/hdsentinel && chmod +x ${HOME_FOLDER}/hdsentinel ) || $(wget --no-check-certificate -O ${HOME_FOLDER}/hdsentinel ${URL} && chmod +x ${HOME_FOLDER}/hdsentinel)
	else 
		printf "File hdsentinel is exist. Not to download new file.\n"	
	fi
}

function get_sendalert()
{
	local -r HOME_FOLDER="/vinahost"
	local -r URL="https://raw.githubusercontent.com/tamdm/bash/master/send_alert.sh"
	if [[ ! -f "${HOME_FOLDER}/send_alert.sh" ]]
	then
		$( curl -m 5 -L ${URL} --output ${HOME_FOLDER}/send_alert.sh && chmod +x ${HOME_FOLDER}/send_alert.sh ) || $(wget --no-check-certificate -O ${HOME_FOLDER}/send_alert.sh ${URL} && chmod +x ${HOME_FOLDER}/send_alert.sh)
	else 
		printf "File send_alert.sh is exist. Not to download new file.\n"
	fi
}

function get_crond()
{	
	echo -e "Set running 12h/time(Press 1) - ${PLAIN}Set running 6h/time (Press 2): "
	echo -e "Menu setup cronjob"
	select opt in Opt_1 Opt_2 Exit; do
	case $opt in 
		Opt_1)
			echo -e "Set crontab run every 8 hours: 0 */8 * * * /bin/bash /vinahost/send_alert.sh"
			read -p "Press Y/y to set cronjob at 8th hours - Press N/n to cancel:" -n 1 -r
			echo
			[[ "${REPLY}" =~ ^[Yy]$ ]] && $(( crontab -l ; echo "0 */8 * * * /bin/bash /vinahost/send_alert.sh") | awk '!x[$0]++'| crontab - )
			;;
		Opt_2)
			echo -e "Set crontab run at 6 hours: 0 */6 * * * /bin/bash /vinahost/send_alert.sh"
			read -p "Press Y/y to set cronjob every 6 hours - Press N/n to cancel: " -n 1 -r
			echo
			[[ "${REPLY}" =~ ^[Yy]$ ]] && $(( crontab -l ; echo "0 */6 * * * /bin/bash /vinahost/send_alert.sh") | awk '!x[$0]++'| crontab - )
			;;
		Exit)
			printf "Back to main menu ...\n"
			break
			;;
		*)
			printf "Invalid option $REPLY\n"
			;;
		esac
		done
}

function optimize_proxmox() 
{
	local -r HOME_FOLDER="/etc/modprobe.d/zfs.conf"
	if [[ -f "/usr/bin/pveversion" ]]
	then
		if [[ ! -f "${HOME_FOLDER}" ]]
		then
			$( touch "${HOME_FOLDER}" ) 
			{
				echo "options zfs zfs_arc_max=2147483648"
				echo "options zfs zfs_arc_min=1073741824"
				echo "options zfs l2arc_noprefetch=0" 
				echo "options zfs zfs_prefetch_disable=1" 
				echo "options zfs zfs_vdev_cache_size=1310720" 
				echo "options zfs zfs_vdev_cache_max=131072" 
				echo "options zfs zfs_vdev_cache_bshift=17" 
				echo "options zfs zfs_read_chunk_size=1310720" 
				echo "options zfs zfs_vdev_async_read_max_active=12" 
				echo "options zfs zfs_vdev_async_read_min_active=12"
				echo "options zfs zfs_vdev_async_write_max_active=12" 
				echo "options zfs zfs_vdev_async_write_min_active=12" 
				echo "options zfs zfs_vdev_sync_read_max_active=12"
				echo "options zfs zfs_vdev_sync_read_min_active=12"
				echo "options zfs zfs_vdev_sync_write_max_active=12" 
				echo "options zfs zfs_vdev_sync_write_min_active=12"
			} >> "${HOME_FOLDER}" 
			/usr/sbin/update-initramfs -u && printf "${ORANGE}Finish config zfs.conf. \n" && sleep 1
		else
			printf "File ${HOME_FOLDER} is exist. ${PLAIN}Not to make new file.\n"
		fi
	else 
		printf "Your OS is not ProxmoxPVE. No need to perform optimization OS\n"
	fi
}

function main() {

[[ $EUID -ne 0 ]] && echo -e "${RED}Error:${PLAIN} This script must be run as root!" && exit 1

[[ ! -d "/vinahost" ]] && $( mkdir /vinahost )
PS3="Enter your choice number: "

select opt in Show-Distro UpdateOS Install_hdsentinel Install_SendAlert Set_Crond Optimize_Proxmox Exit; do
case $opt in 

Show-Distro)
	opsy=$( get_opsy )	
	printf "Your OS is: ${GREEN}${opsy}\n"
	;;
UpdateOS)
	printf "Update OS\n"
	Menulist_updateOS
	;;
Install_hdsentinel)
	printf "Install hdsentinel\n"
	get_hdsentinel
	;;
Install_SendAlert)
	printf "Install SendAlert.sh\n"
	get_sendalert
	;;
Set_Crond)
	printf "Set crontab for send_alert.sh\n"
	get_crond
	;;
Optimize_Proxmox)
	printf "Tạo file zfs.conf để tối ưu ram cho Proxmox PVE\n"
	printf "${ORANGE}Chỉ dùng cho phiên bản 5.1.3 trở về sau\n"
	read -p "Are you sure? [Y/y] to install. Press [N/n] to cancel" -n 1 -r
	echo
	[[ ${REPLY} =~ ^[Yy]$ ]] && optimize_proxmox
	;;
Exit)
	printf "[+] Exit the ${0}... Please wait\n"
	break
	;;
*)
	printf "Invalid option $REPLY\n"
	;;
esac
done
}

main "${@}"
