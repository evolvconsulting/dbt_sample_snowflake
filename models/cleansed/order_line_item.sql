{{
  config(
    materialized='incremental',
    tags=['data_cleansing'],
    unique_key=['order_key','line_number'],
    on_schema_change='append_new_columns',
    transient=false
  )
}}

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- get the prior created by and create timestamp to retain through a potential record merge if updated.
    with prior_vals as (
        select
        l.L_ORDERKEY
        ,l.L_LINENUMBER
        ,x.row_hash --get prior row_hash for comparison
        ,coalesce(x.created_by_user_name,current_user()) as created_by_user_name --if the record already exists, need to retain original created_by
        ,coalesce(x.created_by_timestamp,current_timestamp()) as created_by_timestamp --if the record already exists, need to retain original created_timestamp
        from {{ ref("LINEITEM") }} l
        left join {{this}} x on l.L_ORDERKEY = x.order_key and l.L_LINENUMBER = x.line_number
        where l.updated_by_timestamp >= (select max(updated_by_timestamp) from {{this}})
    )

{% endif %}

select 
x.L_COMMENT as line_item_comment
,x.L_COMMITDATE as commit_date
,x.L_DISCOUNT as discount
,x.L_EXTENDEDPRICE as extended_price
,x.L_LINENUMBER as line_number
,x.L_LINESTATUS as line_status
,x.L_ORDERKEY as order_key
,x.L_PARTKEY as part_key
,x.L_QUANTITY as quantity
,x.L_RECEIPTDATE as receipt_date
,x.L_RETURNFLAG as return_flag
,x.L_SHIPDATE as ship_date
,x.L_SHIPINSTRUCT as shipping_instructions
,x.L_SHIPMODE as shipping_mode
,x.L_SUPPKEY as supplier_key
,x.L_TAX as line_tax
,x.row_hash

{% if is_incremental() %}
  -- this will only be applied on an incremental run
,coalesce(pv.created_by_user_name,current_user()) as created_by_user_name
,coalesce(pv.created_by_timestamp,current_timestamp()) as created_by_timestamp
{% else %}
  -- this will only be applied on the initial run or full refresh
,current_user() as created_by_user_name
,current_timestamp() as created_by_timestamp
{% endif %}

,current_user() as updated_by_user_name
,current_timestamp() as updated_by_timestamp
from {{ ref("LINEITEM") }} x

{% if is_incremental() %}
  -- this filter will only be applied on an incremental run

    join prior_vals pv 
      on (x.L_ORDERKEY = pv.L_ORDERKEY and x.L_LINENUMBER = pv.L_LINENUMBER)
      and (coalesce(x.row_hash,0) != coalesce(pv.row_hash,0)) --ensure null matches to null

{% endif %}