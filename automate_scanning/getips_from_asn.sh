#!/usr/bin/env bash

# Fuck one liners you lazy buffoons.

# one-liner to convert ASN to ip addresses. Results will be appended to `ips.out`. sander@cedsys.nl | 1-7-2017

ASNFILE=""
OUTPUTFILE=""

usage() {  # Function: Print a help message.
  echo "Usage: $0 [ -f FILE OF ASNs to get IP addresses of ] [ -o OUTPUT FILE ] [ -h HELP ]" 1>&2
}

exit_abnormal() { # Function: Exit with error.
  usage
  echo "---------------"
  echo "Exiting!"
  exit 1
}

 while getopts "f:o:h" opt
 do
	 case ${opt} in
		f)
			echo "ASN file: ${OPTARG}"
			ASNFILE="${OPTARG}"
			;;
		o)
			echo "Final output file: ${OPTARG}"
			OUTPUTFILE="${OPTARG}"
			;;
		h)
			exit_abnormal
			;;
	esac
done

# Check if the arguments were inputted
if [[ -z "$ASNFILE" || -z "$OUTPUTFILE" ]]
then
	echo "[!] Not all required arugments were supplied"
	echo "---------------"
	exit_abnormal
	exit
fi

while IFS= read -r asn # Read file line by line
do
	for range in $(echo $(whois -h whois.radb.net -- "-i origin $asn" | grep -Eo "([0-9.]+){4}/[0-9]+") | sed ':a;N;$!ba;s/\n/ /g')
	do
		echo "$range" >> "$OUTPUTFILE"
	done
done < "$ASNFILE"
