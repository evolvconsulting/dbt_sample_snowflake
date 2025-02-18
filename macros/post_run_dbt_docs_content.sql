{% macro post_run_dbt_docs_content() -%}

    {%- set file_count = 0 -%}

    {% set result = store_files(filepath='./target/index.html', stage='content/dbt_docs', schema='raw') %}
    {% if execute %}
        {%- set file_count = file_count+1 -%}
    {% endif %}

    {% set result = store_files(filepath='./target/catalog.json', stage='content/dbt_docs', schema='raw') %}
    {% if execute %}
        {%- set file_count = file_count+1 -%}
    {% endif %}

    {% set result = store_files(filepath='./target/manifest.json', stage='content/dbt_docs', schema='raw') %}
    {% if execute %}
        {%- set file_count = file_count+1 -%}
    {% endif %}

    {{- log(file_count ~ ' dbt docs successfully captured.', info=True) -}}

{%- endmacro %}