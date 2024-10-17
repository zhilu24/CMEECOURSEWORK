birds = ( ('Passerculus sandwichensis','Savannah sparrow',18.7),
          ('Delichon urbica','House martin',19),
          ('Junco phaeonotus','Yellow-eyed junco',19.5),
          ('Junco hyemalis','Dark-eyed junco',19.6),
          ('Tachycineata bicolor','Tree swallow',20.2),
        )

# Birds is a tuple of tuples of length three: latin name, common name, mass.
# write a (short) script to print these on a separate line or output block by
# species 

# Method 1 in separate line:

for latin_name, common_name, mass in birds:
    print(f"Latin_name: {latin_name} Common name: {common_name} Mass: {mass}")


# Method 2 in block:
for bird in birds:
    latin_name, common_name, mass = bird
    print(f"Latin name: {latin_name}")
    print(f"Common name: {common_name}")
    print(f"Mass: {mass}g")
    print()