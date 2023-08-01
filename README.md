# VIP Media Import Scripts

## Overview

These are broken up into multiple files so I could work on sections while the long process was running or so I could monitor the output files:

### 1-media-errors-txt-to-csv.sh:
Converts the VIP-CLI media upload error file from the output txt to a CSV with these columns: filepath and error message. This was easier to filter which images the import log and find all files with a certain error. 

To test, extract example file: `example-input-files/media-import-sitename-1689270583193.txt` and comment out the line calling `gm`.

### 2-test-mime.sh:
Tests using GMagick whether media files in a list match their mime type. Result is a CSV file with these columns: path, file format, TRUE/FALSE if this matches the file extension. The uploads need to be downloaded to your local machine. 

To test, extract example file: `example-input-files/uploads-file-list.txt` and comment out the line calling `gm`.

### 3-test-mime-status.sh
Takes a CSV from the previous step and tests the image URL's status code and what content type is returned from the site. Columns: path, file format, if format matches, image url, response status code, response content type. I needed this info to confirm which files needed to be converted, marked as invalid files, or marked as false positives.

### 4-test-mime-status-convert.sh
Takes a CSV from the previous step and converts the marked files using GMagick. This copies the marked files to a new uploads directory before converting so they can be zipped and uploaded more easily. Output is the new folder and a log file with converted image paths.

## Requirements

- GraphicsMagick - http://www.graphicsmagick.org/
  - `brew install graphicsmagick`