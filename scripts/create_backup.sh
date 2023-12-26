#!/bin/bash

if [ ! -d '/var/log/ldap_backup' ] ; then
	mkdir /var/log/ldap_backup
fi

date=`date`
slapcat -b "dc=nit,dc=ir" -l "/var/log/ldap_backup/backup_$date.ldif" 1> /tmp/create_backup.error 2> /tmp/create_backup.success
exit_code=$?
if [ $exit_code -eq 0 ] ; then 
	MESSAGE=`cat /tmp/create_backup.success`	
	dialog  --backtitle "openldap manage" \
                --title "successfull" \
                --msgbox "new backup is created !! \n $MESSAGE" 20 70
else 
	MESSAGE=`cat /tmp/create_backup.error`
	dialog  --backtitle "openldap manage" \
               	--title "error" \
               	--msgbox "something wrong !! \n $MESSAGE" 20 70
fi

source index.sh
