#!/bin/bash
## Author : Kuriens Maliekal 	##
## Version : 1.0.2b		##
## Date : 11-07-2014		##

## Adding proxy logins

IP_LIST_URL="http://URL_OF_PORTAL_WITH_IP_LIST"
LOGIN_URL="http://LOGIN_URL"


export https_proxy="http://YOUR_PROXY_HOST_HERE:PROXY_PORT/";
printf "Enter proxy username : "
read proxy_user;
printf "Enter proxy password : "
read -s proxy_pass;
echo

## Function to get VLAN for IP

vlan() {
ip=$1;
case $ip in
	103.237.10[89]*)
		echo "VLAN 715"
		;;
	125.214.6[4-7]*) 
		echo "VLAN 301"
		;;
	125.214.7[2-5]*)
		echo "VLAN 302"
		;;
	111.67.1[2-5]*)
		echo "VLAN 303"
		;;
	111.67.1[6-9]*)
		echo "VLAN 304"
		;;
	111.67.2[0-3]*)
		echo "VLAN 305"
		;;
	111.67.2[8-9]*)
		echo "VLAN 306"
		;;
	223.27.1[6-7]*)
		echo "VLAN 307"
		;;
	223.27.1[8-9]*)
		echo "VLAN 308"
		;;
	223.27.2[0-1]*)
		echo "VLAN 309"
		;;
	223.27.2[2-3]*)
		echo "VLAN 310"
		;;
	223.27.2[4-5]*)
		echo "VLAN 311"
		;;
	223.27.15*)
		echo "VLAN 312"
		;;
	223.27.2[8-9]*)
		echo "VLAN 313"
		;;
	223.27.3[0-1]*)
		echo "VLAN 313"
		;;
	111.67.[2-3]*)
		echo "VLAN 314"
		;;
	111.67.2[6-7]*)
		echo "VLAN 630"
		;;
	111.67.3[0-1]*)
		echo "VLAN 648"
		;;
	223.27.2[0-1]*)
		echo "VLAN 871"
		;;
	223.27.2[2-3]*)
		echo "VLAN 872"
		;;
	*)
		echo "Unknown VLAN"
		;;

esac
}

## Function to get Firewall status for IP

hwf1() {
	i=$1;
	CMD="wget --proxy-user=\"$proxy_user\" --proxy-password=\"$proxy_pass\" -q -O \$_TMP_FILE --load-cookies=\$_COOKIE_FILE --no-check-certificate \$IP_LIST_URL\$i 2>/dev/null";
        eval "$CMD";
        CMD="lynx -dump -nolist --width 1000 \$_TMP_FILE";
        eval "$CMD" | grep -q "<address>";
        if [ $? -eq 0 ]
        then
        	HWF="\e[31m\e[1mLISTED\e[0m";
                echo -e "\e[1m$i\t\t-\t\t$(vlan "$i")\t\t-\t\t$HWF"
        else
                HWF="\e[32m\e[1mNOT LISTED\e[0m";
                echo -e "$i\t\t-\t\t$(vlan "$i")\t\t-\t\t$HWF"
        fi
}

hwf2() {
        i=$1;
        CMD="wget --proxy-user=\"$proxy_user\" --proxy-password=\"$proxy_pass\" -q -O \$_TMP_FILE --load-cookies=\$_COOKIE_FILE --no-check-certificate \$IP_LIST_URL\$i 2>/dev/null";
        eval "$CMD";
        CMD="lynx -dump -nolist --width 1000 \$_TMP_FILE";
        eval "$CMD" | grep -q "<address>";
        if [ $? -eq 0 ]
        then
                printf "LISTED"
        else
                printf "NOT LISTED";
        fi
}			

## Read WMS credentials from user
echo;
printf "Enter WMS username : "
read _USER;
printf "Enter WMS password : "
read -s _PASS;
echo;

## Creating cookie file
_COOKIE_FILE=$(mktemp);
_ROUTER_LIST_FILE=$(mktemp --suffix ".html");
_TMP_FILE=$(mktemp --suffix ".html");

## Saving session cookies
wget --proxy-user="$proxy_user" --proxy-password="$proxy_pass" -q --save-cookies $(echo "$_COOKIE_FILE") --keep-session-cookies --post-data="email=$_USER&password=$_PASS" --no-check-certificate "$LOGIN_URL" -O /dev/null 2>/dev/null;
CMD="wget --proxy-user=\"$proxy_user\" --proxy-password=\"$proxy_pass\" -q -O \$_ROUTER_LIST_FILE --load-cookies=\$(echo \"\$_COOKIE_FILE\") --no-check-certificate $IP_LIST_URL 2>/dev/null"
eval "$CMD"

## Storing router details in a variable
CMD="lynx -dump --width 1000 \$_ROUTER_LIST_FILE";
_CONTENTS=$(eval "$CMD");

## Checking if the user has successfully logged in
echo "$_CONTENTS" | grep -q "Logged in as";
if [ $? -ne 0  ]
then
	echo "";
	echo -e "\e[101m\e[37m\e[1mWMS Login failed\e[49m\e[39m\e[21m";
	echo "";
	exit 1;
fi

## Storing final formatted router list to variable
_ROUTER_LIST=$(echo "$_CONTENTS" | grep "hwh\|hwx\|hwv\|vmfw013" | awk '$3<$4 {print $1,$2}')

## Get preferred output from user
clear
echo "Enter the desired output format :"
echo ""
echo "1. Real time output"
echo "2. Spreadsheet friendly output"
echo "3. Quit"
echo ""
printf "(1/2/3)? : "
read -t 0.1 -N 255;
read ch;
case $ch in 
	1 )
## Real time output
		clear
		ips="";
		ct=0;
		tcount=$(echo "$_ROUTER_LIST" | wc -l);
		for i in $(echo "$_ROUTER_LIST" | awk '{print $1}')
		do
			clear;
			ct=$((ct+1));
			curstat=$((ct*50/tcount));
			remstat=$((50-curstat));
			echo "";
			echo -e "\t\tProgress";
			echo -e "\t\e[104m\e[93m";
			printf '[';
			printf '#%.s' echo `seq 2 $curstat`;
			printf ' %.s' echo `seq 2 $remstat`;
			printf ']';
			echo ""
			echo ""
			echo -e "\e[49m\e[39m";
			echo "Retrieving free IP addresses from $ct of $tcount routers...";
			CMD="wget --proxy-user=\"$proxy_user\" --proxy-password=\"$proxy_pass\" -q -O \$_TMP_FILE --load-cookies=\$_COOKIE_FILE --no-check-certificate \$IP_LIST_URL\$i 2>/dev/null"
			eval "$CMD";
		  	CMD="lynx -dump -nolist --width 1000 \$_TMP_FILE";
		  	ips="${ips}
$(eval "$CMD" | grep -v "Noble Park\|10.0." | grep "Remove Assignment" | awk '{print $4}' | sed -e 's/...$//g' | sort -n)";
		done
		ips="$(for i in `echo "$ips" | grep '^[0-9]'`
do
	printf "$i ";
	vlan $i;
done)"
		clear;	
		while true
		do
			echo "";
			echo "";
			echo "Search by :";
			echo "";
			echo "1. IP address";
			echo "2. VLAN";
			echo "";
			read -t 0.1 -N 255;
			printf "Enter your choice (1/2)? ";
			read ch;
			case $ch in
				1)
					clear; 
					printf "Enter network part of IP address to search [Blank for all, Ctrl+C to quit]: ";
					read ch;
					ch="$(echo $ch | sed -e 's/ *//g')";
					echo "";
					echo "";
					for i in $(echo "$ips" | grep "^[0-9]" | grep "^${ch}" | awk '{print $1}')
					do
						hwf1 $i;
					done
					;;
				2)
					clear;
					printf "Enter VLAN ID to search [Blank for all, Ctrl+C to quit]: ";
					read ch;
					ch="$(echo $ch | sed -e 's/ *//g')";
                                        echo "";
                                        echo "";
                                        for i in $(echo "$ips" | grep "^[0-9]" | grep "${ch}$" | awk '{print $1}')
                                        do
                                                hwf1 $i;
                                        done
                                        ;;
				*)
					echo "Invalid Choice!! Exiting...";
					exit 1;
			esac
		done
		;;
	2 )	
## Spreadsheet friendly output
		num=$(echo "$_ROUTER_LIST" | wc -l);
		n=1;
		_SHEET="";
		for i in $(echo "$_ROUTER_LIST" | awk '{print $1}')
		do
			clear;
			echo "${n}/${num} complete...";
		        CMD="wget --proxy-user=\"$proxy_user\" --proxy-password=\"$proxy_pass\" -q -O \$_TMP_FILE --load-cookies=\$_COOKIE_FILE --no-check-certificate \$IP_LIST_URL\$i 2>/dev/null"
		        eval "$CMD";
		        CMD="lynx -dump -nolist --width 1000 \$_TMP_FILE";
		        ips=$(eval "$CMD" | grep -v "Noble Park\|10.0." | grep "Remove Assignment" | awk '{print $4}' | sed -e 's/...$//g' | sort -n);
		        for j in $(echo "$ips")
		        do
		                _SHEET="$_SHEET
$(echo "$_ROUTER_LIST" | grep "^$i" | awk '{print $2}' | cut -d. -f1), ${j}, $(vlan "$j"), $(hwf2 $j)";
		        done
			((n++));
		done
		clear
		echo "****************************"
		echo "HW Node, IP Address, VLAN"
		echo ""
		echo "$_SHEET" | sort -t, -k 2,2n | sort -t. -k 2,2n -k 3,3n -k 4,4n;
		echo "****************************"
		;;
	3 )
		echo ""
		echo "Goodbye!!";
		echo ""
		exit 0;
		;;
	* )
		echo ""
		echo "Invalid option. Exiting."
		exit 1
		;;
esac
