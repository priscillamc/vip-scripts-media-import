#!/bin/bash

## CONVERT VIP MEDIA IMPORT ERRORS TXT TO CSV
##
## USAGE:
## /path/to/this/txt-to-csv.sh /path/to/media/import/error-file-name.txt
## RESULT:
## /path/to/media/import/error-file-name.csv

# Allow the input_file path to be passed in when calling the script
input_file=$1

# Check to see if the filepath has been passed to the script
if test -z "$input_file"
then
    # If $input_file is empty, read in the value from prompt
    read -p "Path to the error file: " input_file
fi

# Variables
name_heading="File Name"
error_heading="Error Message"
original_heading="Original File"

# Set the output path to the same directory as the input input_file
output_file=$(echo $input_file | sed -r 's/\.txt/.csv/')

# Check if the input_file exists
if [[ -f "$input_file" ]]; then
    
    # Create a new output file with headings
    echo "Creating output file: "$output_file
    echo "$name_heading,$error_heading,$original_heading" > $output_file

    name=""
    error=""
    original_file=""

    # Read each line from the input_file, there's an issue if the file doesn't end with a newline
    while IFS= read -r line || [ -n "$line" ]; do
        
        # Check if this is the input_file name line
        if [[ "$line" == "File Name:"* ]]; then
            name=$(echo "$line" | sed 's/File Name: //')
            continue;
        fi
        # Check if this is the error line
        if [[ "$line" == *"- "* ]]; then
            error=$(echo "$line" | sed 's/^[[:blank:]]*\- //')

            # Split the intermedia image message to allow better filtering
            if [[ $error =~ "original file" ]]; then
                original_pattern="s/Skipping intermediate image because original file is being imported from //"
                original_file=$(echo $error | sed $original_pattern)
            fi
            
            # Save to output file
            echo "$name,$error,$original_file" >> $output_file
            break;
        fi
    done < "$input_file"

    echo "Success: File created " $output_file
else
    # If the input_file doesn't exist, show an error message
    echo "Error: File doesn't exist:" $input_file
fi