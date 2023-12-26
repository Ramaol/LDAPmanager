#!/bin/bash

dn=$1
OLD_NAME=`echo "$dn" | gawk -F, '{print $1}' | gawk -F= '{print $2}'`
OLD_DESCRIPTION=`ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b "$dn" -s base | grep "description: " | sed 's/description: //'`

exec 3>&1

VALUES=$(dialog  --ok-label "Submit" \
	  --backtitle "Ldap Management" \
	  --title "create organization unit" \
	  --form "input your values" \
	20 70 0 \
	"new name" 1 1 	"$OLD_NAME" 	1 15 40 0 \
	"description" 3 1	"$OLD_DESCRIPTION"  	3 15 40 0 \
2>&1 1>&3)
exit_code=$?

exec 3>&-

if [ -f './ldif/rename_group.ldif' ] ; then
	: > ./ldif/rename_group.ldif
else
	touch ./ldif/rename_group.ldif
fi


if [ $exit_code -eq 0 ] ; then 

	echo "$VALUES" > /tmp/result

	i=1
	while read line 
	do 
		if [ $i -eq 1 ] ; then
			echo "dn: $dn" >> ./ldif/rename_group.ldif
			echo "changetype: modrdn" >> ./ldif/rename_group.ldif
			echo "newrdn: cn=$line" >> ./ldif/rename_group.ldif
			echo -e "deleteoldrdn: 1\n" >> ./ldif/rename_group.ldif
		elif [ $i -eq 2 ] ; then
			echo "dn: $dn" >> ./ldif/rename_group.ldif
			echo "changetype: modify" >> ./ldif/rename_group.ldif
			echo "replace: description" >> ./ldif/rename_group.ldif
			echo "description: $line" >> ./ldif/rename_group.ldif
		fi

		i=$[$i+1]
	done < /tmp/result

	ldapmodify -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -f ./ldif/rename_group.ldif > /tmp/rename_group.info 2> /tmp/rename_group.error	
	if [ $? -eq 0 ] ; then 
		MESSAGE=`cat /tmp/rename_group.info`
		dialog  --backtitle "openldap manage" \
			--title "successfull" \
			--msgbox "$MESSAGE" 20 70
	else
		MESSAGE=`cat /tmp/rename_group.error`
		dialog --backtitle "openldap manage" \
		       --title "operation failed" \
		       --msgbox "$MESSAGE" 20 70
	fi

	source editing.sh
else 
	source editing.sh
fi
