{{
  config(
    materialized='file_format',
    tags=['formats','initial'],
  )
}}
--options
TYPE = 'JSON' 