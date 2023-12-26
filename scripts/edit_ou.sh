#!/bin/bash


exec 3>&1
OBJECT_DN=$1
ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b "$OBJECT_DN" -s base | grep -e "dn: " -e "ou: " | sed 's/dn: //' | sed 's/ou: //'> /tmp/result

i=1
while read -r line 
do
	if [ $i -eq 1 ] ; then 
		dn=$line
	elif [ $i -eq 2 ] ; then 	
		ou=$line
	fi
	i=$[$i+1]
done < /tmp/result

VALUES=$(dialog --extra-button --extra-label "DELETE" --ok-label "edit" \
    		--backtitle "PSKBeacon Setup" \
      		--title "edit OU" \
                --form "change your data" \20 70 0 \
    		"dn: " 1 1    "$dn"        1 15 40 0 \
    		"ou: "    2 1   "$ou"        2 15 40 0 \
     		2>&1 1>&3)

exit_code=$?
exec 3>&-

if [ -f './ldif/edit_ou.ldif' ] ; then 
	: > ./ldif/edit_ou.ldif	
else 
	touch ./ldif/edit_ou.ldif
fi

if [ $exit_code -eq 0 ] ; then	

	echo "$VALUES" > /tmp/result 
	
	i=1
	while read -r line 
	do
		if [ $i -eq 1 ] ; then 
			NEW_DN=$line
		elif [ $i -eq 2 ] ; then 
			NEW_OU=$line
		fi
		i=$[$i+1]	
	done < /tmp/result 
	
	# check changes 
	if [ "$dn" == "$NEW_DN" -a "$ou" != "$NEW_OU" ] ; then 
		echo "dn: $dn" >> ./ldif/edit_ou.ldif
		echo "changetype: modrdn" >> ./ldif/edit_ou.ldif
		echo "newrdn: ou=$NEW_OU" >> ./ldif/edit_ou.ldif
		echo "deleteoldrdn: 1" >> ./ldif/edit_ou.ldif

	elif [ "$dn" != "$NEW_DN" ] ; then 
		echo "dn: $dn" >> ./ldif/edit_ou.ldif
		echo "changetype: modrdn" >> ./ldif/edit_ou.ldif
		echo "newrdn: $NEW_OU" >> ./ldif/edit_ou.ldif
		echo "deleteoldrdn: 1" >> ./ldif/edit_ou.ldif
		echo "newsuperior: `echo "$NEW_DN" | sed 's/,/ /g' | gawk -F" " '{$1=""}1' | sed 's/ /,/g' | cut -c 2-`" >> ./ldif/edit_ou.ldif
		
	fi	

	ldapmodify -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -f ./ldif/edit_ou.ldif > /tmp/edit_ou.info 2> /tmp/edit_ou.error
	
	if [ $? -eq 0 ] ; then 
		MESSAGE=`cat /tmp/edit_ou.info`
		dialog  --backtitle "System Information" \
			--title "successfull" \
			--msgbox "$MESSAGE" 20 70
	else
		ERROR_MESSAGE=`cat /tmp/edit_ou.error`
		dialog --backtitle "System Information" \
		       --title "error message" \
		       --msgbox "$ERROR_MESSAGE" 20 70
	fi

	source index.sh

# press delete ou 
elif [ $exit_code -eq 3 ] ; then
	#first all user and group will be delete 
	source delete_groups_in_ou.sh $dn $ou 
	source delete_users_in_ou.sh $dn $ou
	echo "dn: $dn" >> ./ldif/edit_ou.ldif
	echo "changetype: delete" >> ./ldif/edit_ou.ldif
	ldapmodify -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -f ./ldif/edit_ou.ldif > /tmp/edit_ou.info 2> /tmp/edit_ou.error
	
	if [ $? -eq 0 ] ; then 
		MESSAGE=`cat /tmp/edit_ou.info`
		dialog  --backtitle "System Information" \
			--title "successfull" \
			--msgbox "$MESSAGE" 20 70
	else
		ERROR_MESSAGE=`cat /tmp/edit_ou.error`
		dialog --backtitle "System Information" \
		       --title "error message" \
		       --msgbox "$ERROR_MESSAGE" 20 70
	fi
	source index.sh

elif [ $exit_code -eq 1	] ; then 
	source index.sh
fi
