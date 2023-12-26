#!/bin/bash 

dn=$1
# !!!!!!! :|
dn_for_users=$dn
dn_for_groups=$dn
dn_for_dc=$dn


# this 2 scrpts can be use for delete organization and arganization unit
source delete_groups_in_ou.sh $dn_for_groups
source delete_users_in_ou.sh $dn_for_users

ldapdelete -x -D cn=admin,dc=nit,dc=ir -w 'radman1378' -r "$dn_for_dc" 1> /tmp/delete_o.info 2> /tmp/delete_o.error
	
if [ $? -eq 0 ] ; then 
	MESSAGE=`cat /tmp/delete_ou.info`
	dialog  --backtitle "openldap manage" \
			--title "successfull" \
			--msgbox "organization is deleted" 20 70
else
	MESSAGE=`cat /tmp/delete_ou.error`
	dialog --backtitle "openldap manage" \
	       --title "error" \
	       --msgbox "$MESSAGE" 20 70
fi
