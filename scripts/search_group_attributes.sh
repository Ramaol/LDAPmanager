#!/bin/bash 

exec 3>&1

value=$(dialog --ok-label "Submit" \
          --backtitle "Ldap Manage" \
          --title "search groups attribute" \
          --form "input your value" \
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
	result=`ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b dc=nit,dc=ir "(&(objectclass=groupOfNames)(|(cn=$value)(dn=$value)(description=$value)(member=$value)))" | grep "dn: " | sed 's/dn: //'`
	echo "$result" > /tmp/group_dn
	
	while read group
	do
		group=`ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b "$group" -s base `
		echo "$group" | grep "dn: " >> /tmp/search_result
 		echo "$group" | grep "cn: " >> /tmp/search_result
		echo "$group" | grep "description: " >> /tmp/search_result
		echo -e "$group\n\n" | grep "member: " >> /tmp/search_result
		
	done < /tmp/group_dn 

	MESSAGE=`cat /tmp/search_result`	
        dialog  --backtitle "openldap manage" \
                --title "search result" \
                --msgbox "$MESSAGE" 20 70
	
fi

source index.sh
