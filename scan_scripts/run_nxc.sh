#!/usr/bin/env bash

file="$1"
output="$2"

if [[ -z "$file" || -z "$output" ]]
then
    echo "Usage: $0 <file_with_ips> <directory_to_save_results>"
    exit 1
fi

protocols=("smb" "ssh" "winrm" "rdp")

for protocol in "${protocols[@]}"
do
    nxc --no-progress "$protocol" "$file" | sudo tee -a "$output""/nxc_results.log" > /dev/null &
done

