#!/usr/bin/env bash

KEYWORD=""
SRC_DIR=""

OUTPUT_DIR=""

FILES=""
CHK_PATH=""
FILE_TYPE=""

EXTRACT=false

usage() {  # Function: Print a help message.
  echo "Usage: $0 
  [ -k KEYWORD TO PARSE FOR (Required) ] 
  [ -p DIRECTORY PATH TO LOOP THROUGH AND PARSE FILES (Required) ]
  [ -e EXTRACT ANY FILES THAT ARE IN DIRECTORY (zip, tar, tar.gz, etc.) (Optinal argument) ]
  [ -o OUTPUT DIRECTORY TO SAVE RESULTS IN (Defaults to current directory if not specified) ]" 1>&2
  echo "---------------"
  echo "Example: $0 -k boop -p /path/to/directory/to/parse -e true -o "$HOME"/results"

}

exit_abnormal() { # Function: Exit with error.
  usage
  echo "---------------"
  echo "Exiting!"
  exit 1
}

# Check if args were inputted

while getopts "k:p:e:o:h" opt
do
        case ${opt} in
        k)
                echo "Keyword parsing for: '${OPTARG}'"
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
        o)
                echo "Output directory: ${OPTARG}" 
                OUTPUT_DIR="${OPTARG}"
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

chk_path() {

    cd "$CHK_PATH"

    if [[ $(pwd) != "$CHK_PATH" && $(pwd)"/" != "$CHK_PATH" && "$CHK_PTH" != "../" ]]
    then
        echo "[!] Not in the correct source directory: '$CHK_PATH'"
        echo "[!] In directory: '$(pwd)'"
        echo "Exiting!"
        exit 1
    fi

}

chk_keyword() {
    count=0
    while IFS= read -r file
    do

        echo "Parsing: '$file'"
        grep "$KEYWORD" "$file" >> "$OUTPUT_DIR"/"$KEYWORD"_results.txt &

        ((count++))

        if [ $((count % 15)) -eq 0 ]
        then
            echo "Reached maximum of number of processes to run in the background"
            echo "Waiting for them to finish in the background"
            wait
        fi

    done <<< "$FILES"
}

extract_files() {
    
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

            file_name="${file%.*}"  # Remove trailing extension file type
            echo "$file_name"
            mkdir -p "$file_name"

            if [[ $FILE_TYPE == "tar" ]]
            then
                tar xf -C "$file_name" "$file" &
            elif [[ $FILE_TYPE == "zip" ]]
            then
                unzip -qq -d "$file_name" "$file" &
            else
                echo "Unknown error and file type: '$FILE_TYPE' "
            fi

            ((count++))

            if [ $((count % 10)) -eq 0 ]
            then
                echo "Reached maximum of number of processes to run in the background"
                echo "Waiting for them to finish in the background"
                wait
            fi

        done <<< "$FILES"

}

echo "Changing directory to '$SRC_DIR'"
CHK_PATH="$SRC_DIR" # Probably unnecessary, but whatever.

chk_path

if [[ $EXTRACT == "true" ]]
then
    # While testing, learned that some files when extracted can have same names.
    # To avoid overwriting or whatever, extract name from original file and create a folder to extract contents to.
    
    echo "Checking for tar files"
    
    files=$(find "$SRC_DIR" -maxdepth 1 -name "*.tar" )

    # Check if variable files is empty or not
    if [[ -z $files ]]
    then

        echo "[!] No tar files were found"

    else
        FILE_TYPE="tar"
        FILES="$files"

        extract_files

    fi

    echo "Checking for zip files"
    files=$(find "$SRC_DIR" -maxdepth 1 -name "*.zip" )

    # Check if variable files is empty or not
    if [[ -z $files ]]
    then
    
        echo "[!] No zip files were found"

    else
        FILE_TYPE="zip"
        FILES="$files"

        extract_files
        
    fi

fi

FILES=$(find "$SRC_DIR" -type f \( -not -name "*.zip" -and -not -name "*.tar*" \))

if [[ -z $FILES ]]
then

    echo "[!] No files were found to parse"

else

    # cd ../
    # mkdir -p results/keyword_parse
    # cd results/keyword_parse

    if [[ -n "$OUTPUT_DIR" ]]
    then

        mkdir -p "$OUTPUT_DIR"

    fi

    chk_keyword

fi
echo "Done!"
