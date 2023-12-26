#!/bin/bash

HEIGHT=30
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="openldap manager"
TITLE="Welcome to openldap manager"
MENU="Choose one of the following options:"

OPTIONS=(1 "show_objects"
	 2 "create_organization" 
 	 3 "create organization unit"
         4 "create user"
 	 5 "create group"
 	 6 "editing"
 	 7 "searching"
 	 8 "create backup"
	 9 "service management")

CHOICE=$(dialog --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

if [ $? -eq 0 ] ; then 
	case $CHOICE in
        	1) source show_objects.sh ;; 
		2) source create_organization.sh ;;
		3) source create_organization_unit.sh ;;
        	4) source add_user.sh ;;
		5) source create_group.sh ;;
		6) source editing.sh ;;
		7) source searching.sh;; 		
		8) source create_backup.sh ;;
		9) source service_management.sh ;;
	esac
else
	clear    
	exit
fi

