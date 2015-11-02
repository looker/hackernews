- view: author_response
  derived_table:
    sql: |
      SELECT comment1.id as post_id,
        comment1.by as post_author,
        comment1.time as post_time,
        comment2.id as response_id,
        comment2.parent as response_parent,
        comment2.by as response_author
      FROM [fh-bigquery:hackernews.full_201510] comment1
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] comment2
      ON comment1.id = comment2.parent
      
  fields:
  - dimension: post_id
    sql: ${TABLE}.post_id
    
  - dimension: post_author
    sql: ${TABLE}.post_author
  
  - dimension_group: post_time
    type: time
    datatype: epoch
    timeframes: [date, month, week, year]
    sql: ${TABLE}.post_time

  - dimension: response_id
    sql: ${TABLE}.response_id

  - dimension: response_author
    sql: ${TABLE}.response_author

  - dimension: response_parent
    sql: ${TABLE}.response_parent
  
  - measure: count
    type: count
    
  
  