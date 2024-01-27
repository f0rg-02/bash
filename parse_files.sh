#!/usr/bin/env bash

KEYWORD=""
SRC_DIR=""
EXTRACT=false

usage() {  # Function: Print a help message.
  echo "Usage: $0 
  [ -k KEYWORD TO PARSE FOR ] 
  [ -p DIRECTORY PATH TO LOOP THROUGH AND PARSE FILES ]
  [ -e EXTRACT ANY FILES THAT ARE IN DIRECTORY (zip, tar, tar.gz, etc.) (Optinal argument) ]" 1>&2
  echo "---------------"
  echo "Example: $0 -k boop -p /path/to/directory/to/parse -e true"

}

exit_abnormal() { # Function: Exit with error.
  usage
  echo "---------------"
  echo "Exiting!"
  exit 1
}

# Check if args were inputted

while getopts "k:p:e:h" opt
do
        case ${opt} in
        k)
                echo "Keyword parsing for: ${OPTARG}"
                KEYWORD="${OPTARG}"
                ;;
        p)
                echo "Directory path to loop through and parse files: ${OPTARG}"
                SRC_DIR="${OPTARG}"
                ;;
        e)
                echo "Extracting files"
                EXTRACT="${OPTARG}"
                ;;
        h)
                echo "---------------"
                exit_abnormal
                ;;
        esac
done

# Check if supplied arguments are empty or not

if [[ -z "$KEYWORD" || -z "$SRC_DIR" ]]
then
        echo "[!] Not all required arugments were supplied"
        echo "---------------"
        exit_abnormal
        exit
fi

echo "Changing directory to '$SRC_DIR'"
cd "$SRC_DIR"

# pwd returns without a / at the end so added the 
# second part of the if statement to account for this
if [[ $(pwd) != "$SRC_DIR" && $(pwd)"/" != "$SRC_DIR" ]]
then
    echo "[!] Not in the correct source directory: '$SRC_DIR'"
    echo "[!] In directory: '$(pwd)'"
    echo "Exiting!"
    exit 1
fi

if [[ $EXTRACT == "true" ]]
then
    # While testing, learned that some files when extracted can have same names.
    # To avoid overwriting or whatever, extract name from original file and create a folder to extract contents to.
    
    echo "Checking for tar files"
    
    #find "$SRC_DIR" -iname "*.tar" -maxdepth 1 -exec tar xvf "{}" \;
    files=$(find "$SRC_DIR" -maxdepth 1 -name "*.tar" )

    # Check if variable files is empty or not
    if [[ -z $files ]]
    then

        echo "[!] No tar files were found"

    else

        count=0

        # How to calculate count properly
        # Using modulus

        #if [ $((n % 2)) -eq 0 ]; then
        #>   echo "Number $n is even"
        #> else
        #>   echo "Number $n is odd"
        #> fi

        while IFS= read -r file
        do

            file_name="${file%.*}"  # Remove trailing tar
            echo "$file_name"
            mkdir -p "$file_name"
            tar xf -C "$file_name" "$file" &

            ((count++))

            if [ $((count % 10)) -eq 0 ]
            then
                echo "Reached maximum of number of processes to run in the background"
                echo "Waiting for them to finish in the background"
                wait
            fi

        done <<< "$files"

    fi

    echo "Checking for zip files"
    #find "$SRC_DIR" -iname "*.zip" -maxdepth 1 -exec unzip "{}" \;
    files=$(find "$SRC_DIR" -maxdepth 1 -name "*.zip" )

     # Check if variable files is empty or not
    if [[ -z $files ]]
    then
    
        echo "[!] No zip files were found"

    else

        # Reset counter
        count=0


        # Could've done this: unzip -d ${$1%.zip}
        # But it looks ugly

        while IFS= read -r file
        do

            file_name="${file%.*}"  # Remove trailing zip
            echo "$file_name"
            mkdir -p "$file_name"
            unzip -qq -d "$file_name" "$file" &

            ((count++))

            if [ $((count % 10)) -eq 0 ]
            then
                echo "Reached maximum of number of processes to run in the background"
                echo "Waiting for them to finish in the background"
                wait
            fi

        done <<< "$files"
    fi

fi

files=$(find "$SRC_DIR" -type f \( -not -name "*.zip" -and -not -name "*.tar*" \))

if [[ -z $files ]]
then

    echo "[!] No files were found to parse"

else

    cd ../
    mkdir -p results/keyword_parse
    cd results/keyword_parse

    count=0
    while IFS= read -r file
    do

        echo "Parsing: '$file'"
        grep "$KEYWORD" "$file" >> "$KEYWORD"_results.txt &

        ((count++))

        if [ $((count % 15)) -eq 0 ]
        then
            echo "Reached maximum of number of processes to run in the background"
            echo "Waiting for them to finish in the background"
            wait
        fi

    done <<< "$files"

echo "Done!"
fi