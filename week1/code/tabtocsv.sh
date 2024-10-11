#!/bin/sh
# Author: Your name you.login@imperial.ac.uk
# Script: tabtocsv.sh
# Description: substitute the tabs in the files with commas
#
# Saves the output into a .csv file
# Arguments: 1 -> tab delimited file
# Date: Oct 2019


 # Check if the number of input arguments is correct.(exactly one argument)
if [ "$#" -ne 1 ]; then
    echo "Error: Exactly one argument is required."
    exit 1 # Exit with error code 1
fi
 
if [ ! -f "$1" ]; then
    echo "Error: Input file '$1' not found."
    exit 2
fi

# Extract the file extension of the input file
ext="${1##*.}"

# Check if the file is already in CSV format to avoid unnecessary operations. 
if grep -q "," "$1"; then
    if [ "$ext" = "csv" ]; then
        echo "The file '$1' is already in CSV format and has a .csv extension."
        exit 0 #Exit successfully
    else
       # Consider if the file content is in CSV format, but the file does not have a .csv extension, rename it
        new_output="${1}.csv"
        echo "The file '$1' appears to be in CSV format. Renaming it to '$new_output'."
        mv "$1" "$new_output"
        exit 0
    fi
fi

# Check it is tab-delimited to ensure the input file format is correct
if ! grep -q $'\t' "$1"; then
    echo "Error: Input file '$1' does not appear to be tab-delimited."
    exit 3
fi

# Convert the file to a comma-delimited (CSV) file
echo "Creating a comma delimited version of $1 ..."
cat "$1" | tr -s "\t" "," > "$1.csv" # Replace tabs with commas and save the output as a new .csv file
echo "Done!" # Notify all good!
 
exit 0
 
