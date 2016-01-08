#!/bin/bash
########################
## Author : Kuriens   ##
## Date : 11 Oct 2014 ##
########################

## Variables to adjust

SQLUSER=""
SQLPASS=""

export TZ=Asia/Kolkata

## No modifications required after this line

usage() {
echo "Usage: $0 -o <output_file> -c <comma_separated_critical_keywords> -w <comma_separated_warning_keywords>"
exit 0
}

_FILE=$1

while getopts ":o:w:c:" opt
do
        case $opt in
                o)
                _FILE=$OPTARG;
                ;;
                w)
                W=$OPTARG;
                ;;
                c)
                C=$OPTARG;
                ;;
                *)
                echo "Invalid arguments passed"
                usage;
                ;;
        esac
done

if [ -z "$W" ] || [ -z "$C" ]
then
        usage;
fi

if [ ! -f $_FILE ] 
then
        touch $_FILE >/dev/null 2>&1 || (echo "`date '+%Y-%m-%d %T'` => UNKNOWN :: Unable to create $_FILE"; exit 1)
        chmod 644 $_FILE >/dev/null 2>&1 || (echo "`date '+%Y-%m-%d %T'` => UNKNOWN :: Unable to apply permissions to $_FILE"; exit 1)
fi

MAXLOAD=`cat /proc/cpuinfo | grep processor | wc -l`

FLAG=0

while true
do
        CURLOAD5=`uptime | awk '{print $(NF-1)}' | cut -d. -f1`
        CURLOAD1=`uptime | awk '{print $(NF-2)}' | cut -d. -f1`

        if [ $((CURLOAD5/2)) -le $MAXLOAD ] && [ $((CURLOAD1/2)) -le $MAXLOAD ]
        then
                FLAG=1
        fi

        if [ $FLAG -ne 0 ]
        then
                if [ -f /var/run/mysqldbcheck.pid ]
                then
                        echo "`date '+%Y-%m-%d %T'` => UNKNOWN :: PID file already exists." | tee $_FILE
                        exit 1
                else
                        touch /var/run/mysqldbcheck.pid || (echo "`date '+%Y-%m-%d %T'` => UNKNOWN :: Unable to create PID file." | tee $_FILE; exit 1)
                        echo $$ > /var/run/mysqldbcheck.pid || (echo "`date '+%Y-%m-%d %T'` => UNKNOWN :: Unable to write to PID file." | tee $_FILE; exit 1)
                fi

                if [ ${#SQLUSER} -eq 0 ]
                then
                        mysqlcheck -s --all-databases > $_FILE
                        rm -f /var/run/mysqldbcheck.pid || (echo "`date '+%Y-%m-%d %T'` => UNKNOWN :: Unable to remove PID file." | tee $_FILE; exit 1)
                        break
                else
                        mysqlcheck -u $SQLUSER -p $SQLPASS -s --all-databases > $_FILE
                        rm -f /var/run/mysqldbcheck.pid || (echo "`date '+%Y-%m-%d %T'` => UNKNOWN :: Unable to remove PID file." | tee $_FILE; exit 1)
                        break
                fi
        fi

        echo "`date '+%Y-%m-%d %T'` => UNKNOWN :: Load on $(hostname -f) is high. Will check later." | tee $_FILE
        sleep 120
done

# Initialize variables

crt=$(echo "$C" | sed -e 's/\,/\\|/g');
warn=$(echo "$W" | sed -e 's/\,/\\|/g');
flag=0;

tmp=`cat $_FILE | grep -i -B1 '^note'`
if [ ${#tmp} -ne 0 ]
then
        _OUT=`cat $_FILE | grep -v "$tmp"`
else
        _OUT=`cat $_FILE`
fi

#CRITICAL
echo "$_OUT" | grep -iq "$crt";
if [ $? -eq 0 ]

then
        echo "`date '+%Y-%m-%d %T'` => CRITICAL :: 
" $_OUT | grep -i "$crt" | tee $_FILE
        flag=1;
        exit 2;
fi

#WARNING
echo "$_OUT" | grep -iq "$warn";
if [ $? -eq 0 ]
then
        echo "`date '+%Y-%m-%d %T'` => WARNING :: 
" $_OUT | grep -i "$warn" | tee $_FILE
        flag=1;
        exit 1;
fi

if [ ${#_OUT} -eq 0 ]
then
        echo "`date '+%Y-%m-%d %T'` => OK :: 
No errors found" | tee $_FILE
        exit 0;
elif [ $flag -eq 0 ]
then
        echo "`date '+%Y-%m-%d %T'` => OK :: 
" $_OUT | tee $_FILE
        exit 3;
fi
