#!/bin/bash

HEIGHT=30
WIDTH=80
CHOICE_HEIGHT=4
BACKTITLE="openldap manage"
TITLE="select user for group"

# get all of users (just users dn)
ldapsearch -x -D cn=admin,dc=nit,dc=ir -w "radman1378" -b dc=nit,dc=ir "objectclass=inetOrgPerson" | grep "dn: " | sed 's/dn: //' > /tmp/user.res


# if no user in database exit
if [ `wc -l /tmp/user.res | gawk -F" " '{ print $1}'` -eq 0 ] ; then 
	
		dialog  --backtitle "openldap manage" \
                	--title "warning" \
  	              	--msgbox "there is no user in database \n you first must add user" 20 70
		
		source index.sh
		exit
fi


function check_required_input() { 
	if [ $1 -eq 0 ] ; then		
		dialog --backtitle "openldap manager" \
        	--title "error" \
        	--msgbox "At least one option must be selected" 20 70
	
		source user_select_for_group.sh
		exit
	fi
}

# fill option to show
OPTIONS=()
while read -r line 
do
	OPTIONS+=($line "$line" off) 
done < /tmp/user.res

CHOICES=$(dialog --backtitle "$BACKTITLE" \
       	        --no-tags \
       		--title "$TITLE" \
                --checklist "select user in list" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
       	        2>&1 >/dev/tty)
exit_code=$?

if [ $exit_code -eq  0 ] ; then 
	# add selected members to ./ldif/create_group.ldif
	i=0
	for choice in $CHOICES ; do 
		echo "member: $choice" >> ./ldif/create_group.ldif
		i=$[$i+1]
	done
	check_required_input $i
	ldapadd -f ./ldif/create_group.ldif -x -D cn=admin,dc=nit,dc=ir -w "radman1378" 1> /tmp/select_user_for_group.info  2> /tmp/select_user_for_group.error
	exit_code=$?
	if [ $exit_code -eq 0 ] ; then 
		MESSAGE=`cat /tmp/select_user_for_group.info`
		dialog  --backtitle "openldap manage" \
                	--title "successfull" \
                	--msgbox "$MESSAGE" 20 70
	else
		MESSAGE=`cat /tmp/select_user_for_group.error`
        	dialog  --backtitle "openldap manage" \
                	--title "error!!" \
                	--msgbox "$MESSAGE" 20 70
	fi
	source index.sh
else  
	: > ./ldif/create_group.ldif
	source index.sh
fi
