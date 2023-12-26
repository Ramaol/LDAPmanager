#!/bin/bash

dn=$1

source delete_user_from_groups.sh $dn 

if [ -f './ldif/delete_user.ldif' ] ; then 
	: > ./ldif/delete_user.ldif 
else 
	touch ./ldif/delete_user.ldif
fi

echo "dn: $dn" >> ./ldif/delete_user.ldif
echo "changetype: delete" >> ./ldif/delete_user.ldif

ldapmodify -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -f ./ldif/delete_user.ldif 1> /tmp/delete_user.info 2> /tmp/delete_user.error

