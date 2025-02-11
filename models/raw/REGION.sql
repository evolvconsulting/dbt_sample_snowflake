{{
  config(
    materialized='view',
    tags=['source_load'],
  )
}}

select 
x.R_COMMENT
,x.R_NAME
,x.R_REGIONKEY
,hash(
  x.R_COMMENT
  ,x.R_NAME
  ,x.R_REGIONKEY
) as row_hash
from {{ source("SNOWFLAKE_SAMPLE_DATA", "REGION") }} x