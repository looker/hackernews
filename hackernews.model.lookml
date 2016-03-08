- connection: lookerdata_publicdata

- include: "*.view.lookml"

- persist_for: 10000 hours

- explore: stories
  joins:
  - join: daily_rank
    view_label: Stories
    sql_on: ${stories.id} = ${daily_rank.id}
    relationship: one_to_one

- explore: story_words
  joins:
  - join: stories
    sql_on: ${story_words.id}=${stories.id}
    relationship: many_to_one
    type: left_outer_each
    
  - join: daily_rank
    view_label: Stories
    sql_on: ${story_words.id} = ${daily_rank.id}
    relationship: one_to_one
    type: left_outer_each