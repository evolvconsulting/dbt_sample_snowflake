{{
  config(
    materialized='incremental',
    tags=['data_cleansing'],
    unique_key='customer_key',
    on_schema_change='append_new_columns',
    transient=false
  )
}}

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- get the prior created by and create timestamp to retain through a potential record merge if updated.
    with prior_vals as (
        select
        x.customer_key
        ,x.row_hash
        ,x.created_by_user_name
        ,x.created_by_timestamp
        from {{this}} x
    )

{% endif %}

select 
x.C_ACCTBAL as account_balance
,x.C_ADDRESS as full_address
,x.C_COMMENT as customer_comment
,x.C_CUSTKEY as customer_key
,x.C_MKTSEGMENT as market_segment
,x.C_NAME as customer_name
,x.C_NATIONKEY as nation_key
,x.C_PHONE as phone_number
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
from {{ ref("CUSTOMER") }} x

{% if is_incremental() %}
  -- this filter will only be applied on an incremental run

    left join prior_vals pv 
      on x.C_CUSTKEY = pv.customer_key
    where (x.row_hash != pv.row_hash or pv.row_hash is null)

{% endif %}