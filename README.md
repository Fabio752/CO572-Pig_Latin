Coursework For CO572 Advanced Databases.

Questions
1. Write a Pig script that writes a CSV file with the scheme (state name) containing all those
state names in feature for which there are no corresponding records in state. The result must
be ordered by state name, return the names of states found in upper case, should assume all
records in state are in upper case, and ignore difference in case between the two tables.
marks 20

2. Write a Pig script that writes a CSV file with the scheme (state name,population,elevation)
that returns in order of state name the sum of the population and the average elevation of
all populated place data in a given state. The result must be ordered by state name, and
elevation data must be rounded to the nearest integer.
marks 20

3. Write a Pig script that writes a CSV file with the scheme (state name,county,no ppl,no stream)
the number of populated places and the number of streams recorded in feature in each county.
The result must be ordered by state name and county.
marks 30

4. Write a Pig script that writes a CSV file with the scheme (state name,name,population)
containing the state name and place name of each populated place, returning only the five
largest populated places in each state. The result must be ordered by state name, with
places in each state listed in declining order of population. If populations agree, then order
of name should be used.
marks 30
