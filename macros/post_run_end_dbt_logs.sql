
{% macro post_run_end_dbt_logs() -%}

    {%- set file_count = 0 -%}

    {% set result = store_files(filepath='./logs/dbt_20*.log', stage='content/logs', schema='raw') %}

    {% set result = store_files(filepath='./target/run_results_20*.json', stage='content/logs', schema='raw') %}

    {{- log('dbt logs successfully captured.', info=True) -}}

{%- endmacro %}