{{
  config(
    materialized='table',
    tags=['source_load'],
    transient=true
  )
}}

select 
x.C_ACCTBAL
,x.C_ADDRESS
,x.C_COMMENT
,x.C_CUSTKEY
,x.C_MKTSEGMENT
,x.C_NAME
,x.C_NATIONKEY
,x.C_PHONE
,hash(
  x.C_ACCTBAL
  ,x.C_ADDRESS
  ,x.C_COMMENT
  ,x.C_CUSTKEY
  ,x.C_MKTSEGMENT
  ,x.C_NAME
  ,x.C_NATIONKEY
  ,x.C_PHONE
) as row_hash
,current_user() as created_by_user_name
,current_timestamp() as created_by_timestamp
,current_user() as updated_by_user_name
,current_timestamp() as updated_by_timestamp
from {{ source("SNOWFLAKE_SAMPLE_DATA", "CUSTOMER") }} x
