library(tidyverse)
library(tidytext)
library(jsonlite)
library(tidyjson)
library(rjson)

articles <- fromJSON(readLines('data/articles.json'),
                     simplifyVector = TRUE)


comment_files <- list.files("data",pattern = "^comments", full.names = T)
comment_files <- comment_files[file.size(comment_files)>0] 

content_list_dt <-lapply(comment_files, function(x) {message(x);rjson::fromJSON(file = x)})
content_list_dt <-lapply(comment_files, function(x) {message(x);fromJSON(readLines(x),simplifyVector = TRUE)})

consolidated_comments <- plyr::ldply(content_list_dt)
rm(content_list_dt)
