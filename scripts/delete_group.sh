#!/bin/bash

dn=$1

if [ -f './ldif/delete_group.ldif' ] ; then 
	: > ./ldif/delete_group.ldif 
else 
	touch ./ldif/delete_group.ldif
fi

echo "dn: $dn" >> ./ldif/delete_group.ldif
echo "changetype: delete" >> ./ldif/delete_group.ldif

ldapmodify -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -f ./ldif/delete_group.ldif 1> /tmp/delete_group.info 2> /tmp/delete_group.error

if [ $? -eq 0 ] ; then 
	MESSAGE=`cat /tmp/delete_group.info`	
        dialog  --backtitle "System Information" \
                --title "successfull" \
                --msgbox "$MESSAGE" 20 70
else
	MESSAGE=`cat /tmp/delete_group.error`	
        dialog  --backtitle "System Information" \
                --title "successfull" \
                --msgbox "$MESSAGE" 20 70
fi

