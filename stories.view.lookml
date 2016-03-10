- view: stories
  sql_table_name: |
     [fh-bigquery:hackernews.stories]

  fields:
  - dimension: id
    primary_key: true
    type: number
    sql: ${TABLE}.id
    html: |
      {{ linked_value }} <a href="https://news.ycombinator.com/item?id={{value}}" target=new>➚</a>

  - measure: count
    type: count
    drill_fields: detail*
  
  - measure: cumulative_story_count
    type: running_total
    sql: ${count} 
    
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
    value_format: '0.00\%'

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
    value_format: '0.00\%'

  - dimension: score
    type: number
    sql: ${TABLE}.score
    
  - measure: average_score
    type: average
    sql: ${score}

  - dimension: time
    type: number
    sql: ${TABLE}.[time]

  - dimension_group: post
    type: time
    timeframes: [hour, hour_of_day, time, date, week, day_of_week, month, year]
    sql: ${TABLE}.time_ts

  - dimension: title
    type: string
    sql: ${TABLE}.title
    case_sensitive: false

  - dimension: title_word
    sql: SPLIT(${title})

  - dimension: url
    type: string
    sql: ${TABLE}.url
    links:
    - label: Goto {{ value }}
      url: "{{ value }}"
      
    
  - measure: count_url
    type: count_distinct
    sql: ${url}
    drill_fields: [url, count]
    
  - dimension: url_host
    sql: REGEXP_EXTRACT(${url},'http://([^/]+)/')
    links:
    - label: Goto {{ value }}
      url: "{{ value }}"
      
  - measure: count_url_host
    type: count_distinct
    sql: ${url_host}
    drill_fields: [url_host, count]

  - dimension: url_domain
    sql: REGEXP_EXTRACT(${url_host},'([^\\.]+\\.[^\\.]+(?:\\.[a-zA-Z].)?)$')
    links:
    - label: Goto {{ value }}
      url: "{{ value }}"
  
  - dimension: domain_logo
    sql: ${url_domain}
    html: |
      <img src="http://logo.clearbit.com/{{ value }}" height=32 width=32> {{ value }}

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
    type: number
    sql: ${TABLE}.descendants

  - dimension: author
    type: string
    sql: ${TABLE}.author
    links:
    - label: Goto news.ycombinator.com
      url: https://news.ycombinator.com/user?id={{value}}
      icon_url: https://news.ycombinator.com/favicon.ico
      
  - measure: author_list
    type: list
    list_field: author
  
  - measure: count_authors
    type: count_distinct
    sql: ${author}
    drill_fields: [author, count, percent_7_plus]
    
  sets:
    detail: [id, post_time, author, title, score]