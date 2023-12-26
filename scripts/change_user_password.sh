#!/bin/bash

function check_password(){ 
	if [ `echo "$1" | gawk '{print length}'` -lt 6 ] ; then 
		echo true
	else 
		echo false
	fi
} 

dn=$1
exec 3>&1
VALUE=$(dialog --ok-label "Submit" \
          --backtitle "Ldap Managment" \
          --title "create organization" \
          --form "input user new password \n current user dn: $dn" \
          20 70 0 \
          "new password" 2 1        ""   2 15 40 0 \
2>&1 1>&3)
exit_code=$?
exec 3>&-
if [ $exit_code -eq 0 ] ; then
	check_password "$VALUE" > /tmp/new_password
	if [ `cat /tmp/new_password` == "true" ] ; then	
        	dialog  --backtitle "System Information" \
                	--title "successfull" \
                	--msgbox 'password can not longer than 6 character !!' 20 70
	else
		ldappasswd -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -s "$VALUE" "$dn" 1> /tmp/change_password.info 2> /tmp/change_password.error
		if [ $? -eq 0 ] ; then 
        		MESSAGE=`cat /tmp/change_password.info`
			dialog  --backtitle "System Information" \
                		--title "successfull" \
                		--msgbox "password change successfully \n $MESSAGE" 20 70
		else 
			MESSAGE=`cat /tmp/change_password.error`
        		dialog  --backtitle "System Information" \
                		--title "error" \
		                --msgbox "$MESSAGE" 20 70
		fi			
	fi
	rm /tmp/new_password
fi

source index.sh
