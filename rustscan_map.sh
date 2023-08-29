#!/usr/bin/env bash

# variables
HOSTFILE=""
PORTS=""
OUTPUTFILE=""
NMAPFILE=""

usage() {  # Function: Print a help message.
  echo "Usage: $0 [ -f FILE OF IPS TO SCAN  ] [ -n NMAP OUTPUT FILE ] [ -o OUTPUT FILE ] [ -p PORTS ] [ -h HELP ]" 1>&2
}

exit_abnormal() { # Function: Exit with error.
  usage
  echo "---------------"
  echo "Exiting!"
  exit 1
}

 while getopts "f:n:p:o:h" opt
 do
	 case ${opt} in
		f)
			echo "IP file: ${OPTARG}"
			HOSTFILE="${OPTARG}"
			;;
		n)
			echo "Nmap output file: ${OPTARG}"
			NMAPFILE="${OPTARG}"
			;;
		p)
			echo "Ports to scan: ${OPTARG}"
			PORTS="${OPTARG}"
			;;
		o)
			echo "Rustscan output file: ${OPTARG}"
			OUTPUTFILE="${OPTARG}"
			;;
		h)
			exit_abnormal
			;;
	esac
done

# check if any of the variables are empty or not
if [[ -z "$HOSTFILE" || -z "$PORTS" || -z "$OUTPUTFILE" || -z "$NMAPFILE" ]]
then
	echo "[!] Not all required arugments were supplied"
	echo "---------------"
	exit_abnormal
	exit
fi

# run rustscan and output into file in greppable format
sudo rustscan -a "$HOSTFILE" -p "$PORTS" --ulimit 5000 --greppable > "$OUTPUTFILE"

# replace the stupid -> with just a plain - since this would make running cut much easier
sed -i 's/->/-/g' "$OUTPUTFILE"

# after parsing store the ports into an array
declare -a port_array

while IFS= read -r line
do
    cut_ip=$(echo "$line" | cut -d "-" -f1)
    cut_port=$(echo "$line" | cut -d "[" -f2 | cut -d "]" -f1)     
    port_array=${cut_port[@]}
    echo "---------------"
    echo "Ip is: $cut_ip"
    echo "Ports are: ${port_array[@]}" && echo
    sudo nmap -T4 -Pn -vv -A --open -p $cut_port --append-output -oX "$NMAPFILE" $cut_ip # run the ip with open ports from rustscan in nmap
    echo "---------------"
done < "$OUTPUTFILE"
echo "Done!"
