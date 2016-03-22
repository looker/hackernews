- view: story_words
  derived_table:
    sql: |
     SELECT a.id as id, a.word as word, b.ssword as ssword
     FROM FLATTEN((
       SELECT id, REGEXP_EXTRACT(LOWER(SPLIT(title," ")),"([a-z]+)") as word
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
    label: 'is_common_word'
    type: yesno
    sql: ${TABLE}.ssword IS NOT NULL
