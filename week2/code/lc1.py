birds = ( ('Passerculus sandwichensis','Savannah sparrow',18.7),
          ('Delichon urbica','House martin',19),
          ('Junco phaeonotus','Yellow-eyed junco',19.5),
          ('Junco hyemalis','Dark-eyed junco',19.6),
          ('Tachycineata bicolor','Tree swallow',20.2),
         )

#(1) Write three separate list comprehensions that create three different
# lists containing the latin names, common names and mean body masses for
# each species in birds, respectively. 
latin_names_list = [bird[0] for bird in birds]
common_names_list = [bird[1] for bird in birds]
mean_body_masses_list = [bird[2] for bird in birds]
print(using list co)
print(latin_names_list)
print(common_names_list)
print(mean_body_masses_list)

# (2) Now do the same using conventional loops
latin_names_loop = []
for bird in birds:
    latin_names_loop.append(bird[0])

common_names_loop = []
for bird in birds:
    common_names_loop.append(bird[1])

mean_body_masses_loop = []
for bird in birds:
    mean_body_masses_loop.append(bird[2])

print(latin_names_loop)
print(common_names_loop)
print(mean_body_masses_loop)