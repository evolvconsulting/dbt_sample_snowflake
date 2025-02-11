{{
  config(
    materialized='view',
    tags=['source_load'],
  )
}}

select 
x.PS_AVAILQTY
,x.PS_COMMENT
,x.PS_PARTKEY
,x.PS_SUPPKEY
,x.PS_SUPPLYCOST
,hash(
  x.PS_AVAILQTY
  ,x.PS_COMMENT
  ,x.PS_PARTKEY
  ,x.PS_SUPPKEY
  ,x.PS_SUPPLYCOST
) as row_hash
from {{ source("SNOWFLAKE_SAMPLE_DATA", "PARTSUPP") }} x