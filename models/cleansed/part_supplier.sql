{{
  config(
    materialized='incremental',
    tags=['data_cleansing'],
    unique_key=['part_key','supplier_key'],
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
        ,x.supplier_key
        ,x.row_hash
        ,x.created_by_user_name
        ,x.created_by_timestamp
        from {{this}} x
    )

{% endif %}

select 
x.PS_AVAILQTY as part_supplier_available_quantity
,x.PS_COMMENT as part_supplier_comment
,x.PS_PARTKEY as part_key
,x.PS_SUPPKEY as supplier_key
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
from {{ ref("PARTSUPP") }} x

{% if is_incremental() %}
  -- this filter will only be applied on an incremental run

    left join prior_vals pv 
      on x.PS_PARTKEY = pv.part_key and x.PS_SUPPKEY = pv.supplier_key
    where (x.row_hash != pv.row_hash or pv.row_hash is null)

{% endif %}