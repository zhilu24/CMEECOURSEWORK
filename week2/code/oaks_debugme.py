import csv
import sys
import ipdb 
from fuzzywuzzy import fuzz

#Define function
def is_an_oak(name):
    """ Returns True if the genus name is similar to 'Quercus' using fuzzy matching.
        using fuzzywuzzy to allow for common spelling mistakes
    >>> is_an_oak('Quercu')
    True
    >>> is_an_oak('Carya')
    False
    >>> is_an_oak('Quassia')
    False
    >>> is_an_oak('Quercus alba')
    True
    >>> is_an_oak('Quercus rubra')
    True
    >>> is_an_oak('Quercuss robur') 
    True
    >>> is_an_oak('Fagus sylvatica')
    False
    """
    name = name.lower().strip()
    genus = name.split()[0]
    threshold = 85

    similarity = fuzz.ratio(name.split()[0], 'quercus')
    return similarity >= threshold

def main(argv): 
    f = open('../data/TestOaksData.csv','r')
    g = open('../data/JustOaksData.csv','w')
    taxa = csv.reader(f)
    csvwrite = csv.writer(g)

    oaks = set()
    for row in taxa:
        ipdb.set_trace()
        print(row)
        print("The genus is: ")
        print(row[0] + '\n')
        
        if is_an_oak(row[0]):
            print('FOUND AN OAK!\n')
            csvwrite.writerow([row[0], row[1]])   
    f.close()
    g.close()

    return 0
    
if (__name__ == "__main__"):
    status = main(sys.argv)

