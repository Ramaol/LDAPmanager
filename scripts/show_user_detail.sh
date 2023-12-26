#!/bin/bash

dn=$1
result=`ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b "$dn" -s base`
dn=`echo "$result" | grep "dn: " | sed 's/dn: //'`
uid=`echo "$result" | grep "uid: " | sed 's/uid: //'`
sn=`echo "$result" | grep "sn: " | sed 's/sn: //'`
givenName=`echo "$result" | grep "givenName: " | sed 's/givenName: //'`
cn=`echo "$result" | grep "cn: " | sed 's/cn: //'`
uidNumber=`echo "$result" | grep "uidNumber: " | sed 's/uidNumber: //'`
gidNumber=`echo "$result" | grep "gidNumber: " | sed 's/gidNumber: //'`
loginShell=`echo "$result" | grep "loginShell: " | sed 's/loginShell: //'`
homeDirectory=`echo "$result" | grep "homeDirectory: " | sed 's/homeDirectory: //'`
userPassword=`echo "$result" | grep "userPassword:: " | sed 's/userPassword:: //'`


dialog  --backtitle "System Information" \
        --title "user detail" \
	--msgbox "dn: $dn\nuid: $uid\nsn: $sn\ngivenName: $givenName\ncn: $cn\nuidNumber: $uidNumber\ngidNumber: $gidNumbr\nloginShell: $loginShell\nhomeDirectory: $homeDirectory\nuserPassword (hashed): $userPassword " 20 70


