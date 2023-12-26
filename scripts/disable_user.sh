#!/bin/bash

dn=$1

echo "dn: $dn" > ./ldif/disable_user.ldif
echo "changetype: modify" >> ./ldif/disable_user.ldif
echo "add: objectClass" >> ./ldif/disable_user.ldif
echo -e "objectClass: top\n" >> ./ldif/disable_user.ldif

echo "add: objectClass" >> ./ldif/disable_user.ldif
echo -e "objectClass: LDAPsubentry\n" >> ./ldif/disable_user.ldif

echo "add: objectClass" >> ./ldif/disable_user.ldif
echo -e "objectClass: pwdPolicy\n" >> ./ldif/disable_user.ldif


echo "add: objectClass" >> ./ldif/disable_user.ldif
echo -e "objectClass: sunPwdPolicy\n" >> ./ldif/disable_user.ldif

echo "add: pwdAccountLockedTime" >> ./ldif/disable_user.ldif
echo -e "pwdAccountLockedTime: 000001010000Z\n" >> ./ldif/disable_user.ldif

ldapmodify -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -f ./ldif/disable_user.ldif 1> /tmp/disable_user.info 2> /tmp/disable_user.error

if [ $? -eq 0 ] ; then 
	MESSAGE=`cat /tmp/disable_user.info`	
        dialog  --backtitle "System Information" \
                --title "successfull" \
                --msgbox "account is disabled \n $MESSAGE" 20 70
else	
	MESSAGE=`cat /tmp/disable_user.error`	
        dialog  --backtitle "System Information" \
                --title "successfull" \
                --msgbox "error \n $MESSAGE" 20 70
fi

source edit_user_kind.sh $dn





