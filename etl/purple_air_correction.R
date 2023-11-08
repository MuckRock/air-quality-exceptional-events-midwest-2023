library(tidyverse)
library(rio)
library(janitor)
library(here)
library(lubridate)
library(htmlwidgets)
library(plotly)

# STEP 1: Load data 
# Take 60-minute raw readings, and select the columns we need:
# This is https://map.purpleair.com/1/a/ls/mAQI/a10/p604800/cC0?select=169723#14.06/42.31516/-88.46578
woodstock <- read_csv(here("data","raw", "purple_air_download", "169723 2023-04-01 2023-10-01 60-Minute Average.csv")) %>% 
  mutate(name = "woodstock", id = "169723")

# This is LVEJO_5: https://map.purpleair.com/1/a/ls/mAQI/a10/p604800/cC0?select=7920#12.91/41.85461/-87.7342
little_village <- read_csv(here("data","raw", "purple_air_download", "7920 2023-04-01 2023-10-01 60-Minute Average.csv")) %>% 
  mutate(name = "little_village", id = "7920")

# STEP 2: Apply correction formula
# Good guide on how that works: https://community.purpleair.com/t/is-there-a-field-that-returns-data-with-us-epa-pm2-5-conversion-formula-applied/4593/2
all_data_corrected <- rbind(woodstock, little_village) %>%
  # Change UTC time of PurpleAir stamp to Central Time 
  mutate(time_stamp = with_tz(time_stamp, tzone = "America/Chicago")) %>% 
  mutate(date = date(time_stamp)) %>%
  select(name, id, date, time_stamp, humidity, pm2.5_atm_a, pm2.5_atm_b) %>% 
  filter(date >= "2023-04-01" & date < "2023-08-01") %>% 
  mutate(corrected_a = case_when(pm2.5_atm_a >= 0 & pm2.5_atm_a <30 ~ 0.524*pm2.5_atm_a - 0.0862*humidity + 5.75,
                                 pm2.5_atm_a >= 30 & pm2.5_atm_a <50 ~ (0.786*(pm2.5_atm_a/20 - 3/2) + 0.524*(1 - (pm2.5_atm_a/20 - 3/2)))*pm2.5_atm_a -0.0862*humidity + 5.75,
                                 pm2.5_atm_a >= 50 & pm2.5_atm_a <210 ~ 0.786*pm2.5_atm_a - 0.0862*humidity + 5.75,
                                 pm2.5_atm_a >= 210 & pm2.5_atm_a <260 ~ (0.69*(pm2.5_atm_a/50 - 21/5) + 0.786*(1 - (pm2.5_atm_a/50 - 21/5)))*pm2.5_atm_a - 0.0862*humidity*(1 - (pm2.5_atm_a/50 - 21/5)) + 2.966*(pm2.5_atm_a/50 - 21/5) + 5.75*(1 - (pm2.5_atm_a/50 - 21/5)) + 8.84*(10^-4)*pm2.5_atm_a^2*(pm2.5_atm_a/50 - 21/5),
                                 pm2.5_atm_a >= 260 ~ 2.966 + 0.69*pm2.5_atm_a + 8.84*10^-4*pm2.5_atm_a^2)) %>% 
  mutate(corrected_b = case_when(pm2.5_atm_b >= 0 & pm2.5_atm_b <30 ~ 0.524*pm2.5_atm_b - 0.0862*humidity + 5.75,
                                 pm2.5_atm_b >= 30 & pm2.5_atm_b <50 ~ (0.786*(pm2.5_atm_b/20 - 3/2) + 0.524*(1 - (pm2.5_atm_b/20 - 3/2)))*pm2.5_atm_b -0.0862*humidity + 5.75,
                                 pm2.5_atm_b >= 50 & pm2.5_atm_b <210 ~ 0.786*pm2.5_atm_b - 0.0862*humidity + 5.75,
                                 pm2.5_atm_b >= 210 & pm2.5_atm_b <260 ~ (0.69*(pm2.5_atm_b/50 - 21/5) + 0.786*(1 - (pm2.5_atm_b/50 - 21/5)))*pm2.5_atm_b - 0.0862*humidity*(1 - (pm2.5_atm_b/50 - 21/5)) + 2.966*(pm2.5_atm_b/50 - 21/5) + 5.75*(1 - (pm2.5_atm_b/50 - 21/5)) + 8.84*(10^-4)*pm2.5_atm_b^2*(pm2.5_atm_b/50 - 21/5),
                                 pm2.5_atm_b >= 260 ~ 2.966 + 0.69*pm2.5_atm_b + 8.84*10^-4*pm2.5_atm_b^2))

# STEP 3: Apply quality controls on corrected data 
# Part A: Get rid of data with greater than 68 percent difference between two channels
# This removes 17 values                               
all_data_cleaned <- all_data_corrected %>% 
  mutate(diff = (corrected_a - corrected_b)/ ((corrected_a + corrected_b)/2)) %>% 
  filter(diff <= 0.68, diff >= -0.68) 

# Part B: Aggregate data to daily and remove days with less than 90% enough readings for that day
daily_data <- all_data_cleaned %>% 
  # Average corrected means together 
  mutate(corrected_mean = (corrected_a + corrected_b)/2) %>% 
  group_by(date, name) %>% 
  summarize(daily_mean = mean(corrected_mean), num_readings = n()) %>% 
  # Remove days that don't have 90% completeness for 24 hours 
  filter(num_readings >= 21)


# Step 4: Export for visualization
# Pivot for Flourish and export
final_data <- daily_data %>% 
  select(name, date, daily_mean) %>% 
  pivot_wider(names_from = name, values_from = daily_mean) 
  filter(date >= "2023-06-01" & date < "2023-08-01")


write.csv(final_data, "data/processed/purple_air_little_village_woodstock.csv")









