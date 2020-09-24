library(tidyverse)
library(tidytext)
library(jsonlite)
library(tidyjson)
library(rjson)

articles <- fromJSON(readLines('data/articles.json'),
                     simplifyVector = TRUE)


comment_files <- list.files("data",pattern = "^comments", full.names = T)
comment_files <- comment_files[file.size(comment_files)>0] 
content_list_dt <-lapply(comment_files, function(x) {message(x);fromJSON(readLines(x),simplifyVector = TRUE)})

consolidated_comments <- plyr::ldply(content_list_dt)
rm(content_list_dt)

consolidated_comments$id <- as.character(consolidated_comments$id)
consolidated_comments$parent <- as.character(consolidated_comments$parent)
consolidated_comments$kids <- as.character(consolidated_comments$kids)
consolidated_comments <- consolidated_comments[complete.cases(consolidated_comments),]

# live/ history of user

duration_dt <-consolidated_comments %>%
  group_by(by) %>%
  mutate(duration = difftime(max(time,na.rm = T) , min(time,na.rm = T),units = "day")) %>%
  select(by, duration)
duration_dt <- duration_dt[!duplicated(duration_dt),] 


ggplot(duration_dt, aes(x = duration)) +
  geom_histogram(aes(fill = ..count..)) +
  xlab("Days") + ylab("Users")

duration_dt_without_zero <- duration_dt[duration_dt$duration != 0,]
ggplot(duration_dt_without_zero, aes(x = duration)) +
  geom_histogram(aes(fill = ..count..)) +
  xlab("Days") + ylab("Users")

ggplot(duration_dt_without_zero, aes(x = duration)) +
  geom_histogram(aes(y = ..density.., fill = ..density..)) +
  xlab("Days") + ylab("Desnisty")+
  geom_density(alpha = .2, color = "red")

# live/ history of user
duration_dt_hr <-consolidated_comments %>%
  group_by(by) %>%
  mutate(duration = difftime(max(time,na.rm = T) , min(time,na.rm = T),units = "hours")) %>%
  select(by, duration)
duration_dt_hr <- duration_dt_hr[!duplicated(duration_dt_hr),] 


ggplot(duration_dt_hr, aes(x = duration)) +
  geom_histogram(aes(fill = ..count..)) +
  xlab("Hours") + ylab("Users")

duration_dt_hr_without_zero <- duration_dt_hr[duration_dt_hr$duration != 0,]
ggplot(duration_dt_hr_without_zero, aes(x = duration)) +
  geom_histogram(aes(fill = ..count..)) +
  xlab("Hours") + ylab("Users")

ggplot(duration_dt_hr_without_zero, aes(x = duration)) +
  geom_histogram(aes(y = ..density.., fill = ..density..)) +
  xlab("Hours") + ylab("Desnisty")+
  geom_density(alpha = .2, color = "red")


#Average hrs spend on website 74.49309 hours
############################################################
library(lubridate)

