{% macro create_masking_policy__sensitive_account_balance(ns) -%}

  create or replace masking policy {{ ns }}.sensitive_account_balance
    as (val number) returns number ->
    case
    when current_role() in ('DBT_ADMIN','SYSADMIN') then val
    else null
    end
    comment = 'mask a string unless a dbt or sys admin'
    exempt_other_policies = true
;

{%- endmacro %}