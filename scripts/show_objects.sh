#!/bin/bash 


DATA=`ldapsearch -x -LLL -b dc=nit,dc=ir`

dialog  --backtitle "System Information" \
                --title "objetcts" \
                --msgbox "$DATA" 20 70

source index.sh
