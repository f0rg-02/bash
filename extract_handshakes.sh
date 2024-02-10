#!/usr/bin/env bash

FILE_PATH=""
OUTPUT_PATH=""
DIR_PATH=""

usage() {  # Function: Print a help message.
  echo "Usage: $0 
		[ -f FILE PATH OF THE HANDSHAKE PCAP FILES ]
		
		or
		
		[ -d DIRECTORY TO FIND PCAP FILES TO TRY TO EXTRACT HANDSHAKES FROM ] 
		
		[ -o OUTPUT PATH TO SAVE RESULTS IN ]" 1>&2
  echo "---------------"
  echo "Example: $0 -f /path/to/handshakes/handshakes.pcap -o ~/Documents/hashcat/wpa_handshakes"

}

exit_abnormal() { # Function: Exit with error.
  usage
  echo "---------------"
  echo "Exiting!"
  exit 1
}

# Check if args were inputted

while getopts "f:o:d:h" opt
do
        case ${opt} in
        f)
                echo "File to extract handshakes from: ${OPTARG}"
                FILE_PATH="${OPTARG}"
                ;;
        d)
				echo "Directory to try to find pcap files from: ${OPTARG}"
				DIR_PATH="${OPTARG}"
				;;
        o)
				echo "Path to save output to: ${OPTARG}"
				OUTPUT_PATH="${OPTARG}"
				;;
        h)
                echo "---------------"
                exit_abnormal
                ;;
        esac
done

if [[ -z "$OUTPUT_PATH" ]]
then
	echo "Not enough arguments were supplied"
	exit_abnormal
fi


mkdir -p "$OUTPUT_PATH"
cd "$OUTPUT_PATH"

if [[ -n "$FILE_PATH" ]]
then
	date_now=$(date "+%F-%H-%M-%S")
	echo "Extracting handshakes from specified file"
	cap2hccapx "$FILE_PATH" "$date_now"-handshakes.hccapx
elif [[ -n "$DIR_PATH" ]]
then
	files=$(find "$DIR_PATH" -name "*.pcap")
	
	while IFS= read -r file
	do
		date_now=$(date "+%F-%H-%M-%S")
		cap2hccapx "$file" "$date_now"-handshakes.hccapx
		sleep 1
	done <<< "$files"
fi

echo "Done!"
