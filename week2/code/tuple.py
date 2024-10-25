birds = ( ('Passerculus sandwichensis','Savannah sparrow',18.7),
          ('Delichon urbica','House martin',19),
          ('Junco phaeonotus','Yellow-eyed junco',19.5),
          ('Junco hyemalis','Dark-eyed junco',19.6),
          ('Tachycineata bicolor','Tree swallow',20.2),
        )

# Birds is a tuple of tuples of length three: latin name, common name, mass.
# write a (short) script to print these on a separate line or output block by
# species 

"""
This script processes a tuple of birds where each bird is represented as a tuple of:
- Latin name (str)
- Common name (str)
- Mean body mass in grams (float)

The script demonstrates two different methods to print the details of each bird:
1. Method 1: Prints all details in a single line per bird.
2. Method 2: Prints each detail (latin name, common name, and mass) on separate lines, followed by a blank line for readability.
"""

# Method 1 in separate line:
def print_bird_details():
    """ This loop iterates over the birds tuple and prints the latin name, common name, and mass in a single formatted line for each bird. """

for latin_name, common_name, mass in birds:
    print(f"Latin_name: {latin_name} Common name: {common_name} Mass: {mass}")

print_bird_details()


# Method 2 in block:

def print_bird_details_block():

    """This loop iterates over the birds tuple and prints the latin name, common name, and mass in a block form."""

for bird in birds:
    latin_name, common_name, mass = bird
    print(f"Latin name: {latin_name}")
    print(f"Common name: {common_name}")
    print(f"Mass: {mass}g")
    print()

print_bird_details_block()