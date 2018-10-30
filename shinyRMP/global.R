library(readr)
library(tidyverse)
library(shiny)
library(shinydashboard)
library(DT)
library(googleVis)
library(wordcloud2)
library(RColorBrewer)
library(devtools)
library(SnowballC)
library(tm)

state_conversion <- data.frame(state_abb = state.abb, state_name = state.name)

rmp_df = read_csv("rmprof_full.csv")

rmp_df  %>%
  mutate(state = str_extract(city_state, "(?<=, )\\w+"),
         city = str_extract(city_state, ".*(?=, )")) %>% 
  select(-c(Campus, Safety, Library, Facilities))-> rmp_df

rmp_df <- left_join(rmp_df, state_conversion, by=c("state"="state_abb"))

choice <- colnames(rmp_df %>% select(Clubs:Social))

rmp_df %>% 
  select(school, city_state, date, Clubs:Social) -> rmp_excomment

rmp_df %>% 
  select(date, comment, thumbs_up, thumbs_down) -> rmp_comments

school_choices <- unique(sort(rmp_df$school))




