
{% macro check_object_existence(relation,object_type) -%}

{% if object_type.upper() == 'INTERNAL_STAGE' %}
    {# Look in Stages information schema #}
    {%- set information_schema_view_name = 'stages' -%}
    {%- set filter_prefix = 'stage' -%}
{% elif object_type.upper() == 'FILE_FORMAT' %}
    {# Look in Stages information schema #}
    {%- set information_schema_view_name = 'file_formats' -%}
    {%- set filter_prefix = 'file_format' -%}
{% endif %}

{%- set relation_query -%}
    select count(1) as count
    from {{relation['database']}}.information_schema.{{information_schema_view_name}}
    where {{filter_prefix}}_catalog = '{{relation['database'].upper()}}'
    and {{filter_prefix}}_schema = '{{relation['schema'].upper()}}'
    and {{filter_prefix}}_name = '{{relation['name'].upper()}}'
    ;
{%- endset %}

{% set results = run_query(relation_query) %}

{% if execute %}
    {# Return the first column #}
    {% set results_list = results.columns[0].values() %}
    {% else %}
    {% set results_list = [] %}
{% endif %}

{{ return(results_list) }}

{%- endmacro %}