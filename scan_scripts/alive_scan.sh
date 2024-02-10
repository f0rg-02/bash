#!/usr/bin/env bash

interface="$1"
ports="$2"

uuid=$(uuidgen)

sudo mkdir -p /var/log/scans/network_scans/"$uuid"

if [[ -z "$interface" || -z "$ports" ]]
then
	echo "Usage: $0 <interface> <ports>"
	exit 1
fi

ownip=$(ip a show "$interface" | grep -a -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')

range=$(ip a show "$interface" | grep -a -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/[0-9]\{1,\}")
alive=$(sudo nmap -sn -n "$range" -oG - | grep -a -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')

if [[ -z "$alive" ]]
then
	echo "None of the hosts are alive"
	exit 1
fi

echo "$alive" | sudo tee /var/log/scans/network_scans/"$uuid""/alive_hosts.log"

while IFS= read -r ip
do
	sudo rustscan -a "$ip" -p "$ports" --ulimit 5000 --greppable | sed 's/->/-/g' | sudo tee -a /var/log/scans/network_scans/"$uuid""/rustscan_results.log" > /dev/null &

done <<< "$alive"
echo "Waiting for the background processes to finish"
wait

echo "Done!"
