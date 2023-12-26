#!/bin/bash

HEIGHT=30
WIDTH=80
CHOICE_HEIGHT=4
BACKTITLE="openldap manage"
TITLE="change group user"
dn=$1

group=`ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b "$dn" -s base`
echo "$group" | grep "member: " | sed 's/member: //' > /tmp/group_members
all_users=`ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b dc=nit,dc=ir "objectclass=inetOrgPerson" | grep "dn: " | sed "s/dn: //"`
echo "$all_users" > /tmp/all_users
OPTIONS=()

while read -r line 
do			
	grep -q $line /tmp/group_members
	exit_code=$?
	if [ $exit_code -eq 0 ] ; then 
		OPTIONS+=($line "$line" on)
	else 
		OPTIONS+=($line "$line" off)
	fi	
done < /tmp/all_users


CHOICES=$(dialog --backtitle "$BACKTITLE" \
       	        --no-tags \
       		--title "$TITLE" \
                --checklist "select user in list" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
       	         2>&1 >/dev/tty)
 
exit_code=$? 
echo $CHOICES > /tmp/user_selected
if [ $exit_code -eq 0 ] ; then 
	if [ -f './ldif/change_group_user.ldif' ] ; then 
		: > ./ldif/change_group_user.ldif
	else
		touch ./ldif/change_group_user.ldif
	fi
		
	echo "$CHOICES" > /tmp/check_count
	if [ ! `wc -l /tmp/check_count | gawk '{print $1}'` -eq 0 ] ; then
		i=1
		for choice in $CHOICES ; do
			grep -q $choice /tmp/group_members
			exit_code=$? 
			if [ ! $exit_code -eq 0 ] ; then
				flag="true"
				if [ $i -eq 1 ] ; then
					echo "dn: $dn" >> ./ldif/change_group_user.ldif
					echo "changetype:modify" >> ./ldif/change_group_user.ldif	
					echo "add: member" >> ./ldif/change_group_user.ldif
					i=$[$i+1]
				fi
				echo "member: $choice" >> ./ldif/change_group_user.ldif
			fi	
		done 
	fi

	if [ "$flag" == "true" ] ; then 
		echo "" >> ./ldif/change_group_user.ldif
	fi

	i=1	
	while read line 
	do	
		grep -q $line /tmp/user_selected
		exit_code=$? 
		if [ ! $exit_code -eq 0 ] ; then 
			if [ $i -eq 1 ] ; then 
				echo "dn: $dn" >> ./ldif/change_group_user.ldif
				echo "changetype: modify" >> ./ldif/change_group_user.ldif
				echo "delete: member" >> ./ldif/change_group_user.ldif
				i=$[$i+1]
			fi
			echo "member: $line" >> ./ldif/change_group_user.ldif	
		fi
	done < /tmp/group_members
		
	ldapmodify -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -f ./ldif/change_group_user.ldif 1> /tmp/change_group_user.info 2> /tmp/change_group_user.error

	exit_code=$?
	if [ "$exit_code" -eq 0 ] ; then 
		MESSAGE=`cat /tmp/change_group_user.info`
        	dialog  --backtitle "openldap manage" \
                	--title "successfull" \
                	--msgbox "$MESSAGE" 20 70
	else 
		MESSAGE=`cat /tmp/change_group_user.error`		
        	dialog  --backtitle "openldap manage" \
                	--title "error" \
                	--msgbox "$MESSAGE" 20 70
	fi
fi


