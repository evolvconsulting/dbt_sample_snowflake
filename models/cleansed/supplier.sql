{{
  config(
    materialized='incremental',
    tags=['data_cleansing'],
    unique_key='supplier_key',
    on_schema_change='append_new_columns',
    transient=false
  )
}}

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- get the prior created by and create timestamp to retain through a potential record merge if updated.
    with prior_vals as (
        select
        x.supplier_key
        ,x.row_hash
        ,x.created_by_user_name
        ,x.created_by_timestamp
        from {{this}} x
    )

{% endif %}

select 
x.S_ACCTBAL as account_balance
,x.S_ADDRESS as full_address
,x.S_COMMENT as supplier_comment
,x.S_NAME as supplier_name
,x.S_NATIONKEY as nation_key
,x.S_PHONE as phone_number
,x.S_SUPPKEY as supplier_key
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
from {{ ref("SUPPLIER") }} x

{% if is_incremental() %}
  -- this filter will only be applied on an incremental run

    left join prior_vals pv 
      on x.S_SUPPKEY = pv.supplier_key
    where (x.row_hash != pv.row_hash or pv.row_hash is null)

{% endif %}