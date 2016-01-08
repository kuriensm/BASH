#!/bin/bash
## Author : Kuriens
## Date : 17 Oct 2014

## Description : Script to send log out alerts to display.

## Variables to adjust

LOGIN_URL="http://LOGIN_URL"
SUBMIT_URL="http://FORM_SUBMIT_URL"

## No changes required below this line

_COOKIE_FILE=$(mktemp --suffix=.cookie)
_HTML_FILE=$(mktemp --suffix=.html)

check() {
login_time=$1;
while true
do
	current_time=$(date +%s);
	diff=$((current_time-login_time));
	if [ $diff -gt 28800 ]
	then
		kdialog --title "Shift time elapsed : $((diff/60/60)) hours" --passivepopup "Your shift is over. Please log out." 100000000
	fi
	
	sleep 30;
done
}

_USER=$(kdialog --inputbox "Enter username" $USER)
_PASS=$(kdialog --password "Enter password")
month=$(date +%B | awk '{print substr($0,0,3)}');
year=$(date +%Y);
echo
echo
new_month=$(kdialog --inputbox "Enter month [Jan-Dec]" $month)
new_year=$(kdialog --inputbox "Enter year" $year)

wget -q --save-cookies $_COOKIE_FILE --keep-session-cookies --post-data="action=login&username=$_USER&password=$_PASS&Login=" --no-check-certificate $LOGIN_URL -O /dev/null 2>/dev/null

if [ ! -z $new_month ] 
then
	month=$new_month;
fi
if [ ! -z $new_year ] 
then
	year=$new_year;
fi

wget -q --load-cookies=$_COOKIE_FILE --post-data="option_type=login_records&month=$month&year=$year" --no-check-certificate $SUBMIT_URL -O $_HTML_FILE 2>/dev/null

_CONTENT=$(lynx --width 1000 --dump $_HTML_FILE | grep -i "Reason unknown" | tail -1);
_LOGIN_TIME_TMP=$(echo "$_CONTENT" | awk {'print $1,$2'});
echo "$_LOGIN_TIME_TMP" | grep -iq "$year"
if [ $? -ne 0 ]
then
	notify-send -u critical "Either you have already logged out or you did not log in!!!" -t 100000000
	exit 1;
fi
_LOGIN_TIME=$(date -d "$_LOGIN_TIME_TMP" +%s);
check $_LOGIN_TIME &
