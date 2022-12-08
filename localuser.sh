#!/bin/bash

#This script will create a local user from the input that a person provides.


# Make sure the script is being executed with superuser privileges.

if [[ ${UID} -ne 0 ]]

then
	echo "you dont have sufficient permission to proceed further"

	exit 1
fi

# Get the username (login)

read -p 'enter the user name: ' USER_NAME

# Get the real name

read -p 'enter the name of the person who this account is for: ' PERSON

# Get the password

read -p 'enter the password: ' PASSWORD

# Create the user with the password

useradd -c "${PERSON}" -m ${USER_NAME}


# Check to see if the useradd command succeeded

if [[ ${?} -ne 0 ]]
then
	echo "adding the user encountered an error"

	exit 1
fi

# Set the password

echo ${USER_NAME}:${PASSWORD} | chpasswd

# Force password change on first login

passwd -e ${USER_NAME} 

# Check to see if the passwd command succeeded

if [[ ${?} -ne 0 ]]
then
        echo "setting password error"

        exit 1
fi

# Display the username, password, and the host where the user was created

HOST=$(hostname)

echo "The user "${USER_NAME}" identified by password "${PASSWORD}" is created on the host "${HOST}""

exit 0
