# Hacking HackerNews

Hackernews data has recently been release on Google's BigQuery data engine.  BigQuery is a giant clustered SQL engine that can query enormous amounts of data very quickly.  

## Quick Links if you just want to play

This article talks about building out a data model in LookML to be able to explore this data.  If you are in a rush, you can:

* **[Play with the HackerNews Data Dashboard](/dashboards/169)**
* **[See the code on Github](https://github.com/looker/hackernews)**
* **[Explore the data Directly](/explore/hackernews/stories)**


## Start with the raw data

Navigating to the [HackerNews data in BigQuery](https://bigquery.cloud.google.com/table/fh-bigquery:hackernews.stories), we see there are two table, stories and comments.  Both tables are relatively simple in structure.

## Table Stories

Each story contains a story id, the author that made the post, when it was written, the score the story achieved (I believe this is 'points' on http://news.ycombinator.com.  Each story also as a title and the URL containing the content.  

<img src="https://discourse.looker.com/uploads/default/original/2X/7/77a46d2cc6933d063c8e7a5bfd8d1c08d7513237.png" width="423" height="485">

## Table Comments

Stories on hackernews have comments.  Each comment has an author, a timestamp of the comment, the parrent comment and a ranking.

<img src="https://discourse.looker.com/uploads/default/original/2X/0/0f8f4d6b366872131249bc5ae9effe65ac0431f3.png" width="397" height="433">

## Getting Started

Let's first start with Stories.  First we run Looker's generator to create a LookML model for stories.  Each field in the table will have an associated LookML dimension.  These dimensions are used both in Looker's Explorer and to write SQL statements and run them in BigQuery.  

Without any changing any of this code, we can explore the data immediately.


```
- explore: stories

- view: stories
  sql_table_name: |
     [fh-bigquery:hackernews.stories]

  fields:
  - measure: count
    type: count
    drill_fields: detail*

  - dimension: id
    type: int
    sql: ${TABLE}.id

  - dimension: by
    type: string
    sql: ${TABLE}.[by]

  - dimension: score
    type: int
    sql: ${TABLE}.score
    
  - dimension: time
    type: int
    sql: ${TABLE}.[time]

  - dimension_group: post
    type: time
    timeframes: [time, date, week, month, year]
    sql: ${TABLE}.time_ts

  - dimension: title
    type: string
    sql: ${TABLE}.title

  - dimension: url
    type: string
    sql: ${TABLE}.url

  - dimension: text
    type: string
    sql: ${TABLE}.text

  - dimension_group: deleted
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.deleted

  - dimension: dead
    type: yesno
    sql: ${TABLE}.dead

  - dimension: descendants
    type: int
    sql: ${TABLE}.descendants

  - dimension: author
    type: string
    sql: ${TABLE}.author
    
  sets:
    detail: [id, post_time, author, title]
```

## Let's Start Exploring

The first and most obvious question is how many stories are there?

<look>
  model: hackernews
  explore: stories
  measures: stories.count
</look>

Is the number of stories going up or down?  Let's look by year.

<look>
  model: hackernews
  explore: stories
  dimensions: [stories.post_year]
  measures: [stories.count]
  filters:
    stories.score: '0 to'
  sorts: [stories.post_year]
</look>


<look>
  model: hackernews
  explore: stories
  type: looker_column
  dimensions: [stories.post_year]
  measures: [stories.count]
  filters:
    stories.score: '0 to'
  sorts: [stories.post_year]
  x_axis_scale: ordinal
</look>

Looks like stories peaked in 2013.

## How do I get my Story to the top of Hacker News?

I've tried a couple of times, to post, but my stories never seem to go anywhere.  Let's find my stories.  I'm going to filter by 'lloydt' my hackernews name and let's take a look.  
<look>
  model: hackernews
  explore: stories
  dimensions: [stories.post_year]
  measures: [stories.count]
  filters:
    stories.score: '0 to'
    stories.author: lloydt
  sorts: [stories.post_year]
</look>

<look>
  model: hackernews
  explore: stories
  type: looker_column
  dimensions: [stories.post_year]
  measures: [stories.count]
  filters:
    stories.score: '0 to'
    stories.author: lloydt
  sorts: [stories.post_year]
  x_axis_scale: ordinal
</look>

Clicking on any of the counts will lead to my stories.  Clicking on the 4 in 2013 shows my stories.

<look>
  type: table
  model: hackernews
  explore: stories
  dimensions: [stories.id, stories.post_time, stories.author, stories.title, stories.score]
  filters:
    stories.author: '"lloydt"'
    stories.post_year: '2013'
    stories.score: 0 to
  sorts: [stories.post_time desc]
  limit: 500
</look>

My best story scored a 4.  Looking on the front page of Hacker news at the moment, we see posts with a variety of scores, but the lowest looks to be *7*.

<img src="https://discourse.looker.com/uploads/default/original/2X/d/da7894868c9970b4d5f9a9360e5498e0e932b457.png" width="465" height="500">

## How are the Scores Distributed?

If use the score as a dimension (group by score, ins SQL) and the count the number of posts with each score, we should get an idea about how likely a story is to get a given score.  Looking at the table and graph below we can see that many stories are scored like mine, 1,2,3,4.   

<look height="300">
  type: table
  model: hackernews
  explore: stories
  dimensions: [stories.score]
  measures: [stories.count]
  filters:
    stories.score: NOT NULL
  sorts: [stories.score]
  limit: 500
</look>

<look>
  type: looker_line
  model: hackernews
  explore: stories
  dimensions: [stories.score]
  measures: [stories.count]
  filters:
    stories.score: NOT NULL
  sorts: [stories.score]
  limit: 500
  stacking: ''
  show_value_labels: false
  label_density: 25
  legend_position: center
  x_axis_gridlines: false
  y_axis_gridlines: true
  show_view_names: true
  y_axis_combined: true
  show_y_axis_labels: true
  show_y_axis_ticks: true
  y_axis_tick_density: default
  y_axis_tick_density_custom: 5
  show_x_axis_label: true
  show_x_axis_ticks: true
  x_axis_scale: auto
  show_null_points: true
  point_style: none
  interpolation: linear
</look>

## Lucky 7

The goal here is to try and figure out if a story made it to the front page of HackerNews.  Many stories each day are posted and most don't get there.  It is pretty obvious that the distrubution is heavily bifurcated, there are some stories that make it,  but most stories don't.  

Unfortunately, there is no obvious way, in the data to see the split.

Sometimes, just picking a somewhat arbitrary threshold will help us find it.  In this case, I'm going to pick 7 as a threshold for an interesting story.  Later, we can investigate different thresholds, but for now, I'm going ot say if a story has a score of 7 or more, it's interesting.   

Let's build a new dimension.  In LookML.  Note We can reuse the score definition (${score}) in the main model to create score_7_plus.

```
  - dimension: score_7_plus
    type: yesno
    sql: ${score} >= 7
```

Using the new *score_7_plus* dimension, we run a query and we can see that about 15% (300K/1959K) of the stories have a score of 7 or above.

<look>
  type: table
  model: hackernews
  explore: stories
  dimensions: [stories.score_7_plus]
  measures: [stories.count]
  sorts: [stories.score, stories.count desc]
  limit: 500
  total: true
</look>

Looker, using the LookML model, behind the scenes is writing all the SQL for us and sending it to BigQuery.  The query it sent on our behave was:

```
SELECT 
  CASE WHEN stories.score >= 7 THEN 'Yes' ELSE 'No' END AS stories_score_7_plus,
  COUNT(*) AS stories_count
FROM [fh-bigquery:hackernews.stories]
 AS stories
GROUP EACH BY 1
ORDER BY 2 DESC
LIMIT 500
```

## Who is the King of HackerNews?

Getting a front page story is no easy feat.  Let's see if we can figure out of someone out there does it consistently.  We're going to use our lucky 7 as our threshold.  To examine this, we going to hold our grouping by **Score 7 Plus** and additionly group by Author.  Looker lets us pivot the results.  We're also going to sort by the Yes Count column to find the perosn with the most posts with a score of 7 or more.

<look height="300">
  type: table
  model: hackernews
  explore: stories
  dimensions: [stories.score_7_plus, stories.author]
  pivots: [stories.score_7_plus]
  measures: [stories.count]
  sorts: [stories.score, stories.count desc 1, stories.score_7_plus]
  limit: 500
  column_limit: 50
</look>

It looks like an author **cwan** has had the most posts that have made it to the front page.  To see what **cwan** posts about, we just click on his story count. All looker counts drill into the detail behind them.  Let's look at **cwan**'s posts.  

<look height="300">
  type: table
  model: hackernews
  explore: stories
  dimensions: [stories.id, stories.post_time, stories.author, stories.title, stories.score]
  filters:
    stories.author: cwan
  sorts: [stories.score desc]
  limit: 500
</look>

##  Finding Top Posters about a Particular Subject.

Filtering data, to a smaller set can help us find trends about a particular subject.

We can go back to our original "top poster" query and find do some research about who posts contain the word 'Facebook'.   We'll see a different set of people.

Notice that the top poster **ssclanfani** has had 122 posts with 'Facebook' in the title and 65 of them have a score 7 or higher (about 50%).

**iProject** has had 323 posts about facebook and only 29 have scored 7 or higher (about 10%).  

<look height="300">
  type: table
  model: hackernews
  explore: stories
  dimensions: [stories.author, stories.score_7_plus]
  pivots: [stories.score_7_plus]
  measures: [stories.count]
  filters:
    stories.title: '%Facebook%'
  sorts: [stories.count desc 1, stories.score_7_plus]
  limit: 500
  column_limit: 50
</look>

Often, the devil is in the details.  Many times, I've clicked into a number and looked at the underlying data records and seen some pattern.  Let's look at ssclafani's Facebook posts and see if we can find something interesting.  Clicking into the 65, we can see his posts.

<look height="300">
  type: table
  model: hackernews
  explore: stories
  dimensions: [stories.id, stories.post_time, stories.author, stories.title, stories.score]
  filters:
    stories.author: '"ssclafani"'
    stories.score_7_plus: 'Yes'
    stories.title: '%Facebook%'
  sorts: [stories.post_time desc]
  limit: 500
</look>

## Generalizing Hit Rate.

Pivoting the data is helpful, but we're still doing some calculations by hand.  We can create a couple of custom measures that will help us understand the data more readily. 

We'll create a count of just the posts that scored 7 and above.

Then we'll create a measure that is the percentage of all posts that scored 7 and above.

LookML makes created these measures pretty easily.  
 
Notice that we reuse the definition of *score_7_plus*

```
  - measure: count_score_7_plus
    type: count
    drill_fields: detail*
    filters:
      score_7_plus: Yes
```

And we reuse the definition of *count_score_7_plus* in the following definition.

```
  - measure: percent_7_plus
    type: number
    sql: 100.0 * ${count_score_7_plus} / ${count}
    decimals: 2
```

With the new measures, we can rebuild and run our previous query. The percentage measure really helps us see that the author **Slimy** is quite good at placing stories where 65.22% score 7 or higher.

<look height="300">
  type: table
  model: hackernews
  explore: stories
  dimensions: [stories.author]
  measures: [stories.count, stories.count_score_7_plus, stories.percent_7_plus]
  filters:
    stories.title: '%Facebook%'
  sorts: [stories.count_score_7_plus desc]
  limit: 500
  column_limit: 50
</look>

### Are there people better the author: 'Slimy'?

Another advantage of creating a new measure is we can now sort by it.  Let's Sort by **Percent 7 Plus** and look at people that have posted more than 5 stories (again, an arbitrary number). 

<look height="300">
  type: table
  model: hackernews
  explore: stories
  dimensions: [stories.author]
  measures: [stories.count, stories.count_score_7_plus, stories.percent_7_plus]
  filters:
    stories.title: '%Facebook%'
    stories.count_score_7_plus: 6 to
  sorts: [stories.percent_7_plus desc]
  limit: 500
  column_limit: 50
</look>

## Where do the Stories Live?

Hacker New only contains titles and urls that point places (and comments).  Let's take a look where the stories that are posted live.  In order to do this, we'll have to parse out the host from the URL.  We'll build a dimension in LookML that does this.  BigQuery's SQL has a regular expression extractor that makes it pretty easy.  LookML also has a way that we can write the html for the thing we are displaying.

We add the dimension to our model:

```
  - dimension: url_host
    sql: REGEXP_EXTRACT(${url},'http://([^/]+)/')
```

And now we can look at stories by host they were posted to.  Let's sort by Score 7 Plus.

<look height="300">
  type: table
  model: hackernews
  explore: stories
  dimensions: [stories.url_host]
  measures: [stories.count, stories.count_score_7_plus, stories.percent_7_plus]
  filters:
    stories.title: '%Facebook%'
    stories.count_score_7_plus: 6 to
  sorts: [stories.count_score_7_plus desc]
  limit: 500
  column_limit: 50
</look>

And a peek at the sql that Looker wrote for us:

```
SELECT 
  REGEXP_EXTRACT(stories.url,'http://([^/]+)/') AS stories_url_host,
  COUNT(*) AS stories_count,
  COUNT(CASE WHEN stories.score >= 7 THEN 1 ELSE NULL END) AS stories_count_score_7_plus,
  100.0 * (COUNT(CASE WHEN stories.score >= 7 THEN 1 ELSE NULL END)) / (COUNT(*)) AS stories_percent_7_plus
FROM [fh-bigquery:hackernews.stories]
 AS stories
GROUP EACH BY 1
ORDER BY 3 DESC
LIMIT 500
```

### Domains are better.

Domains are probably more intresting then hosts after all www.techcrunch.com and techcrunch.com both appear in this list.  So let's build up another field that parses domain out of the host.  We have to be careful to deal with hosts like 'bbc.co.uk', so we look for domains that end in two letters and grab more data. 

```
  - dimension: url_domain
    sql: REGEXP_EXTRACT(${url_host},'([^\\.]+\\.[^\\.]+(?:\\.[a-zA-Z].)?)$')
```

<look height="300">
  type: table
  model: hackernews
  explore: stories
  dimensions: [stories.url_domain]
  measures: [stories.count, stories.count_score_7_plus, stories.percent_7_plus]
  filters:
    stories.count_score_7_plus: 6 to
  sorts: [stories.count_score_7_plus desc]
  limit: 500
  column_limit: 50
</look>


Are there domains that are more successful than others? Lets look at Hosts by **Percent 7 Plus**.

<look height="300">
  type: table
  model: hackernews
  explore: stories
  dimensions: [stories.url_domain]
  measures: [stories.count, stories.count_score_7_plus, stories.percent_7_plus]
  sorts: [stories.percent_7_plus desc]
  limit: 500
  column_limit: 50
</look>

Whoops, looks like a bunch of one-hit-wonders.  Let's eliminate hosts that have had less than 20 successful posts.

<look height="300">
  type: table
  model: hackernews
  explore: stories
  dimensions: [stories.url_domain]
  measures: [stories.count, stories.count_score_7_plus, stories.percent_7_plus]
  filters:
    stories.count_score_7_plus: 20 to
  sorts: [stories.percent_7_plus desc]
  limit: 500
  column_limit: 50
</look>


## Building a Better Indication that a Post was on the Front Page.

There is an old joke about a group of people that encounter a bear in the woods.  They all start running from the bear.  The joke is that you don't have to outrun the bear, you have to outrun the other people.

Hacker news scores are like that.  We probably don't care what the actual score is, we just care that its better then the other scores being posted on the same day.

We'll rank the the score for each day starting with 1 as the best score for the day and moving down.

In order to compute the daily rank, we'll need to use SQL's window function and a derived table in LookML.  The output is a two column table with the id of the story and the rank of the story on the day it was posted.

```
- view: daily_rank
  derived_table:
     sql: |
        SELECT
           id
          , RANK() OVER (PARTITION BY post_date ORDER BY score DESC) as daily_rank
        FROM (
           SELECT 
            id
            , DATE(time_ts) as post_date
            , score
           FROM [fh-bigquery:hackernews.stories]
           WHERE score > 0
        )
  fields:
  - dimension: id
    primary_key: true
    hidden: true
  - dimension: daily_rank
    type: number
```

We can join this table into our explorer.

```
- explore: stories
  joins:
  - join: daily_rank
    sql_on: ${stories.id} = ${daily_rank.id}
    relationship: one_to_one
```

We can then look at our data by daily_rank and see the number of stories that match this.  The data looks right.  There are some 3000 days and a story for each rank for each day.

<look height="300">
  type: table
  model: hackernews
  explore: stories
  dimensions: [daily_rank.daily_rank]
  measures: [stories.count]
  sorts: [daily_rank.daily_rank]
  limit: 500
  column_limit: 50
</look>
  

The SQL that Looker wrote for this query is below.  As the model gets more and more complex, so do the queries, but asking the question remains simple.

```
SELECT 
  daily_rank.daily_rank AS daily_rank_daily_rank,
  COUNT(*) AS stories_count
FROM [fh-bigquery:hackernews.stories]
 AS stories
LEFT JOIN (SELECT
   id
  , RANK() OVER (PARTITION BY post_date ORDER BY score DESC) as daily_rank
FROM (
   SELECT 
    id
    , DATE(time_ts) as post_date
    , score
   FROM [fh-bigquery:hackernews.stories]
   WHERE score > 0
)
) AS daily_rank ON stories.id = daily_rank.id
GROUP EACH BY 1
ORDER BY 1 
LIMIT 500
```

## Let's build a new Top 25 set of dimensions and measures

Like we did before, having dimension and measures built into the model will allow us to think in these terms.

We build them in a very similar we built our Score 7 measures.  Notice we simply reference ${daily_rank.rank} and Looker figures out how to write the SQL to make it all fit together.

```
  # Was this post in the top 25 on a given day?
  - dimension: rank_25_or_less
    type: yesno
    sql: ${daily_rank.rank} <= 25

  # How many posts were in the top 25 out of this group of posts?
  - measure: count_rank_25_or_less
    type: count
    drill_fields: detail*
    filters:
      rank_25_or_less: Yes
      
  # What Percentage of posts were in the top 25 in group set of posts?
  - measure: percent_rank_25_or_less
    type: number
    sql: 100.0 * ${count_rank_25_or_less} / ${count}
    decimals: 2
```

And the simple output.  Looks like about 4% of posts make it to the top 25 on a given day.

<look height="300">
  
  type: table
  model: hackernews
  explore: stories
  measures: [stories.count, stories.count_rank_25_or_less, stories.percent_rank_25_or_less]
  sorts: [stories.count desc]
  limit: 500
  column_limit: 50
</look>

Now let's look at it by poster.  Looks like Paul Graham has had lots of top 25 posts and a very high hit rate.  

<look height="300">
  type: table
  model: hackernews
  explore: stories
  dimensions: [stories.author]
  measures: [stories.count, stories.count_rank_25_or_less, stories.percent_rank_25_or_less]
  sorts: [stories.count_rank_25_or_less desc]
  limit: 500
  column_limit: 50
</look>

## Wow.  Looking by Domain is an Amazing List

Rerunning the query, this time by target domain with high story counts with rank 25 or less gives us a fascinating list of domains.  The obvious ones are there, nytimes, bbc.co.uk, but scrolling down a little, I find domains I don't know about.  Following the links (we'll talk about how to make these later) usualy takes me to an interesting place.

<look height="300">
  type: table
  model: hackernews
  explore: stories
  dimensions: [stories.url_domain]
  measures: [stories.count, stories.count_rank_25_or_less, stories.percent_rank_25_or_less]
  sorts: [stories.count_rank_25_or_less desc]
  limit: 500
  column_limit: 50
</look>

## Comparing our VCs

Two of Looker's VC Parters like to write (and I love to read what they write).  Firstround capital has the fabulous Firstround Review and Tom Tunguz writes really great blog posts.  Comparing them, it looks like the HackerNew audience appreciates FirstRound more then Tom.  I, of course, appreciate them both :).  Digging through the data, I see Tom change the name of his blog a few years ago.  Tom's performance is quite respectable, but  Firstround's performance is off the charts.  

<look>
  model: hackernews
  explore: stories
  dimensions: [stories.url_domain]
  measures: [stories.count_rank_25_or_less, stories.percent_rank_25_or_less, stories.count_score_7_plus,
    stories.percent_7_plus, stories.count, stories.count_url]
  filters:
    stories.url_domain: '%firstround.com%,%tunguz.com%'
  sorts: [stories.url_domain]
  limit: 500
  column_limit: 50
</look>


## Common Words in Top Posts

We can now find top posts.  Let's figure out if we can figure out why some posts are top. Are top posts talking about something in particular?  Let's see if we can figure out common words in posts.

First, we're going to build a derived table that with have two columns, the story id, and a word that appeared in the title.

```
 view: story_words
  derived_table:
    sql: |
      SELECT id, SPLIT(title," ") as word 
      FROM [fh-bigquery:hackernews.stories] stories
  fields:
  - dimension: id
    primary_key: true
    hidden: true
  - dimension: word
```

Next we'll build an explore definition (the join relationships).  We'll reuse both our prior views (the story view and the daily_rank view).  The basis of this explore is a word, not a story.

```
- explore: story_words
  joins:
  - join: stories
    sql_on: ${story_words.id}=${stories.id}
    relationship: many_to_one
    type: left_outer_each
  - join: daily_rank
    sql_on: ${stories.id} = ${daily_rank.id}
    relationship: one_to_one
    type: left_outer_each
```

Now we can explore by word.  Let's look at the Words in the posts with a rank of 25 or less.  Scroll down a little to look past some of the small common words

<look height="300">
  type: table
  model: hackernews
  explore: story_words
  dimensions: [story_words.word]
  measures: [stories.count]
  sorts: [stories.count desc]
  limit: 500
</look>

and again, the SQL Looker is writing for us...

```
SELECT 
  story_words.word AS story_words_word,
  COUNT(DISTINCT CASE WHEN daily_rank.daily_rank <= 25 THEN stories.id ELSE NULL END, 1000) AS stories_count_rank_25_or_less
FROM (SELECT id, SPLIT(title," ") as word 
FROM [fh-bigquery:hackernews.stories] stories
) AS story_words
LEFT JOIN EACH [fh-bigquery:hackernews.stories]
 AS stories ON story_words.id=stories.id
LEFT JOIN EACH (SELECT
   id
  , RANK() OVER (PARTITION BY post_date ORDER BY score DESC) as daily_rank
FROM (
   SELECT 
    id
    , DATE(time_ts) as post_date
    , score
   FROM [fh-bigquery:hackernews.stories]
   WHERE score > 0
)
) AS daily_rank ON stories.id = daily_rank.id
GROUP EACH BY 1
ORDER BY 2 DESC
LIMIT 500
```

Of course clicking on any of the numbers will drill in and show us any of the stories.

## Eliminating the common words with a Shakespere

The common words are a problem.  It would be great to eliminate or at least flag them.

To do this, we're going to use an inspired little hack.

BigQuery provides a nice little table of all the words in Shakespere.  The table consists of the word, the corpus it appeard in and what year the corpus was written.  

We are going to find these 1000 words and then flag the words that we encounter that appear in the 1000 word list.

First, we write a little query to find the 1000 most common words in shakespere.  

```
SELECT 
    lower(word) as ssword
    , count(distinct corpus) as c 
  FROM [publicdata:samples.shakespeare] 
  GROUP BY 1 
  ORDER BY 2 
  DESC 
  LIMIT 1000
```

With this word list, we can modify our derived table that finds words in posts to have a new column ssword, which if NOT NULL, appears in shakespere (and we would consider common).

```
- view: story_words
  derived_table:
    sql: |
     SELECT a.id as id, a.word as word, b.ssword as ssword
     FROM FLATTEN((
       SELECT id, LOWER(SPLIT(title," ")) as word
          FROM [fh-bigquery:hackernews.stories] stories
       ), word) as a
     LEFT JOIN (
        SELECT lower(word) as ssword
        , count(distinct corpus) as c 
        FROM [publicdata:samples.shakespeare] 
        GROUP BY 1 
        ORDER BY 2 
        DESC 
        LIMIT 1000) as b
      ON a.word = b.ssword  
  fields:
  - dimension: id
    primary_key: true
    hidden: true
  - dimension: word
  - dimension: is_comon_word
    type: yesno
    sql: ${TABLE}.ssword IS NOT NULL
```

Now rerunning our query, with the common field, we can see what we've isolated some of the more common words.

<look height="300">
  type: table
  model: hackernews
  explore: story_words
  dimensions: [story_words.word, story_words.is_comon_word]
  measures: [stories.count]
  sorts: [stories.count desc]
  limit: 500
</look>

And now without the common words

<look height="300">
  type: table
  model: hackernews
  explore: story_words
  dimensions: [story_words.word, story_words.is_comon_word]
  measures: [stories.count]
  filters:
    story_words.is_comon_word: 'No'
  sorts: [stories.count desc]
  limit: 500
</look>

## Finally, which words, if in the Title of the Story are most likely to get you on the Front Page

<look height="300">
  type: table
  model: hackernews
  explore: story_words
  dimensions: [story_words.word]
  measures: [stories.count, stories.percent_rank_25_or_less, stories.percent_7_plus]
  filters:
    story_words.is_comon_word: 'No'
    stories.count: '100 to'
  sorts: [stories.percent_rank_25_or_less desc]
  limit: 500
</look>

## Comparing

Now with a few clicks we can start comparing.  By filtering words to Microsoft, Google and Facebook
Let's compare  front page Posts by Year.


<look height="300">
  model: hackernews
  explore: story_words
  dimensions: [stories.post_year, story_words.word]
  pivots: [story_words.word]
  measures: [ stories.count_rank_25_or_less]
  filters:
    story_words.word: '"microsoft","google","facebook"'
  sorts: [stories.post_year, story_words.word]
  limit: 500
  column_limit: 50
</look>

<look>
  type: looker_column
  model: hackernews
  explore: story_words
  dimensions: [stories.post_year, story_words.word]
  pivots: [story_words.word]
  measures: [stories.count_rank_25_or_less]
  filters:
    story_words.word: '"microsoft","google","facebook"'
  sorts: [stories.post_year, story_words.word]
  limit: 500
  column_limit: 50
  stacking: ''
  show_value_labels: false
  label_density: 25
  legend_position: center
  x_axis_gridlines: false
  y_axis_gridlines: true
  show_view_names: true
  y_axis_combined: true
  show_y_axis_labels: true
  show_y_axis_ticks: true
  y_axis_tick_density: default
  y_axis_tick_density_custom: 5
  show_x_axis_label: true
  show_x_axis_ticks: true
  x_axis_scale: auto
  ordering: none
  show_null_labels: false
</look>

Or computer Languages.

<look height="300">
  model: hackernews
  explore: story_words
  dimensions: [stories.post_year, story_words.word]
  pivots: [story_words.word]
  measures: [ stories.count_rank_25_or_less]
  filters:
    story_words.word: javascript,python,ruby
  sorts: [stories.post_year, story_words.word]
  limit: 500
  column_limit: 50
</look>

<look>
  type: looker_column
  model: hackernews
  explore: story_words
  dimensions: [stories.post_year, story_words.word]
  pivots: [story_words.word]
  measures: [stories.count_rank_25_or_less]
  filters:
    story_words.word: javascript,python,ruby
  sorts: [stories.post_year, story_words.word]
  limit: 500
  column_limit: 50
  stacking: ''
  show_value_labels: false
  label_density: 25
  legend_position: center
  x_axis_gridlines: false
  y_axis_gridlines: true
  show_view_names: true
  y_axis_combined: true
  show_y_axis_labels: true
  show_y_axis_ticks: true
  y_axis_tick_density: default
  y_axis_tick_density_custom: 5
  show_x_axis_label: true
  show_x_axis_ticks: true
  x_axis_scale: auto
  ordering: none
  show_null_labels: false
</look>

## Wiring this into an Application

The next step is to make a data discovery application and cross wire all the research we've done so far.  We easily build a dashboard that show posts, *over time*, *by domain*, *by author*, *by word*, and success rates into making to a score of 7 and from a score of 7 into the top 25.

We wire up filters for author, domain and word, so that any of these will change all the data on the dashboard.

For example Paul Grahm (author: pg), Is posting a little less over time, likes to post about ycombinator. talks about yc, applicathions, hn and startups.  His posts look very successful.

<img src="https://discourse.looker.com/uploads/default/original/2X/b/b75d6f53fff47ab8465fa12b22859be3466ce393.png" width="469" height="499">

One of the nice things we can do in Looker is to create links when we render cels.  Dimensions have a **html:** that is rendered with [liquid templating](http://liquidmarkup.org/).

Using this mechanism, we can cross link everywhere we display, author, domain and word to point to a dashboard.

For example, we link author to both the dashboard and the profile page on hacker news.  We use emoji's to make it all work.  

```
  - dimension: author
    type: string
    sql: ${TABLE}.author
    html: |
      {{ linked_value }} 
       <a href="/dashboards/169?author={{value}}" 
        title="Goto Dashboard"
        target=new>⚡</a>
      <a href="https://news.ycombinator.com/user?id={{value}}" 
        title="Goto news.ycombinator.com"
        target=new>➚</a>
```


## Other Ideas to Research

There is lots more to investigate.

* What's really in a score?  Is it related to the number of comments?
* If it is, are there any cliffs in comments that might be a better indicator of "frontpageness"?
* If there are multiple people that post the same URL with almost the exact same text, does timing matter?
* What time of day is the best time to post?  Does it matter?
* Does velocity of comments matter in score?  How soon after the post do comments need to happen before a score goes up?
* Do some commenters matter more then others (for example, if you get a comment from someone that comments a lot, does that help your score more?)
