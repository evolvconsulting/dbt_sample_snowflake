{{
  config(
    materialized='incremental',
    tags=['dimensions','customer'],
    unique_key='customer_key',
    on_schema_change='append_new_columns',
    transient=false
  )
}}


with customers as (
    select 
    x.customer_key
    ,n.nation_key
    ,r.region_key   
    ,x.customer_name
    ,n.nation_name
    ,r.region_name
    ,x.market_segment
    ,x.customer_comment
    ,x.full_address
    ,x.phone_number
    --,x.account_balance -- add to fact_customer
    ,hash(
        x.customer_key
        ,n.nation_key
        ,r.region_key   
        ,x.customer_name
        ,n.nation_name
        ,r.region_name
        ,x.market_segment
        ,x.customer_comment
        ,x.full_address
        ,x.phone_number
    ) as row_hash
    from {{ ref("customer") }} x
    left join {{ ref("nation") }} n on x.nation_key = n.nation_key
    left join {{ ref("region") }} r on n.region_key = r.region_key
)

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- get the prior created by and create timestamp to retain through a potential record merge if updated.
  -- get all cusotmer records and row_hash to determine later if a merge is truly necessary
    , prior_vals as (
        select
        c.customer_key
        ,x.row_hash --if the record already exists, get prior row_hash for comparison
        ,x.created_by_user_name --if the record already exists, need to retain original created_by
        ,x.created_by_timestamp --if the record already exists, need to retain original created_timestamp
        from {{ ref("customer") }} c
        left join {{this}} x on c.customer_key = x.customer_key
        where c.updated_by_timestamp >= (select max(updated_by_timestamp) from {{this}})
    )

{% endif %}

select 
x.customer_key
,x.nation_key
,x.region_key   
,x.customer_name
,x.nation_name
,x.region_name
,x.market_segment
,x.customer_comment
,x.full_address
,x.phone_number
,x.row_hash

{% if is_incremental() %}
  -- this will only be applied on an incremental run
,pv.created_by_user_name as created_by_user_name
,pv.created_by_timestamp as created_by_timestamp
{% else %}
  -- this will only be applied on the initial run or full refresh
,current_user() as created_by_user_name
,current_timestamp() as created_by_timestamp
{% endif %}

,current_user() as updated_by_user_name
,current_timestamp() as updated_by_timestamp
from customers x
{% if is_incremental() %}
  -- this filter will only be applied on an incremental run

    join prior_vals pv
        on x.customer_key = pv.customer_key
        and coalesce(x.row_hash,0) != coalesce(pv.row_hash,0) --ensure null row_hash matches can be processed

{% endif %}
