import csv
import ipdb
import os

def read_sequences_from_csv(file_name: str) -> tuple[str, str]:
    """     
    Reads two sequences from a CSV file.     
        Args:     
        - file_name (str): Path to the CSV file.    
         Returns:     
         - tuple: Two sequences as strings.     
         Raises:    
         - ValueError: If the file does not contain at least two sequences.     
    """
    with open(file_name, mode='r') as file:
        csv_reader = csv.reader(file)
        sequences = [row[0] for row in csv_reader if row]
    if len(sequences) < 2:
        raise ValueError("The CSV file must contain at least two sequences.")
    ipdb.set_trace()  # Debug point 
    return sequences[0], sequences[1]

def read_sequences_from_csv(file_name: str) -> tuple[str, str]:
    """
    Reads two sequences from a CSV file.

    Args:
    - file_name (str): Path to the CSV file.

    Returns:
    - tuple: Two sequences as strings.
    """
    with open(file_name,mode='r') as file:
        csv_reader = csv.reader(file)
        sequences = []
        for row in csv_reader:
            sequences.append(row[0])
    #assuming two sequences are provided
    ipdb.set_trace() #Debug point to check if sequences are read correctly
    return sequences[0], sequences[1]

# A function that computes a score by returning the number of matches starting from arbitrary startpoint (chosen by user)
def calculate_score(s1: str, s2: str, l1: int, l2: int, startpoint: int) -> tuple[int, str]:
    """
    Calculates the score between two sequences from a given start point.

    Args:
    - s1 (str): First sequence (usually the longer one).
    - s2 (str): Second sequence (usually the shorter one).
    - l1 (int): Length of the first sequence.
    - l2 (int): Length of the second sequence.
    - startpoint (int): Position to start the alignment.

    Returns:
    - tuple: The alignment score and a string showing matches/mismatches.
    """
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
    """
    Saves the best alignment and score to a file.

    Args:
    - file_name (str): Path to the output file.
    - best_alignment (str): Best alignment string.
    - best_score (int): Best score.
    - s1 (str): The longer sequence used in the alignment.
    """
    dir_name = os.path.dirname(file_name)
    if not os.path.exists(dir_name):
        os.makedirs(dir_name)
        print(f"Directory {dir_name} created.")

    with open(file_name, mode='w') as file:
        file.write(f"Best alignment:\n{best_alignment}\n{s1}\n")
        file.write(f"Best score: {best_score}\n")
    print(f"Results saved in: {file_name}")

def find_best_alignment(seq_file: str, output_file: str):
    """
    Finds the best alignment between two sequences from a CSV file.

    Args:
    - seq_file (str): Path to the CSV file with sequences.
    - output_file (str): Path to save the best alignment and score.
    """
    # Read sequences from the CSV file
    seq1, seq2 = read_sequences_from_csv(seq_file)
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

    for i in range(l1): 
        z, _ = calculate_score(s1, s2, l1, l2, i)
        if z > my_best_score:
                my_best_align = "." * i + s2 
                my_best_score = z

    save_best_alignment_to_file(output_file, my_best_align, my_best_score, s1)

if __name__ == "__main__":
    input_file = "../data/sequences.csv"
    output_file = "../results/best_alignment.txt"
    find_best_alignment(input_file, output_file)