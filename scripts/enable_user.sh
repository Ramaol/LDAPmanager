#!/bin/bash

dn=$1
objectClass: top
objectClass: LDAPsubentry
objectClass: pwdPolicy
objectClass: sunPwdPolicy

echo "dn: $dn" > ./ldif/enable_user.ldif
echo "changetype: modify" >> ./ldif/enable_user.ldif
echo "delete: objectClass" >> ./ldif/enable_user.ldif
echo -e "objectClass: top\n" >> ./ldif/enable_user.ldif

echo "delete: objectClass" >> ./ldif/enable_user.ldif
echo -e "objectClass: LDAPsubentry\n" >> ./ldif/enable_user.ldif

echo "delete: objectClass" >> ./ldif/enable_user.ldif
echo -e "objectClass: pwdPolicy\n" >> ./ldif/enable_user.ldif


echo "delete: objectClass" >> ./ldif/enable_user.ldif
echo -e "objectClass: sunPwdPolicy\n" >> ./ldif/enable_user.ldif

echo "delete: pwdAccountLockedTime" >> ./ldif/enable_user.ldif
echo -e "pwdAccountLockedTime: 000001010000Z\n" >> ./ldif/enable_user.ldif

ldapmodify -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -f ./ldif/enable_user.ldif 1> /tmp/enable_user.info 2> /tmp/enable_user.error

if [ $? -eq 0 ] ; then 
	MESSAGE=`cat /tmp/enable_user.info`	
        dialog  --backtitle "System Information" \
                --title "successfull" \
                --msgbox "account is enabled \n $MESSAGE" 20 70
else	
	MESSAGE=`cat /tmp/enable_user.error`	
        dialog  --backtitle "System Information" \
                --title "successfull" \
                --msgbox "error \n $MESSAGE" 20 70
fi

source edit_user_kind.sh $dn





