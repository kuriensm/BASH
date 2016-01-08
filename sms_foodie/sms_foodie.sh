#!/bin/bash
## Author: Kuriens Maliekal
## 160by2 SMS Gateway

## Retrieving data from foodie.inhouse.net and splitting in two (this SMS crap has 160 char limit. SIGH!!)

_FOOD=$(wget -qO- http://FOOD_MENU_URL_HERE | grep autoList | sed -e 's/category":"Tomorrow.*$//g' -e 's/autoList\|=\|\[\|\:\|{\|\"\|category\|label\|\}\|Today//g' -e 's/\,\,/\n/g' -e 's/^ *\,//g' -e 's/,$//g');
_FOOD1=$(date +%D; echo "$_FOOD" | head -2);
_FOOD2=$(date +%D; echo "$_FOOD" | tail -2);

## Log in to 160by2
wget -q -O /dev/null --keep-session-cookies --save-cookies cookies.txt --post-data="username=MY_MOB_HERE&password=MY_PASS_HERE" http://www.160by2.com/re-login

## Initialize POST data
_SESS=$(cat cookies.txt | grep JSESSIONID | cut -d~ -f2)
_MOB=$(wget -qO- --load-cookies cookies.txt http://www.160by2.com/SendSMS?id=$(cat cookies.txt | grep JSESSIONID | cut -d~ -f2) | grep "Enter Mobile Number or Name" | sed -e 's/.*name=\"//g' | cut -d\" -f1)
_HID=$(wget -qO- --load-cookies cookies.txt http://www.160by2.com/SendSMS?id=$(cat cookies.txt | grep JSESSIONID | cut -d~ -f2) | grep "input type=\"hidden\" name=" | sed -e 's/.*id\=\"//g' | cut -d\" -f1)

## Additional Cookies to pass
_ADCOOK=$(echo ".160by2.com	TRUE	/	FALSE	1465928366	__gads	ID=4707eb1307b37856:T=1402856366:S=ALNI_MZdHOMqAqvG5PDf3FS7CkLgoz0Vyg
www.160by2.com	FALSE	/	FALSE	1465928366	adCookie	2
www.160by2.com	FALSE	/	FALSE	1465928366	shiftpro	axisproapril8th
.160by2.com	TRUE	/	FALSE	1465928366	_ga	GA1.2.2144927074.1402856366")

## Add additional cookies to cookie file
echo "$_ADCOOK" >> cookies.txt

## Sending messages
for i in $(cat mob.txt | grep '^[0-9]' | awk '{print $1}')
do
	wget -q -O /dev/null --load-cookies cookies.txt --post-data="hid_exists=no&fkapps=SendSMSDec19&maxwellapps=$_SESS&UgadHieXampp=ugadicome&aprilfoolc=HoliWed27&janrepu=April3wed&marYellundi=abcdef12345tops&by2Hidden=by2sms&feb2by2action=sdf5445fdg&grabit=applecut&shine=65000&diwali2013=november3&$_HID=&$_MOB=$i&sendSMSMsg=$_FOOD1" http://www.160by2.com/SendSMSDec19
	sleep 20;
	wget -q -O /dev/null --load-cookies cookies.txt --post-data="hid_exists=no&fkapps=SendSMSDec19&maxwellapps=$_SESS&UgadHieXampp=ugadicome&aprilfoolc=HoliWed27&janrepu=April3wed&marYellundi=abcdef12345tops&by2Hidden=by2sms&feb2by2action=sdf5445fdg&grabit=applecut&shine=65000&diwali2013=november3&$_HID=&$_MOB=$i&sendSMSMsg=$_FOOD2" http://www.160by2.com/SendSMSDec19
	sleep 20
done