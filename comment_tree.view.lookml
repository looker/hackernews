- view: comment_tree
  derived_table:
    sql: |
      SELECT  descendent.type AS type,
      descendent.parent AS Level1,
      descendent.id AS Level2,
      descendent3.id AS Level3,
      descendent4.id AS Level4,
      descendent5.id AS Level5,
      descendent6.id AS Level6,
      descendent7.id AS Level7,
      descendent8.id AS Level8,
      descendent9.id AS Level9,
      descendent10.id AS Level10,
      descendent11.id AS Level11,
      descendent12.id AS Level12,
      descendent13.id AS Level13,
      descendent14.id AS Level14,
      descendent15.id AS Level15,
      descendent16.id AS Level16,
      descendent17.id AS Level17,
      descendent18.id AS Level18,
      descendent19.id AS Level19,
      descendent20.id AS Level20
      FROM [fh-bigquery:hackernews.full_201510] descendent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent3 ON descendent.id = descendent3.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent4 ON descendent3.id =descendent4.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent5 ON descendent4.id =descendent5.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent6 ON descendent5.id =descendent6.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent7 ON descendent6.id =descendent7.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent8 ON descendent7.id =descendent8.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent9 ON descendent8.id =descendent9.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent10 ON descendent9.id = descendent10.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent11 ON descendent10.id =descendent11.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent12 ON descendent11.id =descendent12.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent13 ON descendent12.id =descendent13.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent14 ON descendent13.id =descendent14.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent15 ON descendent14.id =descendent15.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent16 ON descendent15.id =descendent16.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent17 ON descendent16.id =descendent17.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent18 ON descendent17.id =descendent18.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent19 ON descendent18.id =descendent19.parent
      LEFT JOIN EACH [fh-bigquery:hackernews.full_201510] descendent20 ON descendent19.id =descendent20.parent
      WHERE descendent.type != 'comment_ranking' 
      AND descendent.parent = 1
      AND descendent.dead IS NULL
      AND descendent3.dead IS NULL
      AND descendent4.dead IS NULL
      AND descendent5.dead IS NULL
      AND descendent6.dead IS NULL
      AND descendent7.dead IS NULL
      AND descendent8.dead IS NULL
      AND descendent9.dead IS NULL
      AND descendent10.dead IS NULL
      AND descendent11.dead IS NULL
      AND descendent12.dead IS NULL
      AND descendent13.dead IS NULL
      AND descendent14.dead IS NULL
      AND descendent15.dead IS NULL
      AND descendent16.dead IS NULL
      AND descendent17.dead IS NULL
      AND descendent18.dead IS NULL
      AND descendent19.dead IS NULL
      AND descendent20.dead IS NULL
      
  
  fields:
#   - dimension: id
#     primary_key: true
#     hidden: true
#     
#   - dimension: parent
#     sql: ${TABLE}.parent
  - dimension: type
    sql: ${TABLE}.type

  - dimension: level1
    type: int
    sql: ${TABLE}.Level1
#     hidden: true
  - dimension: level2
    type: int
    sql: ${TABLE}.Level2
#     hidden: true
  - dimension: level3
    type: int
    sql: ${TABLE}.Level3
#     hidden: true
  - dimension: level4
    type: int
    sql: ${TABLE}.Level4
#     hidden: true
  - dimension: level5
    type: int
    sql: ${TABLE}.Level5
#     hidden: true
  - dimension: level6
    type: int
    sql: ${TABLE}.Level6
#     hidden: true
  - dimension: level7
    type: int
    sql: ${TABLE}.Level7
#     hidden: true
  - dimension: level8
    type: int
    sql: ${TABLE}.Level8
#     hidden: true
  - dimension: level9
    type: int
    sql: ${TABLE}.Level9
#     hidden: true
  - dimension: level10
    type: int
    sql: ${TABLE}.Level10
#     hidden: true
  
  - dimension: last_comment
    type: int
    sql: COALESCE(${level10},${level9},${level8},${level7},${level6},${level5},${level4},${level3},${level2},${level1})