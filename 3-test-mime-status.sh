#!/bin/bash

## TEST UPLOADED MEDIA FROM A CSV (FILE_PATH,FILE_FORMAT,MATCH)
##
## USAGE:
## /path/to/file/test-mime-status-code.sh /path/to/output-mime.csv newsbtc-com.go-vip.net
## RESULT:
## /path/to/output-mime-status.csv

# Allow the input file and domain to be passed in when calling the script
input_file=$1
domain_site=$2

# If the file is empty, prompt for the value
if test -z "$input_file"
then
    read -p "Path to the input file: " input_file
fi

# If the domain is empty, prompt for the value
if [ -z "$domain_site" ]; then
    read -p "Site domain (www.example.com): " domain_site
fi

# Variables
heading_path="Path"
heading_mime="Mime Type"
heading_match="Match"
heading_url="URL"
heading_status="Status Code"
heading_type="Content-Type/Action"
domain_url="https://${domain_site}/wp-content"


# Set the output path to the same directory as the input input_file
output_file=$(echo $input_file | sed -r 's/\.csv/-status.csv/')

# Check if the input_file exists
if [[ -f "$input_file" ]]; then
    # Create a new output input_file with headings
    echo "Creating output file: "$output_file
    echo -e "$heading_path,$heading_mime,$heading_match,$heading_url,$heading_status,$heading_type" > $output_file

    # Read each line from the input_file
    while IFS="," read -r path mime match; do
        
        if [[ $match =~ FALSE ]]; then

            # Get the url for cURL, replace spaces
            # Needs to real encoding to replace the characters, so this is a hack
            url_unencoded="${domain_url}/${path}"
            url=$(echo $url_unencoded | sed 's/ /%20/')

            # Use cURL to get the uploaded status code and content type
            response=$(curl -Isw "HTTP/2 %{response_code} content-type: %{content_type}" $url)
            response_status=$(echo $response | sed -r 's/HTTP\/2 ([0-9]+) (.*)/\1/')
            response_type=$(echo $response | sed -r 's/(.*)content-type: (.+)\/([^;]+)(.*)/\2\/\3/')

            # Output to CSV, trim any newlines
            match=$(echo $match | tr -d '\r')
            echo -e "$path,$mime,$match,$url,$response_status,$response_type" >> $output_file
        fi
    done < <(tail -n +2 $input_file) # Start at line 2 to avoid the header row

    # Output to a CSV
    echo "Success: File created " $output_file
else
    # If the input_file doesn't exist, show an response_status message
    echo "Error: File doesn't exist:" $input_file
fi