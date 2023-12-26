#!/bin/bash

HEIGHT=30
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="Cluster Options"
TITLE="Welcome to LDAP"
MENU="Choose one of the following options:"

dn=$1

OPTIONS=(1 "delete"
	 2 "rename"
         3 "move"
 	 4 "disable user"
 	 5 "enable user"
 	 6 "change user password")

CHOICE=$(dialog --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

exit_code=$?


if [ $exit_code -eq 0 ] ; then 
	clear
	case $CHOICE in
        	1) source delete_user.sh $dn ;; 
        	2) source rename_user.sh $dn ;;
        	3) source move_user.sh $dn ;;
		4) source disable_user.sh $dn;;
		5) source enable_user.sh $dn;;
		6 ) source change_user_password.sh $dn;;
	esac
else
	source index.sh
fi

