#!/bin/bash

## TEST IMAGE FILE FORMAT FROM A LIST OF FILE PATHS (txt/log/csv)
##
## USAGE:
## /path/to/this/test-uploaded.sh /path/to/upload/paths.txt
## RESULT:
## /path/to/upload/paths-mime.csv

# Allow the input_file path to be passed in when calling the script
input_file=$1
output_dir=$2

# Check to see if the filepath has been passed to the script
if test -z "$input_file"
then
    # If $input_file is empty, read in the value from prompt
    read -p "Path to the error file: " input_file
fi

# If the output_dir is empty, prompt for the value
# If the uploads directory of files is in /User/abc/Downloads/uploads, use ./Downloads/ or ./
# Yes, this is confusing, so it needs work
if [ -z "$output_dir" ]; then
    read -p "Relative path to the output dir: " output_dir
fi

# Variables
heading_path="Path"
heading_mime="Mime Type"
heading_match="Match"

# Set the output path to the same output_dir as the input input_file
output_file=$(echo $input_file | sed -r 's/\.(txt|log|csv)/-mime.csv/')

echo "Saving to $output_file"

# Check if the input_file exists
if [[ -f "$input_file" ]]; then
    # Create a new output input_file with headings
    echo -e "$heading_path,$heading_mime,$heading_match" > $output_file

    while IFS="," read -r line; do

        # Print to the screen
        if [[ $line =~ \.(jpg|jpeg|png|eps|gif|bmp|tiff|tif|svg|webp|ico|ttf|JPG|JPEG|PNG|EPS|GIF|BMP|TIFF|TIF|SVG|WEBP|ICO|TTF)$ ]]; then
                        
            # Get the image format using gmagick
            dir_path="${output_dir}${line}"
                        
            format=$(gm identify -verbose $dir_path | grep 'Format:' | head -1)
            
            img_path=$line
            img_format=$(echo ${format/'  Format: '/})
            img_match="FALSE"

            # Test to see if the type matches the expected extension amd type, result in col is TRUE/FALSE
            if [ "$img_format" == "JPEG (Joint Photographic Experts Group JFIF format)" ]; then
                if [[ $line =~ \.(jpg|jpeg|JPG|JPEG)$ ]]; then
                    img_match="TRUE"
                fi
            elif [ "$img_format" == "PNG (Portable Network Graphics)" ]; then
                if [[ $line =~ \.(png|PNG)$ ]]; then
                    img_match="TRUE"
                fi
            elif [ "$img_format" == "GIF (CompuServe graphics interchange format)" ]; then
                if [[ $line =~ \.(gif|GIF)$ ]]; then
                    img_match="TRUE"
                fi
            elif [ "$img_format" == "WEBP (WebP Image Format)" ]; then
                if [[ $line =~ \.(webp|WEBP)$ ]]; then
                    img_match="TRUE"
                fi
            elif [ "$img_format" == "BMP (Microsoft Windows bitmap image)" ]; then
                if [[ $line =~ \.(bmp|BMP)$ ]]; then
                    img_match="TRUE"
                fi
            elif [ "$img_format" == "TIFF (Tagged Image File Format)" ]; then
                if [[ $line =~ \.(tif|tiff|TIF|TIFF)$ ]]; then
                    img_match="TRUE"
                fi
            elif [ "$img_format" == "ICO (Microsoft Icon)" ]; then
                if [[ $line =~ \.(ico|ICO)$ ]]; then
                    img_match="TRUE"
                fi
            elif [ "$img_format" == "MVG (Magick Vector Graphics)" ]; then
                if [[ $line =~ \.(svg|SVG)$ ]]; then
                    img_match="TRUE"
                fi
            elif [ "$img_format" == "TTF (TrueType font)" ]; then
                if [[ $line =~ \.(ttf|TTF)$ ]]; then
                    img_match="TRUE"
                fi
            fi

            csv_line="${img_path},${img_format},${img_match}"
            echo -e $csv_line >> $output_file
        fi

    done < "$input_file"

    echo "Success: File created " $output_file
else
    # If the input_file doesn't exist, show an error message
    echo "Error: File doesn't exist:" $input_file
fi