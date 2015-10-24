Hackernews data has recently been release on BigQuery's data engine.  BigQuery is a giant clustered SQL engine that can query enormous amounts of data very quickly.

We're going to explore this data using Looker.

Navigating to bigquery, we see there are two table, stories and comments.  Both tables are relatively simple

## Table Stories

Each story contains and id, score, who wrote it when it was written, the score the story achieved (I believe this is 'points' on http://news.ycombinator.com.  Each story also as a title and the URL containing the content.  Stories have decendants, not sure what that means yet, but we'll find out.

<img src="https://discourse.looker.com/uploads/default/original/2X/7/77a46d2cc6933d063c8e7a5bfd8d1c08d7513237.png" width="423" height="485">

## Table Comments

Stories on hackernews have comments.  Each comment has an author, a timestamp of the comment, the parrent comment and a ranking.

<img src="https://discourse.looker.com/uploads/default/original/2X/0/0f8f4d6b366872131249bc5ae9effe65ac0431f3.png" width="397" height="433">

## Getting Started

Let's first start with Stories.  First we run Looker's generator to create a LookML model for stories.  Each field in the table with have an associated LookML declaration.

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

If we set the score and the count the number of posts with each score, we should get an idea about how likely a story is to get a given score.  Looking at the table and graph below we can see that many stories are scored like mine, 1,2,3,4.   

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

Sometimes, just picking a threshold will help you figure out stuff.  In this case, I'm going to pick 7 as a threshold for an interesting story.  Later, we can investigate different thresholds, but for now, I'm going ot say if a story has a score of 7 or more, it's interesting.   

Let's build a new dimension.  In LookML.  We can reuse the score definition in the main model to create score_7_plus.

```
  - dimension: score_7_plus
    type: yesno
    sql: ${score} >= 7
```

Then run a query using the new dimension, and we can see that about 15% (300K/1959K) of the stories have a score of 7 or above.

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

By the way, Looker, using the LookML model, behind the scenes is writing all the SQL for us and sending it to BigQuery.

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

Getting a front page story is no easy feat.  Let's see if we can figure out of someone out there does it consistently.  We're going to use our lucky 7 as our threshold.  To examine this, we going to hold our grouping by **Score 7 Plus** and additionly group by Author.  Looker lets us pivot the results.  We're also going to sort by the Yes Count column.

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

It looks like an author **cwan** has had the most posts that have made it to the front page.  To see what **cwan** posts about, we just click on his story count.  Let's look at it by score.

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

We can go back to our original "top poster" and find do some research about who posts the most about say 'Facebook'.   I've added row totals, so we can know the total number of posts, both 7 and above and not.

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


Humans are great at recognizing what works.  Let's look at ssclafani's Facebook posts and see if we can figure out what's going on.  Clicking into the 65, we can see his posts.

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

Apparently authors succeed on HackerNews at different rates.  Let's create a measure the percentage of posts that are 7 or above.  In LookML we simply create a new count of stories that scored 7 or more (reusing the last declaration we made), and a new measure that computes the percentage.

```
  - measure: count_score_7_plus
    type: count
    drill_fields: detail*
    filters:
      score_7_plus: Yes
      
  - measure: percent_7_plus
    type: number
    sql: 100.0 * ${count_score_7_plus} / ${count}
    decimals: 2
```

We can then rerun our query using these new measures.  We can easily see **Slimy** is quite good at placing stories scoring 65.22%.

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

We can sort by **Percent 7 Plus** and look at people that have posted more than 5 stories (again, an arbitrary number). 

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
    html: |
      {{ linked_value }} <a href="http://{{value}}" target=new>➚</a>
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
    stories.count_score_7_plus: '>5'
  sorts: [stories.count_score_7_plus desc]
  limit: 500
  column_limit: 50
</look>

And a peek at the sql:

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

Domains are probably more intresting then hosts, so let's build up another field that parses domain out of the host.

```
  - dimension: url_domain
    sql: REGEXP_EXTRACT(${url_host},'([^\\.]+\\.[^\\.]+)$')
    html: |
      {{ linked_value }} <a href="http://{{value}}" target=new>➚</a>
```

<look height="300">
  type: table
  model: hackernews
  explore: stories
  dimensions: [stories.url_domain]
  measures: [stories.count, stories.count_score_7_plus, stories.percent_7_plus]
  filters:
    stories.title: '%Facebook%'
    stories.count_score_7_plus: '>5'
  sorts: [stories.count_score_7_plus desc]
  limit: 500
  column_limit: 50
</look>


Are there hosts that are more successful than others? Lets look at Hosts by **Percent 7 Plus**.

<img src="/uploads/default/original/2X/1/19704db60e2097482a5709726d279fb905b66f16.png" width="580" height="278">

Whoops, looks like a bunch of one-hit-wonders.  Let's eliminate hosts that have had less than 20 successful posts.

<img src="/uploads/default/original/2X/b/ba3f1bf8afbaef4bed06b2639813a31cd56daa91.png" width="478" height="500">

## Who is posting?

Looker knows how to build lists.  We add another LookML field to build a list of authors.

```
 - measure: author_list
    type: list
    list_field: author  
```
And now we can add that to our query.

<img src="/uploads/default/original/2X/6/63470abc48e90f6c865f83fe247ed383eb88dcdd.png" width="690" height="412">

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

<img src="/uploads/default/original/2X/d/d6645cb769566156fbca5fc51098f233e4861dff.png" width="585" height="430">

And the SQL for this query:
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
We build them in a very similar we built our Score 7 measures.  Notice we simply reference ${daily_rank.rank} and Looker figures out how to write the SQL to make it all fit together.

```
  - dimension: rank_25_or_less
    type: yesno
    sql: ${daily_rank.rank} <= 25

  - measure: count_rank_25_or_less
    type: count
    drill_fields: detail*
    filters:
      rank_25_or_less: Yes
      
  - measure: percent_rank_25_or_less
    type: number
    sql: 100.0 * ${count_rank_25_or_less} / ${count}
    decimals: 2
```

And the simple output.  Looks like about 4% of posts make it to the top 25 on a given day.

<img src="/uploads/default/original/2X/5/59b7925e58e2fa6c4e90bf3d348e9ecbdf0cf1e3.png" width="581" height="46">

Now let's look at it by poster.  Looks like Paul Graham has had lots of top 25 posts and a very high hit rate.  

<img src="/uploads/default/original/2X/c/c82e30fcbbd88ce15d3749835d381bc7b40436f1.png" width="588" height="403">

And by host, we start to see some new entrants.  Jeff Attwood's blog coding horror is now ranked 15 for all time.

<img src="/uploads/default/original/2X/3/38e9d0514a505b265abe39c441eb6dfc9cac31f4.png" width="560" height="500">

## Common Words in Top Posts

We can embellish so we can explore the top words in posts.  First, we're going to build a derived table that with have two columns, the story id, and a word that appeared in the title.

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

Now we can explore by word.  Let's look at the Words in the posts with a rank of 25 or less.  We'll scroll down a little to look past some of the small common words

<img src="/uploads/default/original/2X/a/a036f49544b484a6884349088a712650a768cd2b.png" width="594" height="367">

and the SQL

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

<img src="/uploads/default/original/2X/a/ac320aebfe6dce2c800ccaab361fd46009411e5c.png" width="588" height="496">


## Comparing
Now with a few clicks we can start comparing.  By filtering words to Microsoft, Google and Facebook
Let's compare  front page Posts by Year.
<img src="/uploads/default/original/2X/8/891a39483106f66527fc98c922cc30ba7b52161c.png" width="509" height="500">

Or computer Languages.

<img src="/uploads/default/original/2X/2/28c858309e2e4ce74a2ffa630a598b12b53eaea6.png" width="439" height="500">