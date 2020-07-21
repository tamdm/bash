#!/usr/bin/env bash

path=/etc/ssh/sshd_config


echo -e "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo -e "[+] This script is being used for hardening security on Centos 6/7\n"

function backup() {
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
cp /etc/sysconfig/iptables /etc/sysconfig/iptables.backup
}

function changeSSH_Port(){
if [ -e $path ];then
    [ -z "`grep ^Port /etc/ssh/sshd_config`" ] && ssh_port=22 || ssh_port=`grep ^Port $path | awk '{print $2}'`
    while :; do
    read -p "Please input SSH port(Default: $ssh_port): " SSH_PORT
    [ -z "$SSH_PORT" ] && SSH_PORT=$ssh_port
        if [ $SSH_PORT -eq 22 >/dev/null 2>&1 -o $SSH_PORT -gt 1024 >/dev/null 2>&1 -a $SSH_PORT -lt 65535 >/dev/null 2>&1 ];then
                break
        else
            echo "${CWARNING}input error! Input range: 22,1025~65534${CEND}"
                fi
        done

        if [ -z "`grep ^Port /etc/ssh/sshd_config`" -a "$SSH_PORT" != '22' ];then
                sed -i "s@^#Port.*@&\nPort $SSH_PORT@" $path
        elif [ -n "`grep ^Port /etc/ssh/sshd_config`" ];then
                sed -i "s@^Port.*@Port $SSH_PORT@" $path
        fi
fi
service sshd restart || systemctl restart sshd
}

function hardening() {
    if [ -n "`grep ^#PasswordAuthentication /etc/ssh/sshd_config`" ]; then
        sed -re 's/^(\#)(PasswordAuthentication)([[:space:]]+)(.*)/\2\3no/' -i /root/test
    elif [ -n "`grep ^PasswordAuthentication /etc/ssh/sshd_config`" ]; then
        sed -re 's/^(PasswordAuthentication)([[:space:]]+)(.*)/\1\2no/' -i /root/test
    else
        :
    fi

    if [ -n "`grep ^#X11Forwarding /etc/ssh/sshd_config`" ]; then
        sed -re 's/^(\#)(X11Forwarding)([[:space:]]+)(.*)/\2\3no/' -i /root/test

    elif [ -n "`grep ^X11Forwarding /etc/ssh/sshd_config`" ]; then
        sed -re 's/^(X11Forwarding)([[:space:]]+)(.*)/\1\2no/' -i /root/test

    else
        :
    fi

    if [ -n "`grep ^#AllowTcpForwarding /etc/ssh/sshd_config`" ]; then
        sed -re 's/^(\#)(AllowTcpForwarding)([[:space:]]+)(.*)/\2\3no/' -i /root/test

    elif [ -n "`grep ^AllowTcpForwarding /etc/ssh/sshd_config`" ]; then
        sed -re 's/^(AllowTcpForwarding)([[:space:]]+)(.*)/\1\2no/' -i /root/test

    else
        :
    fi

    echo """Protocol 2
HashKnownHosts yes
Ciphers aes128-ctr,aes192-ctr,aes256-ctr
MACs hmac-sha2-256,hmac-sha2-512,hmac-sha1 """ >> $path




}

# Main program
while true
do

changeSSH_Port
# hardening

exit 1
done
