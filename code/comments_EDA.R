library(rjson)
library(tidytext)
library(tidyverse)

fillColor = "#FFA07A"

PATH_COMMENTS_1 = "input/comments_recent.json"

get_text <- function(x)
{
  if (length(x) == 0)
  {
    blank = ""
    return (blank)
  }

  else
  {
    return (x$text)
  }
}


create_dataframe_comments <- function(comments_file)
{

  comments <- fromJSON(file = comments_file)

  comments_text <- sapply(comments,function(x) get_text(x))
  comments_df = data.frame(Text=comments_text)
  comments_df$Text = as.character(comments_df$Text)

  return(comments_df)


}




comments_text = create_dataframe_comments(PATH_COMMENTS_1)

createBarPlotCommonWords = function(train,title)
{
  train %>%
    filter(length(Text) > 0) %>%
    unnest_tokens(word, Text) %>%
    filter(!word %in% stop_words$word) %>%
    count(word,sort = TRUE) %>%
    ungroup() %>%
    mutate(word = factor(word, levels = rev(unique(word)))) %>%
    head(10) %>%

    ggplot(aes(x = word,y = n)) +
    geom_bar(stat='identity',colour="white", fill =fillColor) +
    geom_text(aes(x = word, y = 1, label = paste0("(",n,")",sep="")),
              hjust=0, vjust=.5, size = 4, colour = 'black',
              fontface = 'bold') +
    labs(x = 'Word', y = 'Word Count',
         title = title) +
    coord_flip() +
    theme_bw(base_size = 15)


}

createBarPlotCommonWords(comments_text,'Top 10 most Common Words')

