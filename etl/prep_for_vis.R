library(tidyverse)
library(janitor)
library(here)
library(lubridate)
library(geojsonio)
library(sf)

chicago <- read_csv(here("data", "raw", "com_ed_chicago_ozone_max_2023.csv"))
muskegon <- read_csv(here("data", "raw", "muskegon_ozone_max_2023.csv"))
cleveland <- read_csv(here("data", "raw", "district_6_cleveland_ozone_max_2023.csv"))

all_cities <- rbind(chicago, cleveland, muskegon) %>% 
  mutate(Date = mdy(Date)) %>% 
  filter(Date >= "2023-05-01" & Date <= "2023-06-30") %>% 
  filter(!Source == "AirNow") %>% 
  mutate(name = case_when(`Site Name` == "COM ED MAINTENANCE BLDG" ~ "Chicago",
                         `Site Name` == "District 6" ~ "Cleveland",
                         TRUE ~ "Muskegon")) %>% 
  select(Date, `Daily Max 8-hour Ozone Concentration`, name) %>% 
  mutate(exceedence = case_when(`Daily Max 8-hour Ozone Concentration` > .07 ~ "Y", TRUE ~ "N")) %>% 
  mutate(name = case_when(name == "Chicago" & exceedence == "Y" ~ "Chicago, IL",
                          name == "Muskegon" & exceedence == "Y" ~ "Muskegon, MI",
                          name == "Cleveland" & exceedence == "Y" ~ "Cleveland, OH",
                          TRUE ~ name))
  

#pivot_wider(names_from = name, values_from = `Daily Max 8-hour Ozone Concentration`)

write.csv(all_cities, "data/processed/all_cities_daily_max_ozone_2023.csv")

# Nonattainment map 

# Filter our background map of states to just 12 Midwestern states 
midwest_states <- st_read(here("data", "raw", "states.geojson")) %>% 
  filter(NAME %in% c("Illinois", "Indiana", "Iowa", "Kansas", "Michigan", "Minnesota", "Missouri", "Nebraska", "North Dakota", "Ohio", "South Dakota", "Wisconsin"))

# Filter our nonattainment map to 12 Midwestern states 
midwest_nonattainment_areas <- st_read(here("data", "raw", "nonattainment_areas.geojson")) %>%
  filter(state_name %in% c("Illinois", "Indiana", "Iowa", "Kansas", "Michigan", "Minnesota", "Missouri", "Nebraska", "North Dakota", "Ohio", "South Dakota", "Wisconsin"))
  

st_write(midwest_states, "data/processed/midwest_states.geojson")

st_write(midwest_nonattainment_areas, "data/processed/midwest_nonattainment_areas.geojson")


# Convert hectares to acres 
# 2.471054 acres is one hectar

canada_acres_burned <-  read_csv(here("data", "raw", "canadian_areas_burned_1993_2023.csv")) %>% 
  mutate(area_burned_acres = round(area_burned_ha*2.471054, digits= 0)) 
  

average_before_2023 <- canada_acres_burned %>% 
  filter(!year == 2023)

# Mean is 6,065,859 
summary(average_before_2023)

write_csv(canada_acres_burned, "data/processed/canada_acres_burned.csv")
