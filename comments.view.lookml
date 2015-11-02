- view: comments
  sql_table_name: |
     [fh-bigquery:hackernews.comments]

  fields:
  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id
    html: |
      {{ linked_value }} <a href="https://news.ycombinator.com/item?id={{value}}" target=new>➚</a>

  - measure: count
    type: count
    drill_fields: detail*