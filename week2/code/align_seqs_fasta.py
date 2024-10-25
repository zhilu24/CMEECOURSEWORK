import csv
import ipdb
import os
import sys
import random

def read_fasta(file_name: str) -> str:
    """Reads a sequence from a fasta file and returns it as a string."""
    with open(file_name,mode='r') as file:
        lines = file.readlines()
        sequence = ''.join(line.strip() for line in lines if not line.startswith('>'))
    return sequence

# A function that computes a score by returning the number of matches starting from arbitrary startpoint (chosen by user)
def calculate_score(s1: str, s2: str, l1: int, l2: int, startpoint: int) -> tuple[int, str]:
    matched = "." # to hold string displaying alignements
    score = 0
    for i in range(l2):
        if (i + startpoint) < l1:
            if s1[i + startpoint] == s2[i]: # if the bases match
                matched = matched + "*"
                score = score + 1
            else:
                matched = matched + "-"

    # some formatted output
    print("." * startpoint + matched)           
    print("." * startpoint + s2)
    print(s1)
    print(score) 
    print(" ")

    return score, matched

def save_best_alignment_to_file(file_name: str, best_alignment:str, best_score:int, s1:str):
    # Check if the directory exists, and create it if necessary
    dir_name = os.path.dirname(file_name)
    if not os.path.exists(dir_name):
        os.makedirs(dir_name)
        print(f"Directory {dir_name} created.")

    with open(file_name, mode='w') as file:
        file.write(f"Best alignment:\n{best_alignment}\n{s1}\n")
        file.write(f"Best score: {best_score}\n")
    print(f"Results saved in: {file_name}")

def find_best_alignment(seq_file1: str, seq_file2: str, output_file: str):
    # Read sequences from the CSV file
    seq1 = read_fasta(seq_file1)
    seq2 = read_fasta(seq_file2)
    ipdb.set_trace() # Debug point to check if sequences are assigned properly

    # Assign the longer sequence s1, and the shorter to s2
# l1 is length of the longest, l2 that of the shortest

    l1 = len(seq1)
    l2 = len(seq2)
    if l1 >= l2:
        s1 = seq1
        s2 = seq2
    else:
        s1 = seq2
        s2 = seq1
        l1, l2 = l2, l1 # swap the two lengths

# now try to find the best match (highest score) for the two sequences
        
    my_best_align = None
    my_best_score = -1

    for i in range(l1): # Note that you just take the last alignment with the highest score
        z, _ = calculate_score(s1, s2, l1, l2, i)
        if z > my_best_score:
                my_best_align = "." * i + s2 
                my_best_score = z

    save_best_alignment_to_file(output_file, my_best_align, my_best_score, s1)

if __name__ == "__main__":

        seq_file1 = "../week1/data/407228326.fasta"
        seq_file2 = "../week1/data/407228412.fasta"


    output_file = f"../results/best_alignment_pair.txt"
    find_best_alignment(seq_file1, seq_file2, output_file)