-- Write a Pig script that writes a CSV file with the scheme (state name,county,no ppl,no stream)
-- the number of populated places and the number of streams recorded in feature in each county.
-- The result must be ordered by state name and county.

-- Load the state, feature and populated place tables
RUN /vol/automed/data/usgs/load_tables.pig

not_null_populated_place = 
    FILTER populated_place
    BY (state_code IS NOT NULL,
        county IS NOT NULL);
-- Group the entries by state_code, summing the populations and averaging the elevation
grouped_populated_place_data =
    GROUP not_null_populated_place BY (state_code, county);

-- Sum the populations and average the elevations for places in the same states
count_populated_places =
    FOREACH grouped_populated_place_data {
        GENERATE group AS (state_code, county),
                 COUNT(populated_place) AS no_ppl;
    }

-- Group the entries by state_code, summing the populations and averaging the elevation
grouped_feature_data =
    GROUP feature BY county;

-- Sum the populations and average the elevations for places in the same states
count_feature_streams =
    FOREACH  grouped_feature_data {
        GENERATE group AS county, 
                 COUNT(feature) AS no_stream;
    }

-- Join on county
county_to_places_and_streams = 
    JOIN count_populated_places BY county,
         count_feature_streams BY county;

-- Project just the columns of state we need later
state_data =
    FOREACH state
    GENERATE name AS state_name, 
             code AS state_code;

-- Join on state_code
states_with_population_and_avg_elevation = 
    JOIN state_data BY state_code,
         county_to_places_and_streams BY state_code;

-- Filter out the state_codes as we don't need them in the solution
final_states_table =
    FOREACH states_with_population_and_avg_elevation 
    GENERATE state_name, 
             county_to_places_and_streams::no_ppl,
             county_to_places_and_streams::no_stream;

final_ordered_states_table = 
    ORDER final_states_table
    BY state_name, county;

STORE final_ordered_states_table INTO 'q3' USING PigStorage(',');
