{% macro create_masking_policy__sensitive_name(ns) -%}

  create or replace masking policy {{ ns }}.sensitive_name
    as (val string) returns string ->
    case
    when current_role() in ('DBT_ADMIN','SYSADMIN') then val
    else '****MASKED****'
    end
    comment = 'mask a string unless a dbt or sys admin'
    exempt_other_policies = true
;

{%- endmacro %}