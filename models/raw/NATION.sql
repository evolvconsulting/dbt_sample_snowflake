{{
  config(
    materialized='view',
    tags=['source_load'],
  )
}}

select 
x.N_COMMENT
,x.N_NAME
,x.N_NATIONKEY
,x.N_REGIONKEY
,hash(
  x.N_COMMENT
  ,x.N_NAME
  ,x.N_NATIONKEY
  ,x.N_REGIONKEY
) as row_hash
from {{ source("SNOWFLAKE_SAMPLE_DATA", "NATION") }} x