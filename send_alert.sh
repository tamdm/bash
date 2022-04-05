#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# install.sh - Bash shell script
# Copyright 2012-2020, Tam Do Minh <dominhtam.94@gmail.com>

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
# 2021-03-31	Created
# ---------------------------------------------------------------------------
PROGNAME=${0##*/}
VERSION="3.5"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'
ORANGE='\033[38;5;202m'

DATE=$(date '+%d-%B, %Y')
HOME_FOLDER="/vinahost"
Attribute=("HDD Device" "HDD Model" "Temperature" "Highest Temp" "Health" "Performance" "Est. lifetime" "Total written" "Bad sector")

# function isEmptyString()
# {
#     local -r string="${1}"

#     if [[ "$(trimString "${string}")" = '' ]]
#     then
#         echo 'true' && return 0
#     fi

#     echo 'false' && return 1
# }

# function isPositiveInteger()
# {
#     local -r string="${1}"

#     if [[ "${string}" =~ ^[1-9][0-9]*$ ]]
#     then
#         echo 'true' && return 0
#     fi

#     echo 'false' && return 1
# }

# function trimString()
# {
#     local -r string="${1}"

#     sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
# }

# function printTable()
# {
#     local -r delimiter="${1}"
#     local -r tableData="$(removeEmptyLines "${2}")"
#     local -r colorHeader="${3}"
#     local -r displayTotalCount="${4}"

#     if [[ "${delimiter}" != '' && "$(isEmptyString "${tableData}")" = 'false' ]]
#     then
#         local -r numberOfLines="$(trimString "$(wc -l <<< "${tableData}")")"

#         if [[ "${numberOfLines}" -gt '0' ]]
#         then
#             local table=''
#             local i=1

#             for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
#             do
#                 local line=''
#                 line="$(sed "${i}q;d" <<< "${tableData}")"

#                 local numberOfColumns=0
#                 numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

#                 # Add Line Delimiter

#                 if [[ "${i}" -eq '1' ]]
#                 then
#                     table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
#                 fi

#                 # Add Header Or Body

#                 table="${table}\n"

#                 local j=1

#                 for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
#                 do
#                     table="${table}$(printf '#|  %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
#                 done

#                 table="${table}#|\n"

#                 # Add Line Delimiter

#                 if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
#                 then
#                     table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
#                 fi
#             done

#             if [[ "$(isEmptyString "${table}")" = 'false' ]]
#             then
#                 local output=''
#                 output="$(echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1')"

#                 if [[ "${colorHeader}" = 'true' ]]
#                 then
#                     echo -e "\033[1;32m$(head -n 3 <<< "${output}")\033[0m"
#                     tail -n +4 <<< "${output}"
#                 else
#                     echo "${output}"
#                 fi
#             fi
#         fi

#         if [[ "${displayTotalCount}" = 'true' && "${numberOfLines}" -ge '0' ]]
#         then
#             echo -e "\n\033[1;36mTOTAL ROWS : $((numberOfLines - 1))\033[0m"
#         fi
#     fi
# }

# function removeEmptyLines()
# {
#     local -r content="${1}"

#     echo -e "${content}" | sed '/^\s*$/d'
# }

# function repeatString()
# {
#     local -r string="${1}"
#     local -r numberToRepeat="${2}"

#     if [[ "${string}" != '' && "$(isPositiveInteger "${numberToRepeat}")" = 'true' ]]
#     then
#         local -r result="$(printf "%${numberToRepeat}s")"
#         echo -e "${result// /${string}}"
#     fi
# }


function get_hdsentinel()
{
    local -r URL="http://210.211.122.233/files/Checkdisk/hdsentinel-019c-x64"
    if [[ ! -f "${HOME_FOLDER}/hdsentinel" ]]
    then
        $( curl -m 5 -L ${URL} --output ${HOME_FOLDER}/hdsentinel && chmod +x "${HOME_FOLDER}/hdsentinel"  ) ||  (sendMessageToTelegram "Error:File hdsentinel-019c-x64 not found. Please manual check!" && exit 1)
    fi

    cd "${HOME_FOLDER}" && ./hdsentinel > report
    
}
function sendMessageToTelegram() 
{
    local IP=$(curl -s https://ip.vinahost.vn || (hostname -I | awk '{print $1}'))
    local token_id="1126087523:AAG38a7Fm_ZJDey1LXFgdJZLH_WLYpUeWtk"
    local group_id="-604759080"
    # local group_id="-1291900277"
    local -r URL="https://api.telegram.org/bot$token_id/sendMessage"

    curl -s -X POST $URL -d chat_id=$group_id -d text="

    Đây là tin nhắn khẩn cấp

    Vui lòng báo cho Admin hoặc Phòng network để kiểm tra !!!
    
    IP Adress: "${IP}"
    #########################################
    $(echo "${1}")
    #########################################
    Thời gian: ${DATE}" > /dev/null
}
function formatData() 
{
    while IFS= read -r line;
    do
        for val in "${Attribute[@]}";
        do
            case "${line}" in 
                *"${val}"*)
                    echo "${line}" >> "${HOME_FOLDER}/disk.txt"
                ;;
            esac
        done    
        case "${line}" in 
            *"PERFECT"*)
                echo "Bad sector   : 0" >> disk.txt
            ;;
            *"bad sectors"*)
                local num=$(echo "$line" | sed 's/[^0-9]*\([0-9]\+\).*/\1/')
                echo "Bad sector   : "${num}"" >> "${HOME_FOLDER}/disk.txt"
            ;;
        esac
    done < "${HOME_FOLDER}/report"

    cd "${HOME_FOLDER}" && split -l 9 disk.txt -a 1 sd && rm -f "${HOME_FOLDER}/disk.txt"
    [[ "$(grep "Unknown" ${HOME_FOLDER}/sd* | cut -d":" -f1 | head -n1)" ]] && rm -f "${HOME_FOLDER}/$(grep "Unknown" sd* | cut -d":" -f1 | head -n1)"
}

function checkProblemAttribute()
{
    while IFS= read -r line;
    do
        case "${line}" in 
            *"Temperature"*)
                local -r num_temp=$(echo "$line" | sed 's/[^0-9]*\([0-9]\+\).*/\1/')
                ;;
            *"Health"*)
                local -r num_health=$(echo "$line" | sed 's/[^0-9]*\([0-9]\+\).*/\1/')
                ;;
            *"Performance"*)
                local -r num_perform=$(echo "$line" | sed 's/[^0-9]*\([0-9]\+\).*/\1/')
                ;;
            *"Est. lifetime"*)
                local -r num_lifetime=$(echo "$line" | sed 's/[^0-9]*\([0-9]\+\).*/\1/')
                ;;
            # *"Total written"*)
            #     local -r num_totalwritten=$(echo "$line" | sed 's/[^0-9]*\([0-9]\+\).*/\1/')
                # ;;
            *"Bad sector"*)
                local -r num_badsector=$(echo "$line" | sed 's/[^0-9]*\([0-9]\+\).*/\1/')
                ;;
        esac

    done < "${HOME_FOLDER}/${1}"

    if [[ "${num_temp}" -gt 50 || "${num_health}" -lt 50 || "${num_perform}" -lt 50 || "${num_lifetime}" -lt 100 || "${num_badsector}" -gt 1 ]] 
    then
        local content=$(cat "${HOME_FOLDER}/${1}")
        sendMessageToTelegram "${content}"
    fi
}

function checkProblemDisk() 
{
    local -r disk_array=$(cd "${HOME_FOLDER}"; ls sd*)
    for disk in ${disk_array[@]};
        do 
           checkProblemAttribute "${disk}" 
        done
}

function CheckRaid() 
{
Raid_Failed="false"
MDADM=$(df -h | grep "/md" | wc -l)
ZFS=$(mount | grep zfs | wc -l)

if [[ "${MDADM}" -ge 1 ]]
then
    condition=$(/usr/bin/grep "\[.*_.*\]" /proc/mdstat)
    if [[ "${condition}" ]]
    then
        Raid_Failed="true"
        /usr/bin/cat /proc/mdstat > "${HOME_FOLDER}/raid" 
    fi
fi

if [[ "${ZFS}" -ge 1 ]]
then
    condition=$(/sbin/zpool status | egrep -w -i '(DEGRADED|FAULTED|OFFLINE|UNAVAIL|REMOVED|FAIL|DESTROYED|corrupt|cannot|unrecover)')
    errors=$(/sbin/zpool status | grep ONLINE | grep -v state | awk '{print $3 $4 $5}' | grep -v 000)
    if [[ "${condition}" || "${errors}" ]] 
    then
        Raid_Failed="true"
        zpool status > "${HOME_FOLDER}/raid" 
    fi
fi

if [[ "${Raid_Failed}" == "true" ]]
then
    sendAlert "${install_folder}" "${DATE}" "${IP}" "${MESSAGE}"
    local content=$(cat "${HOME_FOLDER}/raid")
    sendMessageToTelegram "${content}"
fi
}


function main() 
{
    [[ $EUID -ne 0 ]] && sendMessageToTelegram "Error: ${0} must be run as root!" && exit 1
    get_hdsentinel    
    formatData
    checkProblemDisk
    CheckRaid
    cd "${HOME_FOLDER}" && rm -f sd* report
}
main "${@}"