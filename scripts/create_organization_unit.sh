#!/bin/bash


function check_ou() { 
	ou=$1
	dn=$2
	dn_ou=`echo "$dn" | gawk -F, '{print $1}' | gawk -F= '{print $2}'`	
	rdn=`echo "$dn" | gawk -F, '{print $1}' | gawk -F= '{print $1}'`

	if [ "$dn_ou" != "$ou" ] ; then 		
        	dialog --backtitle "openldap manager" \
        	--title "error" \
        	--msgbox "ou value is not comptaible with ou in dn" 20 70
		
		 source create_organization_unit.sh	
		 exit
	fi

	if [ "$rdn" != "ou" ] ; then
        	dialog --backtitle "openldap manager" \
        	--title "error" \
        	--msgbox "organization units rdn must be with ou attribute" 20 70
		
		 source create_organization_unit.sh	
		 exit
	fi

}	

# all field must be completed
function check_required_input() { 
	number_of_lines=`wc -l ./ldif/create_organization_unit.ldif | gawk -F" " '{print $1}'`
	if [ ! $number_of_lines -eq 3 ] ; then	
		dialog --backtitle "openldap manager" \
        	--title "error" \
        	--msgbox "all of field must be completed" 20 70
		
		source create_organization_unit.sh
		exit
	fi
}


# open fd
exec 3>&1

# Store data to $VALUES variable
VALUES=$(dialog  --ok-label "Submit" \
	  --backtitle "Ldap Management" \
	  --title "create organization unit" \
	  --form "input your values" \
	20 70 0 \
	"dn" 1 1 	'' 	1 15 40 0 \
	"ou" 3 1	''  	3 15 40 0 \
2>&1 1>&3)

exit_code=$?
# close fd
exec 3>&-

# make ldif file
if [ -f "./ldif/create_organization_unit.ldif" ] ; then
	: > ./ldif/create_organization_unit.ldif
else
	touch ./ldif/create_organization_unit.ldif
fi


# press submit
if [ $exit_code -eq 0 ] ; then
	echo "$VALUES" > /tmp/result
	
	i=1
	while read -r line
	do	
		if [ $i -eq 1 ] ; then 
			dn=$line
			echo "dn: $dn" >> ./ldif/create_organization_unit.ldif;
			echo "objectClass: organizationalUnit" >> ./ldif/create_organization_unit.ldif 

		elif [ $i -eq 2 ] ; then  
			ou=$line
			echo "ou: $ou" >> ./ldif/create_organization_unit.ldif;
		fi
		i=$[$i+1]
	done < /tmp/result

	check_required_input
	check_ou $ou $dn
	
	# add file to database 
	ldapadd -f ./ldif/create_organization_unit.ldif -x -D cn=admin,dc=nit,dc=ir -w "radman1378" 1> /tmp/create_organization_unit.info  \
		   										    2> /tmp/create_organization_unit.error

	if [ $? -eq 0 ] ; then 
		MESSAGE=`cat /tmp/create_organization_unit.info`
		dialog  --backtitle "openldap manager" \
			--title "successfull" \
			--msgbox "$MESSAGE" 20 70
	else
		MESSAGE=`cat /tmp/create_organization.error`
		dialog  --backtitle "openldap manager" \
			--title "operation faild" \
			--msgbox "$MESSAGE" 20 70
	fi	

	source index.sh 
else 	
	source index.sh
fi





