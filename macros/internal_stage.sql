
{% materialization internal_stage, adapter='snowflake' %}
    {#establish relation#}
    {%- set target_relation = api.Relation.create(database=model['database'], schema=model['schema'], identifier=model['alias']) -%}   
    
    {#set default sql command prefix#}
    {%- set prefix='create or replace stage' -%}  

    {#check existence of stage (relation)#}
    {%- set stage_exists=check_object_existence(target_relation,'internal_stage') -%} 

    {#set final stage query to execute#}
    {%- set query -%}
        {%- set relation -%}
            {{ target_relation.database }}.{{ target_relation.schema }}.{{ target_relation.alias or target_relation.name }}
        {%- endset %}

        {#update sql command prefix when processing incrementally to not recreate stage#}
        {% if should_full_refresh() or stage_exists[0] == 0 %}
            {{prefix}} {{relation}} 
            {{ sql }};
        {% else %}
            alter stage {{relation}} refresh;
        {% endif %} 

    {%- endset %}

    {% call statement('main') -%}        
        {{ query }}            
    {% endcall -%}

    {{ return({'relations': [target_relation]}) }}
{% endmaterialization %}