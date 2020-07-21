#/usr/bin/env bash

# Script can probably be run with Centos 6, Ubuntu 18.04.2, Proxmox 5.1-3, Proxmox 6 , Debian 9...
# Keep it updating
# Send alert to Telegram Group with BotChat ID and Group ID
# Change token and group ID in sendAlert Function

host=$(hostname -I)
date=`date '+%d-%B, %Y'`
problems=0

function isRoot () {
    if [ "$EUID" -ne 0 ]; then
        return 1
    fi
}
function checkOS () {
    if [[ -e /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        if [[ "$ID" == "debian" ]]; then
            /sbin/zpool status > /dev/null 2>&1
            if [[ $? -eq 0 ]]; then
                OS="proxmox"
            else
                OS="debian"
            fi
        elif [[ "$ID" == "ubuntu" ]]; then
            OS="ubuntu"
        elif [[ "$ID" == "centos" ]]; then
            OS="centos"
        fi
    elif [ -e /etc/redhat-release ]; then
        OS="centos6"
    else
        echo "Looks like you aren't running this installer on a Debian, Ubuntu, Fedora, CentOS, Arch Linux or any Linux system"
        echo "Please inform to Administrator to determine issue"
        exit 1
    fi
}
function checkUpdateProxmox(){
    local cond=$(egrep -i 'pve-no-subscription' /etc/apt/sources.list)
    if [ ! "${cond}" ]; then
        if [ ! -e /root/pve-enterprise.list ]; then
            echo "deb http://download.proxmox.com/debian stretch pve-no-subscription" >> /etc/apt/sources.list
            mv /etc/apt/sources.list.d/pve-enterprise.list /root/ > /dev/null 2>&1
            apt-get update > /dev/null || apt update > /dev/null
        fi
    fi
}
function installCurl () {
    which curl > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        apt-get install curl -y > /dev/null 2>&1 || apt install curl -y > /dev/null 2>&1 || yum install curl -y > /dev/null 2>&1
    fi
}
function sendAlert() {
    local token_id="1126087523:AAG38a7Fm_ZJDey1LXFgdJZLH_WLYpUeWtk"
    local group_id="-409955694"
    local URL="https://api.telegram.org/bot$token_id/sendMessage"
    curl -s -X POST $URL -d chat_id=$group_id -d text="
    RAID VOLUMES HAVE FAILED STATUS - Please call System Administrator NOW!!!
    ******************************************
    IP ADDRESS IS: $host
    ******************************************
    $rstat
    ******************************************
    $date" > /dev/null
}
function initialCheck () {
    if ! isRoot; then
        echo "Sorry, you need to run this as root"
        exit 1
    fi

    checkOS
    # Check RAID Failed for OS using mdadm
    if [[ $OS =~ (ubuntu|centos|debian|centos6) ]]; then
        installCurl
        condition=$(egrep "\[.*_.*\]" /proc/mdstat)
        if  [ $? -eq 0 ] ; then
            local rstat=$(cat /proc/mdstat) > /dev/null
            sendAlert
        fi






    # Check RAID Failed for OS using zpool






    elif [[ $OS =~ (proxmox) ]]; then
        checkUpdateProxmox
        installCurl
        condition=$(/sbin/zpool status | egrep -i '(state: DEGRADED|state: FAULTED|state: OFFLINE|state: UNAVAIL|state: REMOVED|state: FAIL|state: DESTROYED|corrupt|cannot|unrecover)')
        if [ $? -eq 0 ]; then
            problems=1

        fi
        if [ ${problems} -eq 0 ]; then
           errors=$(/sbin/zpool status | grep ONLINE | grep -v state | awk '{print $3 $4 $5}' | grep -v 000)
           if [ "${errors}" ]; then
                problems=1
            fi
        fi
        if [ ${problems} -ne 0 ]; then
            local rstat=$(/sbin/zpool status) > /dev/null
            sendAlert
        fi
    fi
    exit 1
}

initialCheck

