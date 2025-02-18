{{
  config(
    materialized='file_format',
    tags=['formats'],
  )
}}
--options
TYPE = 'CSV' 
FIELD_DELIMITER = '|||'