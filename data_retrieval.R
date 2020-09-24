library(hackeRnews)
future::plan(future::multiprocess) # setup multiprocess futures, read more at https://github.com/HenrikBengtsson/future
library(dplyr)
library(ggplot2)
library(stringr)
library(tidytext)
library(urltools)
library(topicmodels)
library(rvest)
library(tm)


# Read in data and make a df.
#####
# Get all stories. These will be grouped by topic.
# 500 stories - approx 30 second runtime.
#stories <- get_new_stories(max_items = NULL)

# Save the stories object so you don't have to
# scrape every time this runs.
#saveRDS(stories, file = "stories.RDS")

# Read the stories RDS object. Last retrieved 202009240843JST
stories <- readRDS("stories.RDS")

# Get ids
ids <- lapply(stories, function(id) id$id) %>%
  unlist()

# Get comments
# 15 min runtime
#comments <- lapply(ids, get_item_by_id)
#comments <- lapply(comments, get_comments)
#saveRDS(comments, file = "comments.RDS")

# A bunch of tibbles.
comments <- readRDS("comments.RDS")

# I want them flat. This flattens all comments into one string.
# For loop - sorry! D:
flat_comments <- c()
for(i in 1:length(comments)){
  temp <- unlist(comments[[i]]['text'])
  flat_comments[i] <- paste(temp, collapse = ' ')
}

# Clean the comments and caps them.
flat_comments <-lapply(flat_comments, function(comment) comment) %>% 
  str_replace_all('[^A-Z|a-z]', ' ') %>% 
  str_replace_all('\\s\\s*', ' ') %>% 
  str_to_upper()

# I think that the topics for the stories are stored:
# 1) The title of the story (written by the user)
# 2) The URL. I assume that stories w/ the same base
#    URL will have similar content (i.e. wired.com, etc)
# 3) The raw comments text.

# Building mydf, which has id, title, and url

# Extract, clean and all caps titles.
titles <- lapply(stories, function(story) story$title) %>% 
  str_replace_all('[^A-Z|a-z]', ' ') %>% 
  str_replace_all('\\s\\s*', ' ') %>% 
  str_to_upper()

# Get IDs
ids <- lapply(stories, function(id) id$id) %>%
  unlist()

# Get host URLS

# Some stories are just text and thus don't have
# a url to extract. Make sure these are annotated
# as such. Use an ifelse statement to either get
# the url or write "text_post" in the vector.
# This is important because it preserves indexing.
urls <- lapply(stories, function(url)
  ifelse("url" %in% names(url),
         url$url,
         "text_post")) %>%
  unlist()

# Save the full urls to use later on.
full_urls <- urls

# Returns NA for text posts, and deal with medium.com
# posts. For some reason the suffix_extract() function
# doesn't return a domain from medium.com posts,
# but it does return "host" with the author's username.

# medium.com links don't cooperate...get those
# indices and just write medium.com
medium.com_indices <- which(
  grepl("medium.com", urls) == TRUE
)

urls[medium.com_indices] <- "www.medium.com"

# Extract the urls for non-text posts

# Get indices for posts that are actual urls.
non_text_indices <- which(urls != "text_post")
urls[non_text_indices] <- suffix_extract(
  domain(
    urls[non_text_indices]
  )
)$domain

mydf <- data.frame(id = ids,
                   host = urls,
                   full_url = full_urls,
                   title = titles,
                   comment = flat_comments,
                   stringsAsFactors = FALSE)

# It is pretty unrealistic to scrape such a variety of
# websites, so I am not going to bother trying to target
# and scrape the content from each of these. I think that
# the bulk of the information that can be used to get a latent
# "topic" is located in the title, and perhaps some of the comments.
#####

# Tidy the data and prepare for LDA
#####

# This is a dataframe with two columns:
# the story id and the title and comments pasted
# together.
tidy_hn <- mydf["id"]
tidy_hn$words <- apply(mydf[ , c(4,5) ],
                       1 ,
                       paste ,
                       collapse = " " )

# Make it a tidy tibble
tidy_hn <- tibble(tidy_hn)
tidy_hn <- tidy_hn %>%
  unnest_tokens(word, words)

# This drops a doc. Maybe it was
# all stopwords?
data(stop_words)
tidy_hn <- tidy_hn %>%
  anti_join(stop_words)

# Put it intto a DTM for LDA
dtm_hn <- tidy_hn %>%
  count(id, word) %>%
  cast_dtm(id, word, n)

# I like to use k = sqrt(documents)*2 rounded up
# In this case (500 docs) it is 45
k = ceiling(sqrt(dtm_hn$nrow)*2)
# 10 min runtime
#hn_lda <- LDA(dtm_hn, k = k, control = list(seed = 24601))
#saveRDS(hn_lda, "hn_lda.RDS")
hn_lda <- readRDS("hn_lda.RDS")

# Explore
hn_topics <- tidy(hn_lda, matrix = "beta")

hn_top_terms <- hn_topics %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

hn_top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()

#####
#ok