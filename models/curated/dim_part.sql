{{
  config(
    materialized='incremental',
    tags=['dimensions','supply_chain'],
    unique_key='part_key',
    on_schema_change='append_new_columns',
    transient=false
  )
}}


with parts as (
    select 
    x.part_key
    ,x.part_name
    ,x.brand
    ,x.container
    ,x.manufacturer
    ,x.retail_price
    ,x.size
    ,x.part_type
    ,x.part_comment
    ,hash(
        x.part_key
        ,x.part_name
        ,x.brand
        ,x.container
        ,x.manufacturer
        ,x.retail_price
        ,x.size
        ,x.part_type
        ,x.part_comment
    ) as row_hash
    from {{ ref("part") }} x
)

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- get the prior created by and create timestamp to retain through a potential record merge if updated.
  -- get all cusotmer records and row_hash to determine later if a merge is truly necessary
    , prior_vals as (
        select
        p.part_key
        ,x.row_hash --if the record already exists, get prior row_hash for comparison
        ,x.created_by_user_name --if the record already exists, need to retain original created_by
        ,x.created_by_timestamp --if the record already exists, need to retain original created_timestamp
        from {{ ref("part") }} p
        left join {{this}} x on p.part_key = x.part_key
        where p.updated_by_timestamp >= (select max(updated_by_timestamp) from {{this}})
    )

{% endif %}

select 
x.part_key
,x.part_name
,x.brand
,x.container
,x.manufacturer
,x.retail_price
,x.size
,x.part_type
,x.part_comment
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
from parts x
{% if is_incremental() %}
  -- this filter will only be applied on an incremental run

    join prior_vals pv
        on x.part_key = pv.part_key
        and coalesce(x.row_hash,0) != coalesce(pv.row_hash,0) --ensure null row_hash matches can be processed

{% endif %}
