{{
  config(
    materialized='table'
  )
}}

SELECT 
    id AS superhero_id,
    name,
    gender,
    eye_color,
    race,
    hair_color,
    nullif(height, -99) as height,
    publisher,
    skin_color,
    alignment,
    nullif(weight, -99) as weight_lbs,
    {{ lbs_to_kgs('weight') }} as weight_kgs
FROM {{ source('tutorial', 'superheroes') }}