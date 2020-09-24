### [Text Mining Hackathon](https://2020.whyr.pl/hackaton/) 
Meanguys challenge4

# Table of contents

- [What are the key topics described in the article?](#key-topics)
- [Which topics are the most popular in terms of points and comments?](#topic-popularity)
- [Can you divide articles in groups with meaningful characteristics and the story?](#divide-articles-by-characteristics)
- [Can you map topics with groups of users?](#map-topics-by-user-groups)
- [Which topics were popular during which time periods/intervals?](#topic-time-intervals)
- [What are the most polarizing topics in terms of the sentiment?](#polarizing-topics)

# Key Topics

Key topics were discovered using Latent Dirichlet Allocation(LDA). The hackeRnews API was used to pull the 500 latest posts from https://news.ycombinator.com/. Topic modeling was performed *only* on the title of the post and it's comments - no data was scraped from web pages that were linked in the posts. This decision was made due to the time constraints imposed by the hackathon.

When using an LDA model the user must specify the number of topics, which is written as "k." My preferred formula for determining k is:

```{R}
k <- ceiling(sqrt(number_of_documents)*2)
```
Which (in English) is the square root of the number of documents, times two, rounded up. In this case k = 45. The top terms for the 45 topics selected are shown below:

<img src="https://github.com/kartikeyakirar/meanguys/tree/challenge4/img/top_words_per_topics45.png"
alt="Top Terms by Topic" />

These 45 LDA topics lend themselves to eight key topics, as selected by the authors:

### Technology (Topics 5, 10, 15, 16, 17, 18, 21, 22, 23, 25, 26, 27, 29, 32, 33, 34, 35, 40, 41, 43, 44, 45)
### Politics (Topics 1, 2, 3, 9, 11, 20, 25, 28, 31, 36, 37)
### Energy / Environment (Topics 7, 38, 39, 42)
### Science (Topics 4, 8, 13, 14)
### Cars (Topics 24, 38, 39)
### Internet Community (Topics 6, 12)
### Legal (Topics 30, 33)
### Literature (Topic 19)

Because the LDA with k = 45 revealed 8 topics, let's look at top terms with k = 8:

<img src="https://github.com/kartikeyakirar/meanguys/tree/challenge4/img/top_words_per_topics8.png"
alt="Top Terms by Topic" />

If we break that down we can sort things into just four topics.
### Technology (Topics 2, 5, 7)
### Politics (Topics 1, 3)
### Energy (Topics 4, 8)
### Legal (Topic 6)

Again, let's reduce k and let k = 4.

<img src="https://github.com/kartikeyakirar/meanguys/tree/challenge4/img/top_words_per_topics4.png"
alt="Top Terms by Topic" />

We could group this into politics, tech, environment, and other, but I think that this is forcing documents into groups where they don't belong. We will continue with the k = 8 model, but we will coerce the numbered topics into semantic topics that we have chosen (tehcnology, politics, energy, and legal).

# Topic Popularity

By far the most popular topic is "Technology" with "Energy" and "Politics" neck and neck for the second most popular. However, politics has more comments relative to its score, this implies that there is lots of discussion perhaps from dissenting users who are commenting but not "upvoting."

<img src="https://github.com/kartikeyakirar/meanguys/tree/challenge4/img/num_comments_topic.png"
alt="Top Terms by Topic" />

<img src="https://github.com/kartikeyakirar/meanguys/tree/challenge4/img/score_topic.png"
alt="Top Terms by Topic" />

# Divide Articles by Characteristics

