#!/bin/bash

HEIGHT=30
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="openldap manage"
TITLE="edit organization unit"
MENU="Choose your kind of edit"

dn=$1

OPTIONS=(1 "delete"
	 2 "rename"
         3 "move")

CHOICE=$(dialog --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

exit_code=$?

if [ $exit_code -eq 0 ] ; then 
	case $CHOICE in
        	1) source delete_ou.sh $dn ;; 
        	2) source rename_ou.sh $dn ;;
        	3) source move_ou.sh $dn ;;
	esac
else
	source index.sh
fi

