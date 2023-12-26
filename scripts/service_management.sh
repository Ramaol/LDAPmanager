#!/bin/bash 

HEIGHT=30
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="Cluster Options"
TITLE="Welcome to LDAP"
MENU="service control"


OPTIONS=(1 "start ldap"
	 2 "stop ldap"
	 3 "restart"
 	 4 "enable" 
 	 5 "disable"
 	 6 "status")


CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

if [ $? -eq 0 ] ; then

case $CHOICE in
        1) systemctl start slapd 2> /tmp/service_management.error 1> /tmp/service_management.info ;; 
        2) systemctl stop slapd 2> /tmp/service_management.error 1> /tmp/service_management.info ;;
        3) systemctl restart slapd 2> /tmp/service_management.error 1> /tmp/service_management.info ;;
        4) systemctl enable slapd 2> /tmp/service_management.error 1> /tmp/service_management.info ;;
  	5) systemctl disable slapd 2> /tmp/service_management.error 1> /tmp/service_management.info ;;		
	6) systemctl status slapd 2> /tmp/service_management.error 1> /tmp/service_management.info
esac	

if [ $? -eq 0 ] ; then
	INFO=`cat /tmp/service_management.info`
	dialog  --backtitle "System Information" \
		--title "successfull" \
		--msgbox "done with no error !! \n $INFO" 20 70
else
	ERROR_MESSAGE=`cat /tmp/service_management.error`
	dialog --backtitle "System Information" \
	--title "error message" \
	--msgbox "$ERROR_MESSAGE" 20 70
fi

source index.sh

else
	source index.sh
fi

