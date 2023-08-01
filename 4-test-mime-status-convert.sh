#!/bin/bash

## CONVERT FILES TO CORRECT FORMAT FROM CSV (path mime match url response_status action)
##
## USAGE:
## Run from the directory above the uploads dir
##
## /path/to/this/test-uploaded.sh /path/to/output-status.csv
## RESULT:
## /path/to/output-status-convert.csv

# Allow the input_file path to be passed in when calling the script
input_file=$1
input_dir=$2

# Check to see if the filepath has been passed to the script
if test -z "$input_file"
then
    # If $input_file is empty, read in the value from prompt
    read -p "Path to the csv file (add slash): " input_file
fi

# If the output_dir is empty, prompt for the value
# If the uploads directory of files is in /User/abc/Downloads/uploads, use ./Downloads/ or ./
# Yes, this is confusing, so it needs work
if [ -z "$input_dir" ]; then
    read -p "Relative path to the input dir: " input_dir
fi

# Variables
heading_path="Path"
heading_mime="Mime Type"
heading_action="Action"

# Set the output path to the same input_dir as the input input_file
output_file=$(echo $input_file | sed -r 's/\.(txt|log|csv)/-convert.log/')
output_dir="uploads_converted"

echo "Saving to $output_file ..."

# Check if the input_file exists
if [[ -f "$input_file" ]]; then
    
    # Create a new output file
    echo -e "Converting files..." > $output_file

    while IFS="," read -r path mime match url response_status action; do
            
        # Print to the screen
        # Relies on input csv having files meant to be converted marked as "Convert" or "File something"
        if [[ $action =~ (Convert|File) ]]; then

            # Get the file paths we need
            file_path="${input_dir}${path}"

            output_pattern="s/uploads/${output_dir}\/uploads/"
            output_file_path=$(echo $file_path | sed -r $output_pattern) 
            
            # Copy the original file to the output directory, preserving the directory path
            rsync -R $file_path $output_dir
            
            # Convert the file in the output directory to the format that matches its extension
            gm convert $output_file_path $output_file_path

            # Output to csv file
            csv_line="${action}: ${output_file_path}"
            echo -e $csv_line >> $output_file
        fi

    done < "$input_file"

    echo "Success: File created " $output_file
else
    # If the input_file doesn't exist, show an error message
    echo "Error: File doesn't exist:" $input_file
fi