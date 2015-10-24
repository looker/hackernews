- view: story_words
  derived_table:
    sql: |
      SELECT id, SPLIT(title," ") as word 
      FROM [fh-bigquery:hackernews.stories] stories
  fields:
  - dimension: id
    primary_key: true
    hidden: true
  - dimension: word
