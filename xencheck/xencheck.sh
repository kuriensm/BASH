#!/bin/bash

##Decrypt xen host list 

function decrypt {
_FILE=$1;
_PASS=$2;
_CMD="expect -c '
set timeout 5 ;
log_user 0 ;
spawn openssl enc -d -bf-cbc -in $_FILE ;
expect assword ;
send \"$_PASS\\n\" ;
interact
'"
eval "$_CMD"
}

function diskchk {
_HOST=$1 ;
_PASS=$2 ;
_CMD="expect -c '
log_user 0 ;
spawn ssh -o StrictHostKeyChecking=no root@$_HOST \"df -lh | grep \\\"sr-mount\\\"\" ;
expect assword ;
send \"$_PASS\\n\" ;
interact
'"
eval "$_CMD"
}

##Memory check function

function memchk {
_HOST=$1 ;
_PASS=$2 ;
_CMD="expect -c '
log_user 0 ;
spawn ssh -o StrictHostKeyChecking=no root@$_HOST \"xe host-compute-free-memory\" ;
expect assword ;
send \"$_PASS\\n\" ;
interact
'"
eval "$_CMD"
}

_FILE=$1;
_H=$2;
if [ -z "$_FILE" ] || [ ! -f "$_FILE" ]
then
	echo -e "\nNo arguments provided\n"
	echo -e "Usage : ./xencheck.sh [enc_file] {xen_host}\n"
	echo -e "Required enc_file = Encrypted file containing Xen node credentials"
	echo -e "Optional xen_host = Xen node IP to check (default is all)"
	exit 1
fi

printf "Enter decryption key : "
read -s _PASS
echo
_CONTENTS=$(decrypt $_FILE $_PASS);

echo "$_CONTENTS" | grep -q "bad decrypt"
if [ $? -eq 0 ]
then
	echo -e "\nInvalid decryption key"
	exit 1
fi

echo "$_CONTENTS" | grep -q "bad magic number"
if [ $? -eq 0 ]
then
        echo -e "\nInvalid or corrupted file !"
        exit 1
fi

if [ ! -z "$_H" ]
then
	_CONTENTS=$(echo "$_CONTENTS" | grep $_H)
	if [ $? -ne 0 ]
	then
		echo -e "\nXen node not found"
		exit 1
	fi
fi
_CONTENTS=$(echo "$_CONTENTS" | grep '^[0-9]')
echo -e "\n\n============"
echo -e "Host, Disk, Memory \n"
len=$(echo "$_CONTENTS" | wc -l)
for i in $(seq 1 $len)
do
	host=$(echo "$_CONTENTS" | sed -n "$i"p | awk '{print $1}');
	pass=$(echo "$_CONTENTS" | sed -n "$i"p | awk '{print $2}');
	_DSK=$(diskchk $host $pass | grep "[0-9]" | awk '{print $3}');
	_MEM=$(memchk $host $pass | grep "[0-9]" | sed -e 's/ *//g' -e 's/.$//g');
	_MEM=$(expr $_MEM / 1024);
	_MEM=$(expr $_MEM / 1024);
	_MEM=$(expr $_MEM / 1024);
	echo "$host, ${_DSK}B, ${_MEM}GB"
done
echo "============"
