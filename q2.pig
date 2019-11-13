-- Write a Pig script that writes a CSV file with the scheme (state name,population,elevation)
-- that returns in order of state name the sum of the population and the average elevation of
-- all populated place data in a given state. The result must be ordered by state name, and
-- elevation data must be rounded to the nearest integer.

-- Load the state, feature and populated place tables
RUN /vol/automed/data/usgs/load_tables.pig

-- Project just the columns needed from populated place
populated_place_data = 
    FOREACH populated_place
    GENERATE state_code, population, elevation;

-- Group the entries by state_code, summing the populations and averaging the elevation
grouped_populated_place_data =
    GROUP populated_place_data BY state_code;

-- Sum the populations and average the elevations for places in the same states
summed_pop_and_avg_elevation_data =
    FOREACH grouped_populated_place_data
    GENERATE group AS state_code, 
            SUM(populated_place_data.population) AS population,
            AVG(populated_place_data.elevation) AS elevation;

-- Remove null values.
summed_pop_avg_elevation_not_null = 
    FILTER summed_pop_and_avg_elevation_data
    BY     population IS NOT NULL 
    AND    elevation IS NOT NULL;

-- Project just the columns of state we need later
state_data =
    FOREACH state
    GENERATE name AS state_name, 
             code AS state_code;

-- Join on state_code
states_with_population_and_avg_elevation = 
    JOIN state_data BY state_code,
         summed_pop_avg_elevation_not_null BY state_code;

-- Filter out the state_codes as we don't need them in the solution
final_states_table =
    FOREACH states_with_population_and_avg_elevation 
    GENERATE state_name, 
             summed_pop_avg_elevation_not_null::population AS population,
             ROUND(summed_pop_avg_elevation_not_null::elevation) AS elevation;

final_ordered_states_table = 
    ORDER final_states_table
    BY state_name;

STORE final_ordered_states_table INTO 'q2' USING PigStorage(',');
