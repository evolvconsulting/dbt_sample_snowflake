{{
  config(
    materialized='table',
    tags=['logs'],
    transient=false
  )
}}
--get a single column with the entire row from the file
SELECT 
t.$1:metadata:invocation_id::varchar as invocation_id
,t.$1:metadata:dbt_schema_version::varchar as dbt_schema_version
,t.$1:metadata:dbt_version::varchar as dbt_version
,t.$1:metadata:generated_at::varchar as generated_at_UTC
,METADATA$FILENAME as file_name
,t.$1 as file_json
,METADATA$FILE_ROW_NUMBER as file_row_number
,METADATA$FILE_LAST_MODIFIED as file_last_modified
,current_user() as created_by_user_name
,current_timestamp() as created_by_timestamp
,current_user() as updated_by_user_name
,current_timestamp() as updated_by_timestamp
,hash(t.$1) as row_hash
FROM @{{ ref('content') }}/logs 
(file_format => {{ ref('ff_dbt_log_json') }}
,pattern => '.*.json') t