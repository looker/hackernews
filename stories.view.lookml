- view: stories
  sql_table_name: |
     [fh-bigquery:hackernews.stories]

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

  - dimension: score_7_plus
    type: yesno
    sql: ${score} >= 7

  - measure: count_score_7_plus
    type: count
    drill_fields: detail*
    filters:
      score_7_plus: Yes
      
  - measure: percent_7_plus
    type: number
    sql: 100.0 * ${count_score_7_plus} / ${count}
    decimals: 2

  - dimension: rank_25_or_less
    type: yesno
    sql: ${daily_rank.daily_rank} <= 25

  - measure: count_rank_25_or_less
    type: count
    drill_fields: detail*
    filters:
      rank_25_or_less: Yes
      
  - measure: percent_rank_25_or_less
    type: number
    sql: 100.0 * ${count_rank_25_or_less} / ${count}
    decimals: 2

  - dimension: score
    type: int
    sql: ${TABLE}.score
    
  - measure: average_score
    type: average
    sql: ${score}

  - dimension: time
    type: int
    sql: ${TABLE}.[time]

  - dimension_group: post
    type: time
    timeframes: [hour, hour_of_day, time, date, week, day_of_week, month, year]
    sql: ${TABLE}.time_ts

  - dimension: title
    type: string
    sql: ${TABLE}.title

  - dimension: title_word
    sql: SPLIT(${title})

  - dimension: url
    type: string
    sql: ${TABLE}.url
    
  - measure: count_url
    type: count_distinct
    sql: ${url}
    drill_fields: [url, count]
    
  - dimension: url_host
    sql: REGEXP_EXTRACT(${url},'http://([^/]+)/')
    html: |
      {{ linked_value }} <a href="http://{{value}}" target=new>➚</a>

  - measure: count_url_host
    type: count_distinct
    sql: ${url_host}
    drill_fields: [url_host, count]

  - dimension: url_domain
    sql: REGEXP_EXTRACT(${url_host},'([^\\.]+\\.[^\\.]+(?:\\.[a-zA-Z].)?)$')
    html: |
      {{ linked_value }} <a href="http://{{value}}" target=new>➚</a>

  - measure: count_url_domain
    type: count_distinct
    sql: ${url_domain}
    drill_fields: [url_domain, count]

  - dimension: text
    type: string
    sql: ${TABLE}.text

  - dimension_group: deleted
    type: yesno
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
    html: |
      {{ linked_value }} <a href="https://news.ycombinator.com/user?id={{value}}" target=new>➚</a>
    
  - measure: author_list
    type: list
    list_field: author    
    
  sets:
    detail: [id, post_time, author, title, score]
    
    
    