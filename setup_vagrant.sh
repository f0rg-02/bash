#!/usr/bin/env bash

VAGRANT_VM=""
FILE_PATH=""

usage() {  # Function: Print a help message.
  echo "Usage: $0 [ -n VAGRANT VM BOX NAME ] [ -p FILE PATH TO CREATE VAGRANT FOLDER IN ]" 1>&2
  echo "---------------"
  echo "Example: $0 -p vagrant_vms -n ubuntu/trusty64 (as according to https://app.vagrantup.com/ubuntu/boxes/trusty64)"

}

exit_abnormal() { # Function: Exit with error.
  usage
  echo "---------------"
  echo "Exiting!"
  exit 1
}

# Check if args were inputted

while getopts "n:p:h" opt
do
        case ${opt} in
        n)
                echo "Vagrant box name: ${OPTARG}"
                VAGRANT_VM="${OPTARG}"
                ;;
        p)
                echo "Path to create vagrant folder in: ${OPTARG}"
                FILE_PATH="${OPTARG}"
                ;;
        h)
                echo "---------------"
                exit_abnormal
                ;;
        esac
done

# Check if supplied arguments are empty or not

if [[ -z "$VAGRANT_VM" || -z "$FILE_PATH" ]]
then
        echo "[!] Not all required arugments were supplied"
        echo "---------------"
        exit_abnormal
        exit
fi

echo "[*] Setting up vagrant box"

DIR=$FILE_PATH/${VAGRANT_VM//[\/]/_}

mkdir -p "$DIR" && cd "$DIR" && {
    vagrant init "$VAGRANT_VM"
    vagrant up
    vagrant suspend
}
