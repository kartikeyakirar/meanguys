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

![Image of k8](https://github.com/kartikeyakirar/meanguys/tree/challenge4/img/top_words_per_topics8.png)

If we break that down we can sort things into just four topics.
### Technology (Topics 2, 5, 7)
### Politics (Topics 1, 3)
### Energy (Topics 4, 8)
### Legal (Topic 6)

Again, let's reduce k and let k = 4.

<img src="https://github.com/kartikeyakirar/meanguys/tree/challenge4/img/top_words_per_topics4.png"
alt="Top Terms by Topic" />

This leaves us with:
### Topic 1: Politics
### Topic 2: Technology
### Topic 3: Other
### Topic 4: Environment

# Topic Popularity



## Solutions

At this hackathon you can scale the level of difficulty and the area of challenges on your own. Depending on skills and the time that you have you can tune the fun on your own!

Please send your solutions for every challenge as a separate (max 5 min) video. Each video presenting the solution should be published online and you should fill [this form](https://forms.gle/D8eskXZka9HGQVC88) with a team’s name and the url to the video (form closes at 2020-09-24 5:30 pm UTC). When making a video that presents a solution keep in mind below criterias. For the challenge 1 please submit a short video presenting how you come up with predictions and please send predictions to kontakt_at_whyr.pl no later than 2020-09-24 5:30 pm UTC. You can also add a url to the presentation or the dashboard that you made to present your insights.

**You already should realize that the deadline for solutions is 2020-09-24 5:30 pm UTC.**

Check out the last chapter about [going one level higher](#going-one-level-higher)

# Criteria

- Whether there are at least 3 people in the team?
- Is the presentation based on HackeR News data?
- Is the solution a result of the teamwork?
- Is the solution hosted in a public place?
- Is this solution useful for the imaginary business team at Hacker News or has potential/clear business applications/story?
- Is there a clear business problem/story that you are explaining?
- How attractive is the use case?
- How well are you able to present your solution?
- Is the solution explainable?
- Does the used solution have any statistical validation?


Presented solution should be submitted as a video. It is nice to have if a solution is based on a presentation or a dashboard. For challenges 2-4 the winning solution will be chosen based on insightfulness and usefulness of identified patterns. For challenge 1 the winning solution will be chosen based on a cost function however we would like to know how did you get into such predictions?

# Descriptions of challenges

## Challenge 1 - “Warm up predictions”

Based on historical data of **stories** appearing on Hacker News in 2020 predict

- The number of new articles to appear between 2020-09-25 00:00 UTC - 2020-09-26 00:00 UTC
- The total number of new comments under stories published between 2020-09-25 00:00 UTC - 2020-09-26 00:00 UTC
- The highest number of points obtained by a single article (recorded at 2020-09-26 00:00 UTC) for articles published after 2020-09-25 00:00 UTC

Try to minimize the final cost function: 

```{R}
abs((predicted_n_articles-actual_n_articles)/actual_n_articles) +
abs((predicted_n_comments-actual_n_comments)/actual_n_comments) +
abs((predicted_highest_number_of_points-actual_highest_number_of_points)/actual_highest_number_of_points)
```
## Challenge 2 - “Segmentation”

Based on historical data of some **comments** create meaningful segments of users. Can you propose any statistical measures of goodness of fit to describe the quality of the segmentation solution?

Below we present some inspirations for potential characteristics that may eventually differentiate segments:

- What is the sentiment of comments made by each group?
- What are the common words-association within each group based on comments?
- What are the keywords of titles of articles under which comments are made?
- What amount of comments is done by which segment?
- What are the characteristics of each group? 
- What articles do they comment about and what do they write about? 
- What is the high-level summary of groups? 

Please keep in mind a segmentation solution should have balanced segments sizes and meaningful stories behind the groups of users.

## Challenge 3 - “Churn”

Based on historical data of some **comments** execute a churn analysis so that business can understand what patterns and activities drive users to churn.

The below set of questions might inspire you to craft the story:

- When should we consider a user to have churned?
- What is the typical length of history/live of a user?
- Do users tend to be active only during specific periods of time or are most users active all over the history of the portal?
- What factors make some users “live” longer or shorter?

## Challenge 4 - “Revealing the content”

Ok, let’s tackle articles : ) Based on the below data of **content** find out what are the key topics described in articles?

When building an analysis that helps to understand the corpus of text, you can consider below questions

- What are the key topics described in articles? 
- Which topics are the most popular in terms of points and comments? 
- Can you divide articles in groups with meaningful characteristics and the story? 
- Can you map topics with groups of users?
- Which topics were popular during which time periods/intervals? 
- What are the most polarizing topics in terms of the sentiment?

## Going one level higher

Each challenge can be submitted in one of 2 forms: regular (with data provided by organizers) or extended (with data gathered by the team thanks to the API). You can extend each task by using the data for questions, job offers or show-offs. If API can't deliver enough data, maybe you can webscrap data from the portal? If you decide to go with an extended path you will be compared only to the teams that took the extended part for this particular challenge.

# Datasets

> To make the event more challenging and to make the competition more realistic, in terms of business realities, the **comments** and **content** articles will get updated/extended from a time to time. The **articles** dataset will not be updated.


### Articles

```{R}
library(jsonlite)
articles <- fromJSON(readLines('data/articles.json'))
```
<img src="https://raw.githubusercontent.com/MarcinKosinski/hackathon/master/img/articles.png"
     alt="articles" />

### Comments

```{R}
library(jsonlite)
comments_recent <- fromJSON(readLines('data/comments_recent.json'))
```

<img src="https://raw.githubusercontent.com/MarcinKosinski/hackathon/master/img/comments.png"
     alt="articles" />
     
### Content

Available under this [Dropbox url](https://www.dropbox.com/s/qhuvcfm1bs5wtwt/content.csv?dl=0)
     
```{R}
library(readr)
content <- read_csv('data/content.csv')
```

<img src="https://raw.githubusercontent.com/MarcinKosinski/hackathon/master/img/content.png"
     alt="articles" />