-- Write a Pig script that writes a CSV file with the scheme (state name) containing all those
-- state names in feature for which there are no corresponding records in state. The result must
-- be ordered by state name, return the names of states found in upper case, should assume all
-- records in state are in upper case, and ignore difference in case between the two tables.

-- Load the state, feature and populated place tables
RUN /vol/automed/data/usgs/load_tables.pig

-- Project just the column of feature we need later in uppercase
feature_data =
    FOREACH feature
    GENERATE UPPER(state_name) AS state_name;

-- Project just the column of state we need later
state_data =
    FOREACH state
    GENERATE name AS state_name;

-- Join left so that the states that are present in feature and not in state will have state::name = NULL
feature_and_state_names = 
    JOIN feature_data BY state_name LEFT,
         state_data BY state_name;

-- Filter out the names that are in both tables
states_not_in_state_table =
    FILTER feature_and_state_names 
    BY state_data::state_name IS NULL;

-- Final table
final_table = 
    FOREACH states_not_in_state_table
    GENERATE feature_data::state_name AS state_name;

-- Filter out redundancy : bag->set
distint_final_table =
    DISTINCT final_table;
    
-- Sort result
sorted_final_table =
    ORDER distint_final_table
    BY state_name;
    
STORE sorted_final_table INTO 'q1' USING PigStorage(',');

