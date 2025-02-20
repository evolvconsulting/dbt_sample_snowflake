{{
  config(
    materialized='incremental',
    tags=['logs'],
    unique_key='record_key',
    on_schema_change='append_new_columns',
    transient=false
  )
}}

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- get the prior created by and create timestamp to retain through a potential record merge if updated.
    with prior_vals as (
        select
        x.record_key
        ,x.row_hash
        ,x.created_by_user_name
        ,x.created_by_timestamp
        from {{this}} x
    )

{% endif %}

select 
x.record_key
,x.file_name
,x.file_row_content
,x.file_row_number
,x.file_last_modified
,regexp_like(file_row_content,'^={30}.*') as Is_Run_Header
,case when Is_Run_Header then split_part(split_part(file_row_content,'|',2),' ',2) else '' end as Run_Id
,lead(run_id,1,run_id) over(order by file_row_number) Real_Run_Id
,regexp_like(file_row_content,'^\\\\[.*') as Is_New_Log_Row
,case when Is_New_Log_Row then split_part(file_row_content,'[MainThread]: ',2) else '' end as Run_Info
,case when not Is_Run_Header and not Is_New_Log_Row then file_row_content else '' end as Run_Info_Continued
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
from {{ ref("dbt_logs_csv") }} x

{% if is_incremental() %}
  -- this filter will only be applied on an incremental run

    left join prior_vals pv 
      on x.record_key = pv.record_key
    where (x.row_hash != pv.row_hash or pv.row_hash is null)

{% endif %}