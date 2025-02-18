{% macro post_hook_apply_tags() -%}

    {% if flags.WHICH in ['run', 'build'] %}
        {{ dbt_tags.apply_column_tags() }}
    {% endif %}

{%- endmacro %}    