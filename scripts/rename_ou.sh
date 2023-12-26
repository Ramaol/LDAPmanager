#!/bin/bash

dn=$1
OU_NAME=`echo "$1" | gawk -F, '{print $1}' | gawk -F= '{print $2}'`
exec 3>&1
VALUE=$(dialog --backtitle "openldap manage" \
      		--title "edit OU" \
                --form "input new name" \20 70 0 \
    		"new name: " 1 1    "$OU_NAME"        1 15 40 0 \
     		2>&1 1>&3)

exit_code=$?

exec 3>&-

echo "$VALUE" > /tmp/result
while read line 
do
	NEW_OU=$line
done < /tmp/result

if [ -f './ldif/rename_ou.ldif' ] ; then 
	: > ./ldif/rename_ou.ldif
else
	touch ./ldif/rename_ou.ldif
fi

if [ $exit_code -eq 0 ] ; then 
	echo "dn: $dn" >> ./ldif/rename_ou.ldif
	echo "changetype: modrdn" >> ./ldif/rename_ou.ldif
	echo "newrdn: ou=$NEW_OU" >> ./ldif/rename_ou.ldif
	echo "deleteoldrdn: 1" >> ./ldif/rename_ou.ldif
	ldapmodify -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -f ./ldif/rename_ou.ldif 1> /tmp/rename_ou.info 2> /tmp/rename_ou.error	
	if [ $? -eq 0 ] ; then 
		MESSAGE=`cat /tmp/rename_ou.info`
		dialog  --backtitle "openldap manage" \
			--title "successfull" \
			--msgbox "$MESSAGE" 20 70
	else
		MESSAGE=`cat /tmp/rename_ou.error`
		dialog --backtitle "openldap manage" \
		       --title "error" \
		       --msgbox "$MESSAGE" 20 70
	fi
	source index.sh
else 
	source index.sh
fi
