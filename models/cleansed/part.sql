{{
  config(
    materialized='incremental',
    tags=['data_cleansing'],
    unique_key='part_key',
    on_schema_change='append_new_columns',
    transient=false
  )
}}

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- get the prior created by and create timestamp to retain through a potential record merge if updated.
    with prior_vals as (
        select
        x.part_key
        ,x.row_hash
        ,x.created_by_user_name
        ,x.created_by_timestamp
        from {{this}} x
    )

{% endif %}

select 
x.P_BRAND as brand
,x.P_COMMENT as part_comment
,x.P_CONTAINER as container
,x.P_MFGR as manufacturer
,x.P_NAME as part_name
,x.P_PARTKEY as part_key
,x.P_RETAILPRICE as retail_price
,x.P_SIZE as size
,x.P_TYPE as part_type
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
from {{ ref("PART") }} x

{% if is_incremental() %}
  -- this filter will only be applied on an incremental run

    left join prior_vals pv 
      on x.P_PARTKEY = pv.part_key
    where (x.row_hash != pv.row_hash or pv.row_hash is null)

{% endif %}