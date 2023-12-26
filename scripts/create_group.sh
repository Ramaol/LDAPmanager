#!/bin/bash 

function check_cn() { 
	cn=$1
	dn=$2
	dn_cn=`echo "$dn" | gawk -F, '{print $1}' | gawk -F= '{print $2}'`	
	rdn=`echo "$dn" | gawk -F, '{print $1}' | gawk -F= '{print $1}'`

	if [ "$dn_cn" != "$cn" ] ; then 		
        	dialog --backtitle "openldap manager" \
        	--title "error" \
        	--msgbox "cn value is not comptaible with cn in dn" 20 70
		
		 source create_group.sh	
		 exit
	fi

	if [ "$rdn" != "cn" ] ; then
        	dialog --backtitle "openldap manager" \
        	--title "error" \
        	--msgbox "groups rdn must be with cn attribute" 20 70

		 source create_group.sh	
		 exit
	fi
}	

# all field must be completed
function check_required_input() { 
	number_of_lines=`wc -l ./ldif/create_group.ldif | gawk -F" " '{print $1}'`
	if [ ! $number_of_lines -eq 5 ] ; then	
        	
		dialog --backtitle "openldap manager" \
        	--title "error" \
        	--msgbox "all of field must be complete" 20 70
		
		source create_group.sh
		exit
	fi
}


exec 3>&1

VALUES=$(dialog --ok-label "Submit" \
          --backtitle "Ldap Managment" \
          --title "create group" \
          --form "input your values" \
          20 70 0 \
          "dn" 1 1        ""   1 15 40 0 \
          "cn" 2 1        ""   2 15 40 0 \
          "description" 3 1        ""   3 15 40 0 \
2>&1 1>&3)

exit_code=$?
exec 3>&-

if [  $exit_code -eq 0 ] ; then

	echo "$VALUES" > /tmp/result
	if [ -f "./ldif/create_group.ldif" ] ; then
		: > ./ldif/create_group.ldif
	else
		touch ./ldif/create_group.ldif
	fi
	
	i=1
	while read -r line 
	do 
		if [ $i -eq 1 ] ; then 
			dn=$line
			echo "dn: $dn" >> ./ldif/create_group.ldif
			echo "objectclass: top" >> ./ldif/create_group.ldif
			echo "objectclass: groupOfNames" >> ./ldif/create_group.ldif
		elif [ $i -eq 2 ] ; then 
			cn=$line
			echo "cn: $cn" >> ./ldif/create_group.ldif
		elif [ $i -eq 3 ] ; then 
			echo "description: $line" >> ./ldif/create_group.ldif
		fi
		i=$[$i+1]
	done < /tmp/result	
	
	check_required_input
	check_cn $cn $dn

	source user_select_for_group.sh
else 
	source index.sh
fi


