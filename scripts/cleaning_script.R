library(tidyverse)
library(leaflet)
library(janitor)

# created this csv manually with the help of https://www.latlong.net/
coordinates <- read_csv("raw_data/coordinates.csv")

sta_data <- read_csv("raw_data/responses.csv") %>% 
  clean_names() %>% 
  #renaming columns
  rename(id = number,
         name = what_is_your_name,
         role = what_is_your_skillset_job_role,
         location = where_do_you_live,
         img = please_upload_your_photo) %>%
         #remove everything after the comma in locations (i.e Norwich, Norfolk)
  mutate(location = gsub("(.*),.*", "\\1", location),
         #remove City after location name (there is Glasgow & Glasgow City)
         location = gsub(" City", "\\1", location),
         # Removes a following Edinburgh (i.e Blackhall Edinburgh)
         location = gsub(" Edinburgh", "\\1", location),
         #Avoids duplicates due to capitalisation differences (i.e Glasgow vs glasgow)
         location = str_to_title(location),
        # Some NA's in role so changed to "Other"
         role = ifelse(is.na(role), "Other", role),
        # remove url - just leaves with file name
         #img = sub('.*\\/', "", img),
        # removing last names
         name = gsub("(.*) .*", "\\1", name),
        # setting all names to title case
         name = str_to_title(name)
        ) %>% 
  #Adding coordinates matched by location
  left_join(coordinates, by = "location") %>% 
  #this jitter is so slightly move each coordinate so they all show up on the map when not using clustering
  mutate(lat = jitter(lat, 1), long = jitter(long, 1)) %>% 
  write_csv("clean_data/sta_data.csv")


