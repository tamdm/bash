#!/usr/bin/env bash

HOSTNAME=$(hostname)
DATE=$(date '+%d-%B, %Y')
IP=$(curl -s https://ip.vinahost.vn)
install_folder="/script-Vinahost"
hdsentinel_raw="/script-Vinahost/hdsentinel-result.txt"

function CheckAuthorization() {
   if [[ "${UID}" -ne 0 ]]
      then
         echo "Please run this script with root or root privileges" 1>&2
         exit 1
      fi
}

function checkBadSector() {
	while read line
	do
		if echo $line | grep PERFECT &> /dev/null;
		then
			echo 0 >> "${install_folder}/bad-sector.txt"
		elif  echo $line | grep "bad sector" &> /dev/null;
		then
			echo $line | grep -Po "[[:digit:]]+ *(?=bad sector)" | tee -a "${install_folder}/bad-sector.txt" &>/dev/null
		fi
	done < "${install_folder}/sector.txt"
}
# Send message through telegram
function sendAlert() {
    local token_id="1126087523:AAG38a7Fm_ZJDey1LXFgdJZLH_WLYpUeWtk"
    local group_id="-649404770"
    # local group_id="-1291900277"
    local URL="https://api.telegram.org/bot$token_id/sendMessage"
    curl -s -X POST $URL -d chat_id=$group_id -d text="
    Please notice The System Administrator NOW!!!
    ******************************************
    IP ADDRESS IS: "${IP}"
    ******************************************
    $(cat "${install_folder}/${MESSAGE}.txt")
    ******************************************
    ${DATE}" > /dev/null
}

function CheckRaid() {

Raid_Failed="false"
MESSAGE="report-raid"
MDADM=$(df -h | grep "/md" | wc -l)
ZFS=$(mount | grep zfs | wc -l)

if [[ "${MDADM}" -ge 1 ]]
then
	# condition=$(/usr/bin/egrep "\[.*_.*\]" /proc/mdstat)
	condition=$(/usr/bin/grep "\[.*_.*\]" /proc/mdstat)
	# if $(egrep "\[.*_.*\]" /proc/mdstat)  > /dev/null 
	if [[ "${condition}" ]]
	then
		Raid_Failed="true"
		/usr/bin/cat /proc/mdstat | tee "${install_folder}/${MESSAGE}.txt" 1>/dev/null
	fi
fi

if [[ "${ZFS}" -ge 1 ]]
then

	condition=$(/sbin/zpool status | egrep -w -i '(DEGRADED|FAULTED|OFFLINE|UNAVAIL|REMOVED|FAIL|DESTROYED|corrupt|cannot|unrecover)')
	errors=$(/sbin/zpool status | grep ONLINE | grep -v state | awk '{print $3 $4 $5}' | grep -v 000)
	if [[ "${condition}" || "${errors}" ]] 
	then
		Raid_Failed="true"
		zpool status | tee "${install_folder}/${MESSAGE}.txt" &>/dev/null
	fi
fi

if [[ "${Raid_Failed}" == "true" ]]
then
	sendAlert "${install_folder}" "${DATE}" "${IP}" "${MESSAGE}"
fi
}

# Main function
main() {


CheckAuthorization #Check root permission

if [ ! -d "${install_folder}" ];
then
	mkdir -p "${install_folder}"
fi
if [[ "${?}" -ne 0 ]]
then
	exit 1
fi


if [[ ! -f "${install_folder}/hdsentinel" ]]
then
	wget -O "${install_folder}/hdsentinel" http://210.211.122.233/files/hdsentinel-019c-x64 2>/dev/null && chmod +x "${install_folder}/hdsentinel" 
fi
if [[ "${?}" -ne 0 ]]
then
	#Mail check URL file hdsentinel removed
	exit 1
fi


"${install_folder}/hdsentinel" |  tee "${hdsentinel_raw}" &>/dev/null


grep "/dev/" "${hdsentinel_raw}" | awk '{print $4}' | tee "${install_folder}/devices.txt" 1>/dev/null
grep "Health" "${hdsentinel_raw}" | awk '{print $3}' | tee "${install_folder}/disk-health.txt" 1>/dev/null
grep "PERFECT\|bad sector" "${hdsentinel_raw}" | tee "${install_folder}/sector.txt" 1>/dev/null
sed -i '/^$/d' "${install_folder}"/*.txt

# Function check bad sector from hdsentinel_raw
checkBadSector
i=1
Health_Disk_Low="false"
MESSAGE="report-disk"
device_num=$( /usr/bin/wc -l < "${install_folder}/devices.txt" )

echo -e "Device\t\t| Health\t| Bad Sector\t" > "${install_folder}/${MESSAGE}.txt"
while [ "${i}" -le "${device_num}" ]
	do
		DEVICE=$(awk "NR==$i" "${install_folder}/devices.txt")
		HEALTH=$(awk "NR==$i" "${install_folder}/disk-health.txt")
		BAD_SECTOR=$(awk "NR==$i" "${install_folder}/bad-sector.txt")

		if [[ "${HEALTH}" -lt 40 || "${HEALTH}" == "Unknow" || "${BAD_SECTOR}" -ne 0 ]]
		then
			Health_Disk_Low="true"
		fi
		echo -e ">$DEVICE\t| ${HEALTH}%\t| $BAD_SECTOR bad-sector\t" | tee -a "${install_folder}/${MESSAGE}.txt" 1> /dev/null
		((i++))
	done

if [[ "${Health_Disk_Low}" == "true" ]]
then
	sendAlert "${install_folder}" "${DATE}" "${IP}" "${MESSAGE}"
fi

# Function check raid mdadm and zfs raid - then send alert to telegram
CheckRaid
}

rm -f "${install_folder}"/*.txt
main


