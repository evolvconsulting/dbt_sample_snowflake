{{
  config(
    materialized='table',
    tags=['logs'],
    transient=false
  )
}}
--get a single column with the entire row from the file
SELECT 
hash(t.$1) as row_hash
,hash(METADATA$FILENAME,METADATA$FILE_ROW_NUMBER ) as record_key
,METADATA$FILENAME as file_name
,t.$1 as file_row_content
,METADATA$FILE_ROW_NUMBER as file_row_number
,METADATA$FILE_LAST_MODIFIED as file_last_modified
,current_user() as created_by_user_name
,current_timestamp() as created_by_timestamp
,current_user() as updated_by_user_name
,current_timestamp() as updated_by_timestamp
FROM @{{ ref('content') }}/logs 
(file_format => {{ ref('ff_dbt_log_csv') }}
,pattern => '.*.log') t