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
