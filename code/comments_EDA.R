library(rjson)
library(tidytext)

fillColor = "#FFA07A"

PATH_COMMENTS_1 = "input/comments1.json"


create_dataframe_comments <- function(comments_file)
{

  comments <- fromJSON(file = comments_file)

  n <- length(comments)

  df = data.frame(Text=comments[[1]]$text)

  for(i in 2:n)
  {
    df2 = data.frame(Text=comments[[i]]$text)

    df <- rbind(df,df2)
  }

  return(df)


}


comments_text = create_dataframe_comments(PATH_COMMENTS_1)
comments_text$Text = as.character(comments_text$Text)

createBarPlotCommonWords = function(train,title)
{
  train %>%
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
