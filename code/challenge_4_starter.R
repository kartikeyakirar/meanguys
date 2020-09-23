library(tidyverse)
library(tidytext)
library(ggplot2)
library(ggwordcloud)
library(jsonlite)
library(tidyjson)


art <- read_json('hackathon/data/articles.json')


articles <- fromJSON(readLines('hackathon/data/articles.json'),
                     simplifyVector = TRUE)


articles_df <- as.data.frame(lapply(articles[c("title","url","score","descendants","id")], as.character))

content <- read_csv("content/1.csv")


content_joined <- content %>% 
  left_join(articles_df, by = 'url')

data('stop_words')

words <- content$text %>%
  str_replace_all('[^A-Z|a-z]', ' ') %>% 
  str_replace_all('\\s\\s*', ' ') %>% 
  str_to_upper() %>% 
  str_split(' ') %>%
  as.character()
  
df <- data.frame(word = words, stringsAsFactors = FALSE) %>% 
  filter(str_length(word) > 0 & !str_to_lower(word) %in% stop_words$word) %>% 
  count(word)

df <- df %>% 
  mutate(color=factor(sample(10, nrow(df), replace=TRUE)))

ggplot(df, aes(label = word, size = n, color = color)) + 
  geom_text_wordcloud() + 
  scale_size_area(max_size = 15)

