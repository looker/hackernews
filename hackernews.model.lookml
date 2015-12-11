- connection: thelook_bigquery

# this is a comment

- include: "*.view.lookml"

- explore: stories
  joins:
  - join: daily_rank
    view_label: Stories
    sql_on: ${stories.id} = ${daily_rank.id}
    relationship: one_to_one
  - join: comment_tree
    sql_on: ${stories.id} = ${comment_tree.level1}

  
- explore: comments

- explore: comment_tree

- explore: author_response

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