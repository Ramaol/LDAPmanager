#!/bin/bash

HEIGHT=30
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="Cluster Options"
TITLE="Welcome to LDAP"
MENU="Choose one of the following options:"


OPTIONS=(1 "search in users"
	 2 "search in groups")

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
        	1) source search_user_attributes.sh;; 
        	2) source search_group_attributes.sh;;
	esac
else
	source index.sh
fi

