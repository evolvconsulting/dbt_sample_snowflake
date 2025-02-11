{{
  config(
    materialized='incremental',
    tags=['data_cleansing'],
    unique_key='order_key',
    on_schema_change='append_new_columns',
    transient=false
  )
}}

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- get the prior created by and create timestamp to retain through a potential record merge if updated.
    with prior_vals as (
        select
        o.O_ORDERKEY
        ,x.row_hash --get prior row_hash for comparison
        ,coalesce(x.created_by_user_name,current_user()) as created_by_user_name --if the record already exists, need to retain original created_by
        ,coalesce(x.created_by_timestamp,current_timestamp()) as created_by_timestamp --if the record already exists, need to retain original created_timestamp
        from {{ ref("ORDERS") }} o
        left join {{this}} x on o.O_ORDERKEY = x.order_key
        where o.updated_by_timestamp >= (select max(updated_by_timestamp) from {{this}})
    )

{% endif %}

select 
x.O_CLERK as order_clerk
,x.O_COMMENT as order_comment
,x.O_CUSTKEY as customer_key
,x.O_ORDERDATE as order_date
,x.O_ORDERKEY as order_key
,x.O_ORDERPRIORITY as order_priority
,x.O_ORDERSTATUS as order_status
,x.O_SHIPPRIORITY as shipping_priority
,x.O_TOTALPRICE as total_price
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
from {{ ref("ORDERS") }} x

{% if is_incremental() %}
  -- this filter will only be applied on an incremental run

    join prior_vals pv 
      on x.O_ORDERKEY = pv.O_ORDERKEY
      and (coalesce(x.row_hash,0) != coalesce(pv.row_hash,0)) --ensure null matches to null

{% endif %}