#!/bin/bash

HEIGHT=30
WIDTH=80
CHOICE_HEIGHT=4
BACKTITLE="Cluster Options"
TITLE="filtering"
STATUS=0


OPTIONS=()
function search() {
	ldapsearch -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -b "$1" -s one "objectclass=*" | grep -e "dn: " -e "objectClass: organizationalUnit" -e "objectClass: groupOfNames" -e "objectClass: inetOrgPerson" -e "objectClass: organization" | sed 's/dn: //' | sed 's/objectClass: //' > /tmp/result
	i=1
	OPTIONS=()
	
	if [ `wc -l /tmp/result | gawk -F" " '{print $1}'` -eq 0 ] ; then 
		OPTIONS+=(1 "there is not any object yet")
		STATUS=1
	else
		while read -r line 
		do 
			if [ $i -eq 1 ] ; then 
				dn=$line
			elif [ $i -eq 2 ] ; then
				class=$line
				if [ "$class" == "organizationalUnit" ] ; then
					OPTIONS+=(${dn}__$class "$dn (organization unit)" )
				elif [ "$class" == "organization" ] ; then	
					OPTIONS+=(${dn}__$class "$dn (organization)" )
				elif [ "$class" == "inetOrgPerson" ] ; then 
					OPTIONS+=(${dn}__$class "$dn (user)")
				elif [ "$class" == 'groupOfNames' ] ; then 
					OPTIONS+=(${dn}__$class "$dn (group)")	
				fi
			fi
		
			i=$[$i+1]
			if [ $i -eq 3 ] ; then
				i=1
			fi

		done < /tmp/result
	fi
}
search dc=nit,dc=ir

exec 3>&1

VALUE=$(dialog --extra-button --extra-label "edit" --ok-label "ok" \
    		--backtitle "openldap manage" \
      		--no-tags \
		--title "database hierarchy" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
     		2>&1 1>&3)
exit_code=$?
exec 3>&-

while [ 1 -eq 1 ] 
do
	if [ $exit_code -eq 1 ] ; then 
		break;
	elif [ $exit_code -eq 0 ] && [ $STATUS -eq 1 ] ; then 
		STUTUS=0
		break
	elif [ $exit_code -eq 0 ] ; then	
				
		dn=`echo "$VALUE" | gawk -F"__" '{print $1}'`
 		class=`echo $VALUE | gawk -F"__" '{print $2}'`
		if [ "$class" == "organizationalUnit" ] || [ "$class" == "organization" ] ; then
			search $dn
			
			# STATUS for check if there is not object in container exit || tis get value in search function
			if [ $STATUS -eq 1 ] ; then	
				STATUS=0
				exec 3>&1	
				VALUE=$(dialog  --ok-label "ok" \
    						--backtitle "openldap manage" \
      						--no-tags \
						--title "database hierarchy" \
                				--menu "$MENU" \
                				$HEIGHT $WIDTH $CHOICE_HEIGHT \
                				"${OPTIONS[@]}" \
     						2>&1 1>&3)
				exec 3>&-
		
				clear
				source editing.sh
				exit
			else
				exec 3>&1	
				VALUE=$(dialog --extra-button --extra-label "edit" --ok-label "ok" \
    						--backtitle "openldap manage" \
      						--no-tags \
						--title "database hierarchy" \
                				--menu "$MENU" \
                				$HEIGHT $WIDTH $CHOICE_HEIGHT \
                				"${OPTIONS[@]}" \
     						2>&1 1>&3)
				exit_code=$?
				clear
				exec 3>&-
			fi
		elif [ "$class" == "inetOrgPerson" ] ; then
			source show_user_detail.sh $dn
			break		
		elif [ "$class" == "groupOfNames" ] ; then
			source show_group_detail.sh $dn
			break
		fi
	elif [ $exit_code -eq 3 ] ; then 	
		dn=`echo "$VALUE" | gawk -F"__" '{print $1}'`
 		class=`echo $VALUE | gawk -F"__" '{print $2}'`
		case $class in 
			"organization") source edit_o_kind.sh $dn;break;;
			"organizationalUnit") source edit_ou_kind.sh $dn;break;;
			"inetOrgPerson") source edit_user_kind.sh $dn;break;;
			"groupOfNames") source edit_group_kind.sh $dn;break;;
		esac 		
	fi
done

source index.sh
 












