#!/usr/bin/env bash

SOURCEDIR=""
OUTPUTFOLDER=""
OUTPUTDIR=""
SRCFOLDER=""

usage() {  # Function: Print a help message.
  echo "Usage: $0 [ -s SOURCE DIRECTORY TO ITERATE THROUGH AND GREP FOR ALL POSSIBLE URLS ] [ -d OUTPUT DIRECTORY ] [ -f OUTPUT FILE ] [ -h HELP ]" 1>&2
}

exit_abnormal() { # Function: Exit with error.
  usage
  echo "---------------"
  echo "Exiting!"
  exit 1
}

 while getopts "s:d:f:h" opt
 do
	 case ${opt} in
		s)
			echo "Source directory: ${OPTARG}"
			SOURCEDIR="${OPTARG}"
			;;
        d)
            echo "Output directory: ${OPTARG}"
            OUTPUTDIR="${OPTARG}"
            ;;
		f)
			echo "Output folder to save links extracted: ${OPTARG}"
			OUTPUTFOLDER="${OPTARG}"
			;;
		h)
			exit_abnormal
			;;
	esac
done

# Check if the arguments were inputted
if [[ -z "$SOURCEDIR" || -z "$OUTPUTFOLDER" || -z "$OUTPUTDIR" ]]
then
	echo "[!] Not all required arugments were supplied"
	echo "---------------"
	exit_abnormal
	exit
fi

# Fuck spaces

SRCFOLDER="$OUTPUTDIR"/"$OUTPUTFOLDER"

mkdir -p "$SRCFOLDER"

FILES=$(find "$SOURCEDIR" -name "*" -type f)

while IFS= read -r file
do
    echo "Checking $file"

    filename=$(echo "$file" | sed -r "s/.+\/(.+)\..+/\1/" | tr "." "_" | tr " " "_")_links.txt

    # Getting results
    results=$(grep -o 'http[^"]*' "$file")

    if [[ -n "$results" ]]
    then
        echo "$results" | tr -d "[" | tr "]" "\n" | tr -d "()" | sort | uniq > "$SRCFOLDER"/"$filename"
    fi

done <<< "$FILES"
