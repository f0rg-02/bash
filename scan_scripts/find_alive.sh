#!/usr/bin/env bash

interface="$1"
file="$2"

if [[ -z "$interface" || -z "$file" ]]
then
	echo "Usage: $0 <interface> <output_file_to_save_results>"
	exit 1
fi

# Grep our own ip
ownip=$(ip a show "$interface" | grep -a -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')

# Grep the range of the interface
range=$(ip a show "$interface" | grep -a -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/[0-9]\{1,\}")

# nmap ping scan to find all alive hosts and grep for ips
alive=$(sudo nmap -sn -n "$range" -oG - | grep -a -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')

# Check if alive variable is empty or not
if [[ -z "$alive" ]]
then
	echo "None of the hosts are alive"
	exit 1
else
	# Remove our own ip from the list of alive ips
	# Write the final result to the file
    echo "$alive" | grep -v "$ownip" | sudo tee -a "$file" > /dev/null
fi
