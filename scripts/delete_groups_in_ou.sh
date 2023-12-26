#!/bin/bash 

ou_dn=$1

ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b "$ou_dn"  "objectclass=groupOfNames" | grep "dn: " > /tmp/result 

if [ -f './ldif/delete_groups_from_ou.ldif' ] ; then 
	: > ./ldif/delete_groups_from_ou.ldif
else 
	touch ./ldif/delete_groups_from_ou.ldif
fi

while read -r line 
do
	echo "$line" >> ./ldif/delete_groups_from_ou.ldif
	echo -e "changetype: delete \n" >> ./ldif/delete_groups_from_ou.ldif
done < /tmp/result 

if [ ! `wc -l ./ldif/delete_groups_from_ou.ldif | gawk -F" " '{print $1}'` -eq 0 ] ; then 
	ldapmodify -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -f ./ldif/delete_groups_from_ou.ldif
fi
