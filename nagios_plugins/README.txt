************
** README **
************

"check_mysql" nagios plugin checks all databases on a server and reports any corrupted tables or errors based on keywords provided. Following is the basic usage from command line.

===============
# /usr/local/nagios/libexec/check_mysql 
Usage : check_mysql -u <mysql_user> -p <mysql_pass> -c <comma_separated_critical_keywords> -w <comma_separated_warning_keywords>
===============

Basically, the script executes the following command to scan all databases on a server and restricts the output to only errors if found. 

===============
sudo mysqlcheck -uroot -ptestpass -s --all-databases
===============

You can pass keywords to the -c and -w flags for critical and warning alerts in nagios. If any of those keywords are found in the output of the command above, the appropriate alert is triggered in nagios. Critical alerts have the highest priority.

You can pass multiple keywords like the examples below.

===============
/usr/local/nagios/libexec/check_mysql -uroot -ptestpass -c"Corrupt,corrupt,error" -w"Warning,warn"
/usr/local/nagios/libexec/check_mysql -uroot -ptestpass -c"Corrupt,table corrupt,error in table" -w"Warning,locks with log tables"
===============

Enclose the keywords in double quotes if you need to check for a line or multiple words like the example above.

NOTE
----

1. The keywords are case sensitive.
2. If the script runs as the nagios user, ensure this user is provided privileges like below to run mysqlcheck command.

nagios ALL= NOPASSWD: /usr/bin/mysqlcheck


