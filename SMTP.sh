#!/bin/bash
# Script check raid

##########################################################

# Display RAID status
rstat=$(cat /proc/mdstat)
host=$(hostname -I)

# Check for [U_] or [_U]
if ! egrep "\[.*_.*\]" /proc/mdstat  > /dev/null
then exit
fi

# email a report

echo "$rstat" + "$host" | mailx -v -r "monitor@vina-host.com" -s "RAID failure at `hostname`" -S smtp="e.vinahost.vn:587" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="monitor@vina-host.com" -S smtp-auth-password="GJPzluFUcJZn" -S ssl-verify=ignore support@vinahost.vn
