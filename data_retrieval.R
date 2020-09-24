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
stories <- readRDS("data/stories.RDS")

# Get ids
ids <- lapply(stories, function(id) id$id) %>%
  unlist()

# Get scores
scores <- lapply(stories, function(score) score$score) %>% unlist()

# Get comments
# 15 min runtime
#comments <- lapply(ids, get_item_by_id)
#comments <- lapply(comments, get_comments)
#saveRDS(comments, file = "comments.RDS")

# A bunch of tibbles.
comments <- readRDS("data/comments.RDS")

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

# How many comments are there?
num_comments <- lapply(comments, length) %>% unlist

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
                   num_comments = num_comments,
                   score = scores,
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
my_stopwords <- c("www","https","quot","gt","nofollow",
                  "href","rel","org")
stop_words <- stop_words %>%
  add_row(word = my_stopwords, lexicon = "Custom", .before = 1)
tidy_hn <- tidy_hn %>%
  anti_join(stop_words)

df <- tibble(x = 1:3, y = 3:1)

df %>% add_row(x = 4, y = 0)

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
hn_lda <- readRDS("data/hn_lda.RDS")
#####

# Explore Key Topics
#####
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

# I identified these 8 topics:
### Technology (Topics 5, 10, 15, 16, 17, 18, 21, 22, 23, 25, 26, 27, 29, 32, 33, 34, 35, 40, 41, 43, 44, 45)
### Politics (Topics 1, 2, 3, 9, 11, 20, 25, 28, 31, 36, 37)
### Energy / Environment (Topics 7, 38, 39, 42)
### Science (Topics 4, 8, 13, 14)
### Cars (Topics 24, 38, 39)
### Internet Community (Topics 6, 12)
### Legal (Topics 30, 33)
### Literature (Topic 19)

# Let's run the LDA again to see if they appear more naturally.
#hn_lda2 <- LDA(dtm_hn, k = 8, control = list(seed = 24601))
#saveRDS(hn_lda2, "data/hn_lda2.RDS")
readRDS("data/hn_lda2.RDS")

hn_topics2 <- tidy(hn_lda2, matrix = "beta")

hn_top_terms2 <- hn_topics2 %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

hn_top_terms2 %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()

# If we break that down we can sort things into just four topics.
### Technology (Topics 2, 5, 7)
### Politics (Topics 1, 3)
### Energy (Topics 4, 8)
### Legal (Topic 6)

# Let's see what happens with k = 4
# Let's run the LDA again to see if they appear more naturally.
#hn_lda3 <- LDA(dtm_hn, k = 4, control = list(seed = 24601))
#saveRDS(hn_lda3, "data/hn_lda3.RDS")
readRDS("data/hn_lda3.RDS")

hn_topics3 <- tidy(hn_lda3, matrix = "beta")

hn_top_terms3 <- hn_topics3 %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

hn_top_terms3 %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()

#This leaves us with:
### Topic 1: Politics
### Topic 2: Technology
### Topic 3: Other
### Topic 4: Environment

# If you check these the k = 4 topics don't make
# sense for some of the documents in them. It is
# too specific and is forcing documents into groups
# where they don't necessarily belong
#Let's stick to the  k = 8 topic model.
#hn_documents <- tidy(hn_lda2, matrix = "gamma")
#hn_documents %>%
#  arrange(desc(gamma))

#hn_documents <- tidy(hn_lda3, matrix = "gamma")
#hn_documents %>%
#  arrange(desc(gamma))

#tidy(dtm_hn) %>%
#  filter(document == 24568719) %>%
#  arrange(desc(count))

# Assign a topic to each document and coerce the
# topics into tehcnology, politics, energy, and legal.
hn_documents <- tidy(hn_lda2, matrix = "gamma")
hn_documents %>%
  arrange(desc(gamma))

# Get the max gamma topic for each document.
hn_documents <- hn_documents %>%
  group_by(document) %>%
  top_n(1, gamma)

# I want a regular dataframe.
hn_documents.df <- data.frame(hn_documents)

hn_documents.df$topic[hn_documents.df$topic == 1] <- "Politics"
hn_documents.df$topic[hn_documents.df$topic == 2] <- "Technology"
hn_documents.df$topic[hn_documents.df$topic == 3] <- "Politics"
hn_documents.df$topic[hn_documents.df$topic == 4] <- "Energy"
hn_documents.df$topic[hn_documents.df$topic == 5] <- "Technology"
hn_documents.df$topic[hn_documents.df$topic == 6] <- "Legal"
hn_documents.df$topic[hn_documents.df$topic == 7] <- "Technology"
hn_documents.df$topic[hn_documents.df$topic == 8] <- "Energy"

# There is a missing document number that was lost when
# we did the anti_join. I am not sure why it was lost
# but it needs to be accounted for.
which(mydf$id %in% hn_documents.df$document == FALSE) # 469
hn_documents.df <- rbind(hn_documents.df, c(mydf$id[469], NA, NA))

# Merge the data. Now you have a topic in mydf.
names(hn_documents.df) <- c("id", "topic", "gamma")
mydf <- merge(mydf, hn_documents.df, by = "id")

# Get the popularity





#####

# Popular Topics in Terms of Points & Comments




