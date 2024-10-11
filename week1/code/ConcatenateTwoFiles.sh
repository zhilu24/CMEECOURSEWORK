#!/bin/bash

#Extract the file extensions of the first and second inputs
ext1="${1##*.}"
ext2="${2##*.}"

#Check whether the number of input is correct/whether the input files are exist/whether thier extensions match
if [ "$#" -eq 3 ] && [ -f "$1" ] && [ -f "$2" ] && [ "$ext1" = "$ext2" ]; then
   #If all conditions are met and the output file does not exist, create it automatically
   if [ ! -e "$3" ]; then
       echo "Output file '$3' does not exist. Creating a new file."
       touch "$3"
    fi
else
    # Display warnings based on which condition failed.
    if [ "$#" -ne 3 ]; then
        echo "Error: Exactly 3 arguments required: <input_file1> <input_file2> <output_file>."
        exit 1
    elif [ ! -f "$1" ]; then
        echo "Error: Input file '$1' not found."
        exit 2
    elif [ ! -f "$2" ]; then
        echo "Error: Input file '$2' not found."
        exit 3
    elif [ "$ext1" != "$ext2" ]; then
        echo "Error: Input files '$1' and '$2' do not have the same format."
        exit 4
    fi
fi

# Write the content of input file 1 to the output file, then append the content of input file 2 to the same output file
cat "$1" > "$3"
cat "$2" >> "$3"
#Indicate the process was completed successfully and display the output file
echo "Merge process completed successfully. Merged File is"
cat "$3"