{{
  config(
    materialized='view',
    tags=['source_load'],
  )
}}

select 
x.S_ACCTBAL
,x.S_ADDRESS
,x.S_COMMENT
,x.S_NAME
,x.S_NATIONKEY
,x.S_PHONE
,x.S_SUPPKEY
,hash(
  x.S_ACCTBAL
  ,x.S_ADDRESS
  ,x.S_COMMENT
  ,x.S_NAME
  ,x.S_NATIONKEY
  ,x.S_PHONE
  ,x.S_SUPPKEY
) as row_hash
from {{ source("SNOWFLAKE_SAMPLE_DATA", "SUPPLIER") }} x