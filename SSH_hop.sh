#################
###VPN LOGGING###
#################

##Author : Kuriens##


##Checking if local machine is connected via SSH##

if [ ! -z "$SSH_CLIENT" ]
then
{
        read -t 0.5 -N 255; # Clears the keyboard buffer.
	clear;
        echo "Enter the remote node IP: ";
        read ip;
        echo "Enter the user to log in as: ";
        read user;
        echo -e "\n\n";
        ssh -oStrictHostKeyChecking=no "$user"@"$ip";
        PID=$(ps -ef | grep $USER | grep 172.17 | grep HOP_SERVER_HOST_HERE | awk '{print $2}');
        echo -e "\n Good bye !!\n";
        sleep 1;
        kill -3 $PID;
}
fi


##Aliases##

_IP=$(/sbin/ifconfig | grep "addr:172.17" | awk '{print $2}' | cut -d: -f2);
logvpn() {
        if [ ! -z "$1" ]
        then
        {
                _ssh="ssh -oStrictHostKeyChecking=no HOP_SERVER_HOST_HERE -l $1 -t 'echo -e \"\nEnter your hop server password: \n\"; ssh2 -oStrictHostKeyChecking=no $_IP -l $USER -t '. ~/.bashrc''";
                eval "$_ssh";
        }
        else
        {
                echo -e "\nNo hop server username provided !!";
                echo -e "\nUsage: logvpn <hopserver_username>"
                echo -e "Example: logvpn kuriens.sm\n"
        } 
        fi
}
