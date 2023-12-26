#!/bin/bash 

ou_dn=$1

ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b "$ou_dn"  "objectclass=inetOrgPerson" | grep "dn: " | sed 's/dn: //' > /tmp/users_for_delete 

while read -r user
do
	source delete_user_type2.sh $user
done < /tmp/users_for_delete



