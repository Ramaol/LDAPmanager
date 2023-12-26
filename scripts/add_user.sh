#!/bin/bash

# function for check uid match with dn uid attribute
function check_uid() { 
	uid=$1
	dn=$2
	dn_uid=`echo "$dn" | gawk -F, '{print $1}' | gawk -F= '{print $2}'`	
	rdn=`echo "$dn" | gawk -F, '{print $1}' | gawk -F= '{print $1}'`

	if [ "$dn_uid" != "$uid" ] ; then 		
        	dialog --backtitle "openldap manager" \
        	--title "error" \
        	--msgbox "uid value is not comptaible with username in dn" 20 70
		
		 source add_user.sh	
		 exit
	fi

	if [ "$rdn" != "uid" ] ; then
        	dialog --backtitle "openldap manager" \
        	--title "error" \
        	--msgbox "users rdn must be with uid attribures" 20 70
		
		 source add_user.sh	
		 exit
	fi

}	

# all field must be completed
function check_required_input() { 
	number_of_lines=`wc -l ./ldif/add_user.ldif | gawk -F" " '{print $1}'`
	if [ ! $number_of_lines -eq 13 ] ; then	
        	
		dialog --backtitle "openldap manager" \
        	--title "error" \
        	--msgbox "all of field must be completed" 20 70
		
		source add_user.sh
		exit
	fi
}

exec 3>&1
VALUES=$(dialog --ok-label "Submit" \
          --backtitle "Ldap Manager" \
          --title "create user" \
          --form "input your values" \
          20 70 0 \
          "dn" 1 1        ""   1 15 40 0 \
          "uid" 2 1        ""   2 15 40 0 \
	  "sn" 3 1         ""    3 15 40 0 \
	  "givenName" 4 1         ""    4 15 40 0 \
	  "cn" 5 1         ""    5 15 40 0 \
	  "uidNumber" 6 1         ""    6 15 40 0 \
	  "gidNumber" 7 1         ""    7 15 40 0 \
	  "userPassword" 8 1         ""    8 15 40 0 \
	  "loginShell" 9 1         ""    9 15 40 0 \
	  "homeDirectory" 10 1         ""    10 15 40 0 \
2>&1 1>&3)

# save what button clicked
exit_code=$?

# close fd
exec 3>&-

# save values in file
echo "$VALUES" > /tmp/result


# make ldif file
if [ -f "./ldif/add_user.ldif" ] ; then
        : > ./ldif/add_user.ldif
else
        touch ./ldif/add_user.ldif
fi

if [ "$exit_code" -eq 0 ] ; then 
	
	# make ldif file from result
	i=1
	while read -r line
	do
        	if [ $i -eq 1 ] ; then
        		dn=$line
			echo "dn: $dn" > ./ldif/add_user.ldif;
               		echo "objectClass: inetOrgPerson" >> ./ldif/add_user.ldif
			echo "objectClass: posixAccount" >> ./ldif/add_user.ldif
			echo "objectClass: shadowAccount" >> ./ldif/add_user.ldif

        	elif [ $i -eq 2 ] ; then
                	uid=$line
			echo "uid: $uid" >> ./ldif/add_user.ldif;
		elif [ $i -eq 3 ] ; then
                	echo "sn: $line" >> ./ldif/add_user.ldif;
		elif [ $i -eq 4 ] ; then
                	echo "givenName: $line" >> ./ldif/add_user.ldif;
		elif [ $i -eq 5 ] ; then
                	echo "cn: $line" >> ./ldif/add_user.ldif;
		elif [ $i -eq 6 ] ; then
                	echo "uidNumber: $line" >> ./ldif/add_user.ldif;
		elif [ $i -eq 7 ] ; then
                	echo "gidNumber: $line" >> ./ldif/add_user.ldif;
		elif [ $i -eq 8 ] ; then
               		echo "userPassword: $line" >> ./ldif/add_user.ldif;
		elif [ $i -eq 9 ] ; then
                	echo "loginShell: $line" >> ./ldif/add_user.ldif;
		elif [ $i -eq 10 ] ; then
                	echo "homeDirectory: $line" >> ./ldif/add_user.ldif;
        	fi
        	i=$[$i+1]
	done < /tmp/result


	check_required_input
	check_uid $uid $dn
	


	# create user with ldapadd
	ldapadd -f ./ldif/add_user.ldif -x -D cn=admin,dc=nit,dc=ir -w "radman1378" 1> /tmp/add_user.info 2> /tmp/add_user.error
	exit_code=$? 
	
	# show operation result
	if [ $exit_code -eq 0 ] ; then 
		MESSAGE=`cat /tmp/add_user.info`
        		dialog  --backtitle "openldap manager" \
               	        --title "successfull" \
        	        --msgbox "$MESSAGE" 20 70
	else
        	MESSAGE=`cat /tmp/add_user.error`
        	dialog --backtitle "openldap manager" \
        	--title "operation failed" \
        	--msgbox "$MESSAGE" 20 70
	fi
	
	source index.sh
	
else 	
	# if press cancel back to index
	source index.sh
fi

