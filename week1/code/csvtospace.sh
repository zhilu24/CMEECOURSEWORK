#!/bin/bash
 
# Check whether the number of input files is correct(exactly one argumet)
if [ "$#" -ne 1 ]; then
    echo "Error: Exactly one argument (a CSV file) is required."
    exit 1 # Exit if the number is incorrect
# Check if the input file exists
elif [ ! -f "$1" ]; then
    echo "Error: Input file '$1' not found or not accessible."
    exit 2 
# Check if the input file has a .csv extension
elif [ "${1##*.}" != "csv" ]; then
    echo "Error: Input file must be a CSV file with .csv extension."
    exit 3
fi

# Get the base name of the input file
input_file_basename=$(basename "$1" .csv)

# Define the output directory path
output_dir="../result"

# Create the output file name in the result directory with "_converted.txt" appended
output_file="$output_dir/${input_file_basename}_converted.txt"

# Convert the CSV file by replacing commas with spaces and save it to the output file
tr ',' ' ' < "$1" > "$output_file"

# Indicating the process is complete and show the output file name
echo "Conversion complete. The new file is saved as '$output_file'"

# Exit successfully
exit 0
