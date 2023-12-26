#!/bin/bash
 
dn=$1

result=`ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b "$dn" -s base`
cn=`echo "$result" | grep "cn: "`
description=`echo "$result" | grep "description: "`
members=`echo "$result" | grep "member: "`

dialog  --backtitle "System Information" \
        --title "group detail" \
        --msgbox "dn: $dn\n$description\n$cn\n$members" 20 70
