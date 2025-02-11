{{
  config(
    materialized='incremental',
    tags=['source_load'],
    transient=true
  )
}}

select 
x.L_COMMENT
,x.L_COMMITDATE
,x.L_DISCOUNT
,x.L_EXTENDEDPRICE
,x.L_LINENUMBER
,x.L_LINESTATUS
,x.L_ORDERKEY
,x.L_PARTKEY
,x.L_QUANTITY
,x.L_RECEIPTDATE
,x.L_RETURNFLAG
,x.L_SHIPDATE
,x.L_SHIPINSTRUCT
,x.L_SHIPMODE
,x.L_SUPPKEY
,x.L_TAX
,hash(
  x.L_COMMENT
  ,x.L_COMMITDATE
  ,x.L_DISCOUNT
  ,x.L_EXTENDEDPRICE
  ,x.L_LINENUMBER
  ,x.L_LINESTATUS
  ,x.L_ORDERKEY
  ,x.L_PARTKEY
  ,x.L_QUANTITY
  ,x.L_RECEIPTDATE
  ,x.L_RETURNFLAG
  ,x.L_SHIPDATE
  ,x.L_SHIPINSTRUCT
  ,x.L_SHIPMODE
  ,x.L_SUPPKEY
  ,x.L_TAX
) as row_hash
,current_user() as created_by_user_name
,current_timestamp() as created_by_timestamp
,current_user() as updated_by_user_name
,current_timestamp() as updated_by_timestamp
from {{ source("SNOWFLAKE_SAMPLE_DATA", "LINEITEM") }} x
{% if is_incremental() %}
  -- this filter will only be applied on an incremental run
  where not exists (
      select 1 
      from {{ this }} l
      where x.L_ORDERKEY = l.L_ORDERKEY
      and x.L_LINENUMBER = l.L_LINENUMBER
      )

{% endif %}

limit {{ var("incremental_count") }}