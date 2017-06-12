#/bin/bash

for i in `systemctl list-unit-files | grep enabled|awk '{print $1}'|egrep -v "cronie|autovt|getty"` ;do
   A=`systemctl status $i |grep "Active:"|awk '{print $2}'`
   if [[ $A != "active" ]] ;then
     echo $i is $A
     systemctl restart $i
     echo "Attempting to restart $i" |mail -s "$i is $A" alan@evil-admin.com
   fi
done
