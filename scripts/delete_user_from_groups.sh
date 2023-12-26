#!/bin/bash

dn=$1
ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b dc=nit,dc=ir "(&(objectclass=groupOfNames)(member=$dn))" | grep "dn: " | sed 's/dn: //' > /tmp/result


if [ -f './ldif/delete_user_from_groups.ldif' ] ; then
	: > ./ldif/delete_user_from_groups.ldif
else 
	touch ./ldif/delete_user_from_groups.ldif
fi

while read line 
do
	# check if group hust has one member 
	group_detail=`ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b "$line" -s base`
	member_count=`echo "$group_detail" | grep "member: " | wc -l | gawk -F" " '{print $1}'`

	if [ $member_count -eq 1 ] ; then 
		echo "dn: $line" >> ./ldif/delete_user_from_groups.ldif
		echo "changetype: delete" >> ./ldif/delete_user_from_groups.ldif
		echo "" >> ./ldif/delete_user_from_groups.ldif
	else	
		echo "dn: $line" >> ./ldif/delete_user_from_groups.ldif
		echo "changetype: modify" >> ./ldif/delete_user_from_groups.ldif
		echo "delete: member" >> ./ldif/delete_user_from_groups.ldif
       		echo "member: $dn" >> ./ldif/delete_user_from_groups.ldif
		echo ""	>> ./ldif/delete_user_from_groups.ldif
	fi 
done < /tmp/result

ldapmodify -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -f ./ldif/delete_user_from_groups.ldif 1> /tmp/delete_user_from_groups.info 2> /tmp/delete_user_from_groups.error





