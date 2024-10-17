def buggyfunc(x):
    y = x
    for i in range(x):
        y = y-1
        import ipdb; ipdb.set_trace()pdb #stop and represent there is an error
        import ipdb; ipdb.set_trace()
        z = x/y
    return z

buggyfunc(20)

%run debugme.py
#