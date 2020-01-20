#!/bin/bash

/usr/sap/hostctrl/exe/sapcontrol -nr 10 -function StopSystem ALL

# Check if System is active
while [ "`/usr/sap/hostctrl/exe/sapcontrol -nr 10 -function GetSystemInstanceList | grep -E \"(GREEN|YELLOW)\"`" ]; do
 sleep 1;
done

echo test
# Check if system failed
if [ "`/usr/sap/hostctrl/exe/sapcontrol -nr 10 -function GetSystemInstanceList | grep RED`" ]; then
 echo "HANA Status RED"
 exit 3;
fi


