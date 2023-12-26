#!/bin/bash

dn=$1
dc=`echo "$1" | gawk -F, '{print $1}' | gawk -F= '{print $2}'`
o=`ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b "$dn" -s base | grep "o: " | sed 's/o: //'`

exec 3>&1
VALUE=$(dialog --backtitle "openldap manage" \
      		--title "edit organization" \
                --form "input new name" \20 70 0 \
    		"dc: " 1 1    "$dc"        1 15 40 0 \
    		"o: " 2 1    "$o"        2 15 40 0 \
     		2>&1 1>&3)

exit_code=$?

exec 3>&-

echo "$VALUE" > /tmp/result

# get input values from result
i=1
while read line 
do
	if [ $i -eq 1 ] ; then
		NEW_DC=$line
	elif [ $i -eq 2 ] ; then 
		NEW_O=$line
	fi
	i=$[$i+1]
done < /tmp/result

# make ldif file
if [ -f './ldif/rename_o.ldif' ] ; then 
	: > ./ldif/rename_o.ldif
else
	touch ./ldif/rename_o.ldif
fi

# fill ldif file for change
if [ $exit_code -eq 0 ] ; then 
	
	echo "dn: $dn" >> ./ldif/rename_o.ldif
	echo "changetype: modify" >> ./ldif/rename_o.ldif
	echo "replace: o" >> ./ldif/rename_o.ldif
	echo -e "o: $NEW_O\n" >> ./ldif/rename_o.ldif

	echo "dn: $dn" >> ./ldif/rename_o.ldif
	echo "changetype: modrdn" >> ./ldif/rename_o.ldif
	echo "newrdn: dc=$NEW_DC" >> ./ldif/rename_o.ldif
	echo -e "deleteoldrdn: 1\n" >> ./ldif/rename_o.ldif
	
	ldapmodify -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -f ./ldif/rename_o.ldif 1> /tmp/rename_o.info 2> /tmp/rename_o.error	
	
	if [ $? -eq 0 ] ; then 
		MESSAGE=`cat /tmp/rename_o.info`
		dialog  --backtitle "openldap manage" \
			--title "successfull" \
			--msgbox "$MESSAGE" 20 70
	else
		MESSAGE=`cat /tmp/rename_o.error`
		dialog --backtitle "System Information" \
		       --title "error" \
		       --msgbox "$MESSAGE" 20 70
	fi
	
	source index.sh
else 
	source index.sh
fi
