#!/usr/bin/env bash

ip_file=$1
output=$2

if [ "$#" -ne 2 ]
then
    echo "Usage: `basename $0` ip_file output_file"
    exit 1
fi

while read line
do
    command=$(curl -s https://internetdb.shodan.io/"$line")
    ports=$( echo "$command" | jq -r '.ports')
    if [[ "$ports" != null ]]
    then
        ports=$(echo "$command" | jq -r '.ports | @csv')
        echo "Ports open on '$line' are: $ports"
        echo "$line $ports" >> "$output"
        sleep 1
    else
        echo "No ports found on '$line'"
        sleep 1
    fi
done < "$ip_file"
