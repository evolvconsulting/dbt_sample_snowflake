
{{
  config(
    materialized='internal_stage',
    tags=['stages','initial'],
  )
}}
--options
encryption = (type = 'SNOWFLAKE_SSE')
directory = (enable = true)