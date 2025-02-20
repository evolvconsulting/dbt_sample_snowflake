{{
  config(
    materialized='file_format',
    tags=['formats','initial'],
  )
}}
--options
TYPE = 'CSV' 
FIELD_DELIMITER = '|||'