def buggyfunc(x):
    y = x
    for i in range(x):
        y = y-1
        import ipdb; ipdb.set_trace()pdb #stop and represent there is an error
        import ipdb; ipdb.set_trace()
        z = x/y
    return z

buggyfunc(20)

def buggyfunc(x):
    y = x
    for i in range(x):
        try: 
            y = y-1
            z = x/y
        except:
            print(f"This didn't work;{x = }; {y = }")
    return z

buggyfunc(20)

def buggyfunc(x):
    y = x
    for i in range(x):
        try: 
            y = y-1
            z = x/y
        except ZeroDivisionError:
            print(f"The result of dividing a number by zero is undefined")
        except:
            print(f"This didn't work;{x = }; {y = }")
        else:
            print(f"OK; {x = }; {y = }, {z = };")
    return z

buggyfunc(20)