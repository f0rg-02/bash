#!/bin/bash

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

DSTDIR=""
SRCDIR=""

usage() {  # Function: Print a help message.
  echo "Usage: $0 [ -s DIRECTORY TO BE COPIED ] [ -d WHERE TO COPY TO ] [ -h HELP ]" 1>&2
}

exit_abnormal() { # Function: Exit with error.
  usage
  echo "---------------"
  echo "Exiting!"
  exit 1
}

 while getopts "s:d:h" opt
 do
	 case ${opt} in
		s)
			SRCDIR="${OPTARG}"
			;;
		d)
			DSTDIR="${OPTARG}"
			;;
		h)
			exit_abnormal
			;;
	esac
done

# Check if the arguments were inputted
if [[ -z "$SRCDIR" || -z "$DSTDIR" ]]
then
	echo "[!] Not all required arugments were supplied"
	echo "---------------"
	exit_abnormal
	exit
fi

cp -Ru $SRCDIR $DSTDIR