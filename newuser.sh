#!/bin/bash

#This script will create a local user with random password



#make sure to run with sudo privileges.

if [[ ${UID} -ne 0 ]]
then
	echo "run as sudo or root"

	exit 1
fi

#asking for user name

read -p "please enter the user name: " USER_NAME

#enter the real name

read -p "please enter your real name: " REAL_NAME

#generate a random passowrd

PASSWORD=$(date +%s%N |sha256sum | head -c12)

#add the user

useradd -c ${REAL_NAME} -m ${USER_NAME}

#check if adding the user was succsesfull

if [[ ${?} -ne 0 ]]

then
	echo "This operation cannot be completed"
	exit 1

fi

#setting up random password for the user

echo "${USER_NAME}:${PASSWORD}" | chpasswd

#check if password generation successfull

if [[ ${?} -ne 0 ]]

then
        echo "This operation cannot be completed"
        exit 1

fi

#force password change on first login

passwd -e ${USER_NAME}

#show the user name real name and passwrod

echo "user name is: ${USER_NAME}"
echo
echo "real name is: ${REAL_NAME}"
echo
echo "password is ${PASSWORD}"

exit 0




