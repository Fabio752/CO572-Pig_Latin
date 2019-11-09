-- Write a Pig script that writes a CSV file with the scheme (state name,name,population)
-- containing the state name and place name of each populated place, returning only the five
-- largest populated places in each state. The result must be ordered by state name, with
-- places in each state listed in declining order of population. If populations agree, then order
-- of name should be used.

-- Load the state, feature and populated place tables
RUN /vol/automed/data/usgs/load_tables.pig

-- Start by considering just columns we need
ppl_data = 
    FOREACH populated_place
    GENERATE name, county, state_code, population;

-- Also for state
state_data =
    FOREACH state
    GENERATE code, name;
-- Join the two tables on the state_code
ppl_full_data = 
    JOIN state_data BY code,
         ppl_data BY state_code;

-- Remove the state_code column 
ppl_data = 
    FOREACH ppl_full_data
    GENERATE state_data::name AS state_name,
             ppl_data::name AS name,
             population;

-- Group the result by name of the state
grouped_ppl_data = 
    GROUP ppl_data
    BY state_name;

-- Sort it by the name of the state
sorted_ppl_data = 
    ORDER grouped_ppl_data
    BY group;

-- Filter out the places not in the top five most populated
five_most_populated =
    FOREACH sorted_ppl_data {
        sort_pop =
            ORDER ppl_data
            BY population DESC, name;

        pop_limit = LIMIT sort_pop 5;
        
        GENERATE FLATTEN(pop_limit);
    }

STORE five_most_populated INTO 'q4' USING PigStorage(',');
