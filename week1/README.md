# PROJECT NAME: BOOTCAMP ASSIGNMENT WEEK 1

## Project Overview: 
This project is all the coursework from week1. It is focus on basic UNIX programming practice and shell scripting exercises. The goal is to build familiarity with UNIX commands and scripting using shell scripts. It includes basic tasks such as file manipulation, sequence analysis, and format conversion. 
Key exercises involve: 
1. Building familiarity with UNIX directory structures, working with command arguments, redirections, and pipes
2. Writing shell scripts to automate tasks such as file format conversions and developing robust scripts that check input validity.

## Languages and Tools Used:
`Shell Scripting (Bash)`: The scripts are written in Bash
`UNIX Commands`: Basic UNIX commands like grep, wc, tr, tail, and cat 
 
## Dependencies/Installation:
This project does not require any special dependencies beyond a standard UNIX-like environment. All necessary tools should already be available in most UNIX-based systems like Linux or macOS. No additional third-party packages are required.
There is no special installation process for this project.

## Project Structure and Usage:
### Code 
-contains shell scripts exercise and unixpractice

**UnixPrac1.txt**: This file involves analyzing Fasta files using UNIX shell commands. The tasks include counting the number of lines, extracting sequences, calculating the sequence length, counting occurrences and computing the AT/GC ratio.
The input data files include `407228326.fasta`, `407228412.fasta`, `E.coli.dasta` in the `data` directory.

**ConcatenateTwoFiles.sh**, **tabtocsv.sh**: The robustness of those files were improved by adding error handling. 
ConcatenateTwoFiles.sh create a new file with the content of the second file appended to the first file.
tabtocsv.sh substitue all tabs with commas

**csvtospace**: This shell script is designed to convert a CSV file into a space-separated values file without modifying the origin input file. The input files include `1800.csv`, `1801.csv`, `1802.csv`, `1803.csv` in the `data` directory. The converted data will be saved into a new, differently named file in the `result` directory.

CountLines.sh: count the number of lines in a file

boilerplate.sh: example script

variables.sh: illustrates the use of variables

tiff2png.sh: convert the tiff to png


### Data
-contains CSV and FASTA data files used in the exercise

### result
-result files generated after script execution

### sandbox
### gitignore

## Author:
Name: Zhilu Zhang
Contact: zhilu.zhang24@imperial.ac.uk