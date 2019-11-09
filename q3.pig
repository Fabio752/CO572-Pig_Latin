-- Write a Pig script that writes a CSV file with the scheme (state name,county,no ppl,no stream)
-- the number of populated places and the number of streams recorded in feature in each county.
-- The result must be ordered by state name and county.

-- Load the state, feature and populated place tables
RUN /vol/automed/data/usgs/load_tables.pig

-- Remove not used columns in feature table
feature_data = 
    FOREACH feature
    GENERATE type, county, state_name;

-- Group the entries by state name and county
grouped_feature_data =
    GROUP feature_data
    BY (state_name, county);

-- Count the ppl types and stream types for each county
count_ppl_stream_counties =
    FOREACH grouped_feature_data {
        populated_places =
            FILTER feature_data
            BY type == 'ppl';
        streams = 
            FILTER feature_data
            BY type == 'stream'; 
        GENERATE group.state_name AS state_name,
                 group.county AS county,
                 COUNT(populated_places) AS no_ppl,
                 COUNT(streams) AS no_stream;
    }

-- Sort output
sorted_count_ppl_stream_counties = 
    ORDER count_ppl_stream_counties
    BY state_name, county;

STORE sorted_count_ppl_stream_counties INTO 'q3' USING PigStorage(',');
