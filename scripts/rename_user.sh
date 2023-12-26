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


if [ -f './ldif/rename_user.ldif' ] ; then 
	: > ./ldif/rename_user.ldif
else 
	touch  ./ldif/rename_user.ldif
fi

exec 3>&1

VALUES=$(dialog --ok-label "Submit" \
          --backtitle "Ldap Managment" \
          --title "create organization" \
          --form "input your values \n current location: $dn" \
          20 90 0 \
          "uid" 1 1        "$uid"   1 15 80 0 \
	  "sn" 2 1         "$sn"    2 15 40 0 \
	  "givenName" 3 1         "$givenName"    3 15 40 0 \
	  "cn" 4 1         "$cn"    4 15 40 0 \
	  "uidNumber" 5 1         "$uidNumber"    5 15 40 0 \
	  "gidNumber" 6 1         "$gidNumber"    6 15 40 0 \
	  "loginShell" 7 1         "$loginShell"    7 15 40 0 \
	  "homeDirectory" 8 1         "$homeDirectory"    8 15 40 0 \
2>&1 1>&3)

exit_code=$?
exec 3>&-

if [ $exit_code -eq 0 ] ; then
	
	echo "$VALUES" > /tmp/result
	i=1
	while read line 
	do
		if [ $i -eq 1 ] ; then 
			if [ "$line" != "$uid" ] ; then
				new_uid=$line
				flag=1
			else 
				flag=0
			fi
		elif [ $i -eq 2 ] ; then
			echo "dn: $dn" > ./ldif/rename_user.ldif
			echo "changetype: modify" >> ./ldif/rename_user.ldif
			echo "replace: sn" >> ./ldif/rename_user.ldif
		       	echo -e "sn: $line\n" >> ./ldif/rename_user.ldif
		elif [ $i -eq 3 ] ; then 
			echo "dn: $dn" >> ./ldif/rename_user.ldif
			echo "changetype: modify" >> ./ldif/rename_user.ldif
			echo "replace: givenName" >> ./ldif/rename_user.ldif
			echo -e "givenName: $line\n" >> ./ldif/rename_user.ldif
		elif [ $i -eq 4 ] ; then 	
			echo "dn: $dn" >> ./ldif/rename_user.ldif
			echo "changetype: modify" >> ./ldif/rename_user.ldif
			echo "replace: cn" >> ./ldif/rename_user.ldif
			echo -e "cn: $line\n" >> ./ldif/rename_user.ldif
		elif [ $i -eq 5 ] ; then
			echo "dn: $dn" >> ./ldif/rename_user.ldif
			echo "changetype: modify" >> ./ldif/rename_user.ldif
		        echo "replace: uidNumber" >> ./ldif/rename_user.ldif  	
			echo -e "uidNumber: $line\n" >> ./ldif/rename_user.ldif	
		elif [ $i -eq 6 ] ; then
			echo "dn: $dn" >> ./ldif/rename_user.ldif
			echo "changetype: modify" >> ./ldif/rename_user.ldif
		        echo "replace: gidNumber" >> ./ldif/rename_user.ldif  	
			echo -e "gidNumber: $line\n" >> ./ldif/rename_user.ldif
		elif [ $i -eq 7 ] ; then 
			echo "dn: $dn" >> ./ldif/rename_user.ldif
			echo "changetype: modify" >> ./ldif/rename_user.ldif
			echo "replace: loginShell" >> ./ldif/rename_user.ldif
			echo -e "loginShell: $line\n" >> ./ldif/rename_user.ldif
		elif [ $i -eq 8 ] ; then 
			echo "dn: $dn" >> ./ldif/rename_user.ldif
			echo "changetype: modify" >> ./ldif/rename_user.ldif
			echo "replace: homeDirectory" >> ./ldif/rename_user.ldif
			echo -e "homeDirectory: $line\n" >> ./ldif/rename_user.ldif
		fi  
		i=$[$i+1]	
	done < /tmp/result
	
	if [ $flag -eq 1 ] ; then 
		echo "dn: $dn" >> ./ldif/rename_user.ldif
		echo "changetype: modrdn" >> ./ldif/rename_user.ldif
		echo "newrdn: uid=$new_uid" >> ./ldif/rename_user.ldif
		echo "deleteoldrdn: 1" >> ./ldif/rename_user.ldif
	fi
	

	ldapmodify -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -f ./ldif/rename_user.ldif 1> /tmp/rename_user.info 2> /tmp/rename_user.error
	exit_code=$?
	if [ $exit_code -eq 0 ] ; then
        	MESSAGE=`cat /tmp/rename_user.info`
        	dialog --backtitle "System Information" \
        	       --title "successfull" \
       		       --msgbox "$MESSAGE" 20 70
	else 
			
       		MESSAGE=`cat /tmp/rename_user.error`
        	dialog --backtitle "System Information" \
       		       --title "error message" \
       		       --msgbox "$MESSAGE" 20 70
	fi

	source index.sh
else 
	source index.sh
fi
