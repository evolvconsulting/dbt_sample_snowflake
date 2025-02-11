{{
  config(
    materialized='view',
    tags=['source_load'],
  )
}}

select 
x.P_BRAND
,x.P_COMMENT
,x.P_CONTAINER
,x.P_MFGR
,x.P_NAME
,x.P_PARTKEY
,x.P_RETAILPRICE
,x.P_SIZE
,x.P_TYPE
,hash(
  x.P_BRAND
  ,x.P_COMMENT
  ,x.P_CONTAINER
  ,x.P_MFGR
  ,x.P_NAME
  ,x.P_PARTKEY
  ,x.P_RETAILPRICE
  ,x.P_SIZE
  ,x.P_TYPE
) as row_hash
from {{ source("SNOWFLAKE_SAMPLE_DATA", "PART") }} x