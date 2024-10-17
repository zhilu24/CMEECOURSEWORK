# Average UK Rainfall (mm) for 1910 by month
# http://www.metoffice.gov.uk/climate/uk/datasets
rainfall = (('JAN',111.4),
            ('FEB',126.1),
            ('MAR', 49.9),
            ('APR', 95.3),
            ('MAY', 71.8),
            ('JUN', 70.2),
            ('JUL', 97.1),
            ('AUG',140.2),
            ('SEP', 27.0),
            ('OCT', 89.4),
            ('NOV',128.4),
            ('DEC',142.2),
           )

# (1) Creating a list of month,rainfall tuples where the amount of rain was greater than 100 mm.
rain_above_100_list = [(month, rain_amount)for month, rain_amount in rainfall if rain_amount > 100]

rain_above_100_loop = []
for month, rain_amount in rainfall:
    if rain_amount > 100:
        rain_above_100_loop.append((month,rain_amount))

output = f"""
Months and rainfall values when the amount of rain was greater than 100mm:
Step #1 using list comprehension:
{rain_above_100_list}

step #2 using conventional loops:
{rain_above_100_loop}
"""
print(output)

# (2) Creating a list of just month names where the amount of rain was less than 50 mm. 
rain_less_50_list = [month for month, rain_amount in rainfall if rain_amount < 50]

rain_less_50_loop = []
for month, rain_amount in rainfall:
    if rain_amount < 50:
        rain_less_50_loop.append(month)

output = f"""
Months and rainfall values when the amount of rain was less than 50mm:
Step #1 using list comprehension:
{rain_less_50_list}

step#2 using conventional loops:
{rain_less_50_loop}
"""
print(output)



