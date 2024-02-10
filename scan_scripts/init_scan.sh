#!/usr/bin/env bash

interface="$1"

if [[ -z "$interface" ]]
then
	echo "Usage: $0 <interface>"
	exit 1
fi

uuid=$(uuidgen)

log_path=/var/log/scans/network_scans/"$uuid"

sudo mkdir -p "$log_path"
file="$log_path""/alive_hosts.log"

./find_alive.sh "$interface" "$file"
./run_nxc.sh "$file" "$log_path"

echo "Done!"