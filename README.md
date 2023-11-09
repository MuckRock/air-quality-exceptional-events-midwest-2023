# air-quality-exceptional-events-midwest-2023

This repository contains data and findings for a collaboration between MuckRock and The Chicago Tribune. Reporting and analysis in this collaboration is a follow-up to the multi-newsroom [“Smoke, Screened,” project](https://www.muckrock.com/project/smoke-screened-the-clean-air-acts-dirty-secret-1117/) published by The California Newsroom, MuckRock and the Guardian. 

"Smoke, Screened" is about the use of a legal tool called the exceptional events rule, which allows local air agencies across the United States to remove bad air days from the regulatory record of the Environmental Protection Agency (EPA) if the data is affected by an "exceptional event," like a wildfire.

You can find earlier "Smoke, Screened" data and analysis in [`air-quality-exceptional-events`](https://github.com/MuckRock/air-quality-exceptional-events) and [`gao-wildfire-exceptions`](https://github.com/MuckRock/gao-wildfire-exceptions). Even more data and analysis driving the investigations of MuckRock's news team are cataloged in [`news-team`](https://github.com/MuckRock/news-team).

## Data 
## PurpleAir readings
We retrieved historical PurpleAir sensor readings using PurpleAir's "Data Download Tool" for two sensors: 
- A [sensor in Woodstock, Ill.](https://map.purpleair.com/1/a/ls/mAQI/a10/p604800/cC0?select=169723#14.06/42.31516/-88.46578) belonging to Jessica Beverly, a source we interviewed for this story
- A [sensor in Little Village, Chicago](https://map.purpleair.com/1/a/ls/mAQI/a10/p604800/cC0?select=7920#12.91/41.85461/-87.7342), belong to the [Little Village Environmental Justice Organization](http://www.lvejo.org/)

These data are hourly averages and stored in [`data/raw/purple_air_download`](data/raw/purple_air_download). 
## EPA Ozone 8-hour averages
The EPA's [Concentration Plot lookup tool](https://www.epa.gov/outdoor-air-quality-data/air-data-concentration-plot) provides daily air quality summary statistics by monitor across the United States. We used this tool to pull data for 8-hour ozone concentrations in several Midwestern cities and compare these to the [2015 EPA standard](https://www.epa.gov/ground-level-ozone-pollution/ozone-national-ambient-air-quality-standards-naaqs) of .07 parts per million. 

These data are stored in [`data/raw/ozone_8_hour_maxes_2023`](data/raw/ozone_8_hour_maxes_2023). 
## EPA AQS data "flagged" for "information" 
Flagging data with a "request exclusion" flag in AQS is one of the first steps in the exceptional events process, though agencies can also add an "informational" flag to data as well. 

These flags are not necessarily a step towards the exceptional events rule, but rather a note for the agency as they earmark data they may want to review later to request this data be excluded through the exceptional events rule.

This data is a snapshot in time and represents data flagged from May 1, 2023 to Aug. 31, 2023 as of August 28, 2023.

These data are stored in [`data/raw/epa_informational_flags`](data/raw/epa_informational_flags).

## Acres burned in Canadian wildfires 

## Methodology 
### PurpleAir Correction 

