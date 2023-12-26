#!/bin/bash 

exec 3>&1

value=$(dialog --ok-label "Submit" \
          --backtitle "Ldap Managment" \
          --title "search in users" \
          --form "input pattern" \
          20 70 0 \
          "search" 1 1        ""   1 15 40 0 \
2>&1 1>&3)
exit_code=$?
exec 3>&-

if [ -f '/tmp/search_result' ] ; then 
	: > /tmp/search_result
else	
	touch /tmp/search_result
fi
 
if [ $exit_code -eq 0  ] ; then
	result=`ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b dc=nit,dc=ir "(&(objectclass=inetOrgPerson)(|(uid=$value)(cn=$value)(homeDirectory=$value)(loginShell=$value)(givenName=$value)(dn=$value)(sn=$value)(gidNumber=$value)(uidNumber=$value)))"`
	echo "$result" | grep "dn: " | sed 's/dn: //' > /tmp/users_dn
	
	grep -q 'dc' /tmp/users_dn
	
	if [ $? -eq 0 ] ; then	
	while read user
	do
		user_detail=`ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b "$user" -s base`		
		user_groups=`ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b dc=nit,dc=ir "(&(objectclass=groupOfNames)(member=$user))" | grep "cn: "`
		echo "$user_groups" > /tmp/user_groups
		
		# for solve a problem   echo command create a new line in file and its bug
		grep -q "cn: " /tmp/user_groups
		exit_code=$?
		if [ ! "$exit_code" -eq 0 ] ; then 
			: > /tmp/user_groups
		fi

		echo "$user_detail" | grep "dn: " >> /tmp/search_result
		echo "$user_detail" | grep "uid: " >> /tmp/search_result
		echo "$user_detail" | grep "sn: " >>/tmp/search_result
		echo "$user_detail" | grep "givenName: " >> /tmp/search_result
		echo "$user_detail" | grep "cn: " >> /tmp/search_result
		echo "$user_detail" | grep "uidNumber: " >> /tmp/search_result
		echo "$user_detail" | grep "gidNumber: " >> /tmp/search_result
		echo "$user_detail" | grep "loginShell: " >> /tmp/search_result
		echo "$user_detail" | grep "homeDirectory: " >> /tmp/search_result		
		echo "" >> /tmp/search_result 

		# check user is memeber of any groups or not
		if [ `wc -l /tmp/user_groups | gawk -F" " '{ print $1 }'` -eq 0 ] ; then
			echo -e "this user not in any groups\n" >> /tmp/search_result
		else 
			echo "groups that user member of it" >> /tmp/search_result
			echo "$user_groups" >> /tmp/search_result
			echo "" >> /tmp/search_result
		fi
		
	done < /tmp/users_dn
	else
		echo "no user found in database" > /tmp/search_result
	fi
	
	MESSAGE=`cat /tmp/search_result`	
        dialog  --backtitle "System Information" \
                --title "search result" \
                --msgbox "$MESSAGE" 20 70	
	
fi

source index.sh
