
{{
  config(
    materialized='internal_stage',
    tags=['stages'],
  )
}}
--options
encryption = (type = 'SNOWFLAKE_SSE')
directory = (enable = true)