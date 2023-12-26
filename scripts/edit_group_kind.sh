#!/bin/bash

HEIGHT=30
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="Cluster Options"
TITLE="Welcome to LDAP"
MENU="Choose one of the following options:"

dn=$1

OPTIONS=(1 "delete group"
	 2 "rename group"
         3 "move group"
 	 4 "change users")
CHOICE=$(dialog --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

exit_code=$?

if [ -f './ldif/edit_ou.ldif' ] ; then 
	: > ./ldif/edit_ou.ldif	
else 
	touch ./ldif/edit_ou.ldif
fi

if [ $exit_code -eq 0 ] ; then 
	clear
	case $CHOICE in
        	1) source delete_group.sh $dn ;; 
        	2) source rename_group.sh $dn ;;
        	3) source move_group.sh $dn ;;
		4) source change_group_user.sh $dn ;;
	esac
else
	source index.sh
fi

