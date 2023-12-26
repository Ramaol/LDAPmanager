#!/bin/bash 

dn=$1

#get old rd
OLD_RDN=`echo "$dn" | gawk -F, '{print $1}' | gawk -F= '{print $2}'`

exec 3>&1

VALUES=$(dialog --ok-label "Submit" \
          --backtitle "Ldap Managment" \
          --title "change organization" \
          --form "input your values\n current location:$dn" \
          20 70 0 \
          "newrdn" 1 1        "$OLD_RDN"   1 15 40 0 \
          "newsuperior" 2 1        ""   2 15 40 0 \
2>&1 1>&3)
exit_code=$?
exec 3>&-
echo "$VALUES" > /tmp/result

if [ $exit_code -eq 0 ] ; then 

	if [ -f './ldif/move_o.ldif' ] ; then 
		: > ./ldif/move_o.ldif
	else 
		touch ./ldif/move_o.ldif
	fi

	i=1
	while read line
	do	
		if [ $i -eq 1 ] ; then 
			echo "dn: $dn" >> ./ldif/move_o.ldif
	       		echo "changetype: modrdn" >>./ldif/move_o.ldif
			echo "newrdn: dc=$line" >> ./ldif/move_o.ldif
			echo "deleteoldrdn: 1" >> ./ldif/move_o.ldif
		elif [ $i -eq 2 ] ; then
			echo "newsuperior: $line" >> ./ldif/move_o.ldif
		fi
		i=$[$i+1]
	done < /tmp/result

	ldapmodify -x -D cn=admin,dc=nit,dc=ir -w "radman1378" -f ./ldif/move_o.ldif 1> /tmp/move_o.info 2> /tmp/move_o.error
	exit_code=$?
	
	if [ $exit_code -eq 0 ] ; then 
        	MESSAGE=`cat /tmp/move_o.info`
		dialog  --backtitle "openldap manage" \
	                --title "successfull" \
        	        --msgbox "$MESSAGE" 20 70
	else
		MESSAGE=`cat /tmp/move_o.error`
        	dialog  --backtitle "openldap manage" \
               		--title "error" \
                	--msgbox "$MESSAGE" 20 70
	fi

       	source index.sh	
else 
	source index.sh
fi




