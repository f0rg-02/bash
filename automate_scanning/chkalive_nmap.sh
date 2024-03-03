
#!/usr/bin/env bash

FILE="$1"

range=""

scan() {
    alive=$(sudo nmap -T4 -sn -n "$range" -oG - | grep -a -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')

    if [[ -z "$alive" ]]
    then
	    echo "None of the hosts are alive"
	    exit 1
    fi

    echo "$alive" >> alive-hosts.txt
}

count=0

if [[ -n "$FILE" ]]
then
    while IFS= read -r line
    do
        range="$line"
        scan &
        ((count++))

        if [ $((count % 25)) -eq 0 ]
        then
            echo "Reached maximum of number of processes to run in the background"
            echo "Waiting for them to finish in the background"
            wait # Wait for the current background processes to finish running before continuing
        fi
    done < "$FILE"
else
    exit 1
fi
