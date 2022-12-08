#!/bin/bash

#generate a random password


PASSWORD=$(date +%s%N | sha256sum | head -c12)

echo "${PASSWORD}"


#add special charecter to the current password


SPECIAL=$(echo '#$%^&*(@)' | shuf | head -c2)

echo "${PASSWORD}${SPECIAL}"

