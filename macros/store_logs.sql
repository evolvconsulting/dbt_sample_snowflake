
{% macro store_logs(filepath,stage,database=none,schema=none) -%}

{#set default database if none is supplied#}
{%- set def_database = database if database is not none else target.database -%}

{#set default schema if none is supplied#}
{%- set def_schema = schema if schema is not none else target.schema -%}

{%- set put_query -%}
    put 'file://{{filepath}}' @{{def_database}}.{{def_schema}}.{{stage}} auto_compress=false overwrite=true;
{%- endset %}

{{- log(put_query, info=True) -}}

{% set results = run_query(put_query) %}

{{- log('dbt logs successfully uploaded.', info=True) -}}

{%- endmacro %}