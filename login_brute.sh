#!/bin/bash
# Author : Kuriens Maliekal
# Date : 12-Apr-2015
# Description : Block IP addresses that exceed a limit on the number of POST requests to an URL in a given interval

# Variables to adjust

CONN_LIMIT=50; # Max number of POST requests to an url in the INTERVAL
INTERVAL=1; # In minutes
NGINX_LOG="/var/log/nginx/log/access.log"; # Nginx access log
OUR_IP="1.2.3.4|4.3.2.1|8.8.8.8"; # IP addresses to exclude

# Main

search=$(date -d"-$((INTERVAL)) min" +%d/%b/%Y:%H:%M:);
line_no=$(grep -m1 -n $search $NGINX_LOG | cut -d: -f1);
data=$(tail -n +$((line_no)) $NGINX_LOG | awk '$6~"POST" {print $1, $7}' | egrep -v $OUR_IP | sort | uniq -c | sort -n);
IP2BLOCK=$(echo "$data" | awk -v lim="$CONN_LIMIT" '{if($1>lim) print $2}');
if [ ${#IP2BLOCK} -ne 0 ]
then
        for i in $(echo "$IP2BLOCK")
        do
                logger "${0}: $i triggered for making $(echo "$data" | grep $i | awk '{print $1}') connections in $INTERVAL minutes";
#               /sbin/iptables -A INPUT -s "$i" -j DROP;
        done
service iptables-persistent save 2>&1 /dev/null;
fi
