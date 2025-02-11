{{
  config(
    materialized='incremental',
    tags=['source_load'],
    transient=true
  )
}}

select 
x.O_CLERK
,x.O_COMMENT
,x.O_CUSTKEY
,x.O_ORDERDATE
,x.O_ORDERKEY
,x.O_ORDERPRIORITY
,x.O_ORDERSTATUS
,x.O_SHIPPRIORITY
,x.O_TOTALPRICE
,hash(
  x.O_CLERK
  ,x.O_COMMENT
  ,x.O_CUSTKEY
  ,x.O_ORDERDATE
  ,x.O_ORDERKEY
  ,x.O_ORDERPRIORITY
  ,x.O_ORDERSTATUS
  ,x.O_SHIPPRIORITY
  ,x.O_TOTALPRICE
) as row_hash
,current_user() as created_by_user_name
,current_timestamp() as created_by_timestamp
,current_user() as updated_by_user_name
,current_timestamp() as updated_by_timestamp
from {{ source("SNOWFLAKE_SAMPLE_DATA", "ORDERS") }} x
{% if is_incremental() %}
  -- this filter will only be applied on an incremental run
  where not exists (
      select 1 
      from {{ this }} o
      where x.O_ORDERKEY = o.O_ORDERKEY
      )

{% endif %}

limit {{ var("incremental_count") }}