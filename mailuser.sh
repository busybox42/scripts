#!/bin/bash

# Local Settings
TMP="/tmp"
MDIR="/home/vmail"
MUSR="username"
PASS="password"

# Script Arguments
OPT="$1"
EMAIL="$2"
OPT_TWO="$3"

usage() {
  echo "Usage: ./mailuser.sh get|add|del|pwd email@domain.tld ARG"
  echo " "  
  echo "get - Retrieve user information from LDAP. Optionally"
  echo "      you can pass a LDAP attribute to display from" 
  echo "      the user.  If left emptyall user attributes will"
  echo "      be displayed."
  echo " "
  echo "add - Create a user: add user@domain.tld password"
  echo " "
  echo "del - Remove a user from LDAP and delete the inbox."
  echo "      del user@domain.tld"
  echo " "
  echo "pwd - Set user password: pwd user@domain.tld password"
  echo " "
  echo "alias - Manage user aliases"
  echo " "
  exit 1
}

# Script runs as root or not at all
if [[ $EUID -ne 0 ]]
then
  echo "This script must be run as root!"  
  usage
fi
# Script Help
if [ "$#" -gt 4 ]
then
  usage
elif [ "$#" -lt 2 ]
then
  usage
fi

# Construct DN
LP=$(echo $EMAIL|cut -f1 -d@)
DOM=$(echo $EMAIL|cut -f2 -d@)
DC1=$(echo $DOM|cut -f1 -d.)
DC2=$(echo $DOM|cut -f2 -d.)
DN="uid=${LP},ou=accounts,dc=${DC1},dc=${DC2}"

if [ "${OPT}" == "del" ]
then
	ldapdelete -w ${PASS} -D "cn=Manager,dc=${DC1},dc=${DC2}" "${DN}"
  unlink ${MDIR}/${EMAIL}
  rm -rf ${MDIR}/${LP}
elif [ "${OPT}" == "get" ]
then
  if [ "$#" -ne 3 ]
  then
    if [ "${EMAIL}" == "accounts" ]
    then
      ldapsearch -LLL -D "cn=Manager,dc=evil-admin,dc=com" -w secret -b "dc=evil-admin,dc=com" "(objectclass=posixAccount)" dn |awk -F "=" '{print $2, $4, $5}'|sed 's/\,ou\ /@/'|sed 's/\,dc\ /\./'|sed '/^\s*$/d'
    else
      ldapsearch -LLL -D "cn=Manager,dc=${DC1},dc=${DC2}" -w secret -b "${DN}"
    fi
  else
    ldapsearch -LLL -D "cn=Manager,dc=${DC1},dc=${DC2}" -w secret -b "${DN}" ${OPT_TWO}
  fi
elif [ "${OPT}" == "alias" ]
then
  if [ "${3}" == "list" ]
  then
    ldapsearch -LLL -D "cn=Manager,dc=${DC1},dc=${DC2}" -w secret -b "${DN}" uid
  elif [ "${3}" == "add" ]
  then
    if [ "$#" -ne 4 ]
    then
      useage
    else
      # Make ldiff
      echo "dn: ${DN}" |tee ${TMP}/${OPT}_user_${LP}.ldiff
      echo "changetype: modify" |tee -a ${TMP}/${OPT}_user_${LP}.ldiff
      echo "add: uid" |tee -a ${TMP}/${OPT}_user_${LP}.ldiff
      echo "uid: ${4}" |tee -a ${TMP}/${OPT}_user_${LP}.ldiff
      # Add the alias
      ldapmodify -x -D "cn=Manager,dc=${DC1},dc=${DC2}" -w ${PASS} -f ${TMP}/${OPT}_user_${LP}.ldiff
    fi
  elif [ "${3}" == "del" ]
  then
    if [ "$#" -ne 4 ]
    then
      useage
    else
      # Make ldiff
      echo "dn: ${DN}" |tee ${TMP}/${OPT}_user_${LP}.ldiff
      echo "changetype: modify" |tee -a ${TMP}/${OPT}_user_${LP}.ldiff
      echo "delete: uid" |tee -a ${TMP}/${OPT}_user_${LP}.ldiff
      echo "uid: ${4}" |tee -a ${TMP}/${OPT}_user_${LP}.ldiff
      # Add the alias
      ldapmodify -x -D "cn=Manager,dc=${DC1},dc=${DC2}" -w ${PASS} -f ${TMP}/${OPT}_user_${LP}.ldiff
    fi
  fi  
else
	if [ "${OPT}" == "add" ]
	then		
    # Get last LDAP uid and gid and incriment
		LAST_UID=`ldapsearch -LLL -D "cn=Manager,dc=${DC1},dc=${DC2}" -w ${PASS} -b "dc=${DC1},dc=${DC2}" "(objectclass=person)" uidNumber|grep "uidNumber:" |awk '{print $2}'|sort |tail -n1`
		LAST_GID=`ldapsearch -LLL -D "cn=Manager,dc=${DC1},dc=${DC2}" -w ${PASS} -b "dc=${DC1},dc=${DC2}" "(objectclass=person)" gidNumber|grep "gidNumber:" |awk '{print $2}'|sort |tail -n1`
		UNUM=$(($LAST_UID +1))		
		GNUM=$(($LAST_GID +1))
    # Make the ldiff
		echo "dn: ${DN}" |tee ${TMP}/${OPT}_user_${LP}.ldiff
		echo "objectClass: top" |tee -a ${TMP}/${OPT}_user_${LP}.ldiff
		echo "objectclass: person" |tee -a ${TMP}/${OPT}_user_${LP}.ldiff
		echo "objectClass: posixAccount" |tee -a ${TMP}/${OPT}_user_${LP}.ldiff
		echo "cn: ${LP}" |tee -a ${TMP}/${OPT}_user_${LP}.ldiff
		echo "sn: ${LP}" |tee -a ${TMP}/${OPT}_user_${LP}.ldiff
		echo "uid: ${LP}" |tee -a ${TMP}/${OPT}_user_${LP}.ldiff
		echo "uidNumber: ${UNUM}" |tee -a ${TMP}/${OPT}_user_${LP}.ldiff
		echo "gidNumber: ${GNUM}" |tee -a ${TMP}/${OPT}_user_${LP}.ldiff
		echo "homeDirectory: /home/vmail/${LP}" |tee -a ${TMP}/${OPT}_user_${LP}.ldiff
    # Add the user
    ldapadd -x -D "cn=Manager,dc=${DC1},dc=${DC2}" -w ${PASS} -f ${TMP}/${OPT}_user_${LP}.ldiff
    # Symlink user directory
    install -d -o ${MUSR} -g ${MUSR} -m 700 /home/vmail/${LP}
    ln -s ${MDIR}/${LP} ${MDIR}/${EMAIL}
    # Set password
    ldappasswd -w ${PASS} -s ${OPT_TWO} -D "cn=Manager,dc=${DC1},dc=${DC2}" "$DN"
  elif [ "${OPT}" == "pwd" ]
  then
    # Set password
    ldappasswd -w ${PASS} -s ${OPT_TWO} -D "cn=Manager,dc=${DC1},dc=${DC2}" "$DN"
	fi
fi
