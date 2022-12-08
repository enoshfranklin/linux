#!/bin/bash


MYSQL=$(which mysql)


if [[ ${?} -eq 0 ]]
then
	echo "mysql path is ${MYSQL}"
else
	echo "mysql is not installed"

	
fi


#testing for looop

PASSWORD=$(date +%s%n | sha256sum | head -c12)

for i in "${@}"
do
	echo "${i}: ${PASSWORD}"
done


