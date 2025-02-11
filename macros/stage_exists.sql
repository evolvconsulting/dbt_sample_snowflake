
{% macro check_stage_existence(relation) -%}

{%- set relation_query -%}
    select count(1) as count
    from dbt_sample_dev.information_schema.stages
    where stage_schema = '{{relation['schema'].upper()}}'
    and stage_name = '{{relation['name'].upper()}}'
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