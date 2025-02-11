{{
  config(
    materialized='incremental',
    tags=['facts','orders'],
    unique_key=['order_key','line_number'],
    on_schema_change='append_new_columns',
    transient=false
  )
}}


with lines as (
    select 
    x.order_key
    ,x.line_number
    ,x.part_key
    ,x.supplier_key
    ,o.customer_key
    ,c.nation_key
    ,c.region_key  
    ,o.order_date
    ,x.commit_date
    ,x.receipt_date
    ,x.ship_date
    ,x.quantity
    ,x.extended_price
    ,x.discount
    ,x.line_tax
    -- ,x.line_item_comment -- add to dim_order_line_item
    -- ,x.line_status -- add to dim_order_line_item
    -- ,x.return_flag -- add to dim_order_line_item
    -- ,x.shipping_instructions -- add to dim_order_line_item
    -- ,x.shipping_mode -- add to dim_order_line_item
    ,hash(
        x.order_key
        ,x.line_number
        ,x.part_key
        ,x.supplier_key
        ,o.customer_key
        ,c.nation_key
        ,c.region_key  
        ,o.order_date
        ,x.commit_date
        ,x.receipt_date
        ,x.ship_date
        ,x.quantity
        ,x.extended_price
        ,x.discount
        ,x.line_tax
    ) as row_hash
    from {{ ref("order_line_item") }} x
    join {{ ref("orders") }} o on x.order_key = o.order_key
    left join {{ ref("dim_customer") }} c on o.customer_key = c.customer_key
)

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- get the prior created by and create timestamp to retain through a potential record merge if updated.
  -- get all cusotmer records and row_hash to determine later if a merge is truly necessary
    , prior_vals as (
        select
        l.order_key
        ,l.line_number
        ,x.row_hash --if the record already exists, get prior row_hash for comparison
        ,x.created_by_user_name --if the record already exists, need to retain original created_by
        ,x.created_by_timestamp --if the record already exists, need to retain original created_timestamp
        from {{ ref("order_line_item") }} l
        left join {{this}} x on l.order_key = x.order_key and l.line_number = x.line_number
        where l.updated_by_timestamp >= (select max(updated_by_timestamp) from {{this}})
    )

{% endif %}

select 
x.order_key
,x.line_number
,x.part_key
,x.supplier_key
,x.customer_key
,x.nation_key
,x.region_key  
,x.order_date
,x.commit_date
,x.receipt_date
,x.ship_date
,x.quantity
,x.extended_price
,x.discount
,x.line_tax
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
from lines x
{% if is_incremental() %}
  -- this filter will only be applied on an incremental run

    join prior_vals pv
        on x.order_key = pv.order_key and x.line_number = pv.line_number
        and coalesce(x.row_hash,0) != coalesce(pv.row_hash,0) --ensure null row_hash matches can be processed

{% endif %}
