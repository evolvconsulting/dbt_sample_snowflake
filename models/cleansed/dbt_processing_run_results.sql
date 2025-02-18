{{
  config(
    materialized='incremental',
    tags=['logs'],
    unique_key='invocation_id',
    on_schema_change='append_new_columns',
    transient=false
  )
}}

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- get the prior created by and create timestamp to retain through a potential record merge if updated.
    with prior_vals as (
        select
        x.invocation_id
        ,x.row_hash
        ,x.created_by_user_name
        ,x.created_by_timestamp
        from {{this}} x
    )

{% endif %}

select 
x.invocation_id
,x.dbt_schema_version
,x.dbt_version
,x.generated_at_UTC
,x.file_name
,x.file_json
,x.file_json:results::variant as run_results_json
,x.file_json:elapsed_time::float as total_execution_time_seconds
,x.file_json:args:write_json::boolean as arg_write_json
,x.file_json:args:require_explicit_package_overrides_for_builtin_materializations::boolean as arg_require_explicit_package_overrides_for_builtin_materializations
,x.file_json:args:quiet::boolean as arg_quiet
,x.file_json:args:store_failures::boolean as arg_store_failures
,x.file_json:args:require_nested_cumulative_type_params::boolean as arg_require_nested_cumulative_type_params
,x.file_json:args:use_experimental_parser::boolean as arg_use_experimental_parser
,x.file_json:args:profiles_dir::varchar as arg_profiles_dir
,x.file_json:args:skip_nodes_if_on_run_start_fails::boolean as arg_skip_nodes_if_on_run_start_fails
,x.file_json:args:state_modified_compare_more_unrendered_values::boolean as arg_state_modified_compare_more_unrendered_values
,x.file_json:args:populate_cache::boolean as arg_populate_cache
,x.file_json:args:require_batched_execution_for_custom_microbatch_strategy::boolean as arg_require_batched_execution_for_custom_microbatch_strategy
,x.file_json:args:indirect_selection::varchar as arg_indirect_selection
,x.file_json:args:log_file_max_bytes::integer as arg_log_file_max_bytes
,x.file_json:args:debug::boolean as arg_debug 
,x.file_json:args:state_modified_compare_vars::boolean as arg_state_modified_compare_vars
,x.file_json:args:single_threaded::boolean as arg_single_threaded
,x.file_json:args:defer::boolean as arg_defer
,x.file_json:args:static_parser::boolean as arg_static_parser
,x.file_json:args:log_format_file::varchar as arg_log_format_file
,x.file_json:args:invocation_command::varchar as arg_invocation_command
,x.file_json:args:show_resource_report::boolean as arg_show_resource_report
,x.file_json:args:vars::variant as arg_vars
,x.file_json:args:fail_fast::boolean as arg_fail_fast
,x.file_json:args:introspect::boolean as arg_introspect
,x.file_json:args:macro::varchar as arg_macro
,x.file_json:args:require_yaml_configuration_for_mf_time_spines::boolean as arg_require_yaml_configuration_for_mf_time_spines
,x.file_json:args:log_cache_events::boolean as arg_log_cache_events
,x.file_json:args:partial_parse::boolean as arg_partial_parse
,x.file_json:args:strict_mode::boolean as arg_strict_mode
,x.file_json:args:require_resource_names_without_spaces::boolean as arg_require_resource_names_without_spaces
,x.file_json:args:use_colors_file::boolean as arg_use_colors_file
,x.file_json:args:version_check::boolean as arg_version_check
,x.file_json:args:send_anonymous_usage_stats::boolean as arg_send_anonymous_usage_stats
,x.file_json:args:source_freshness_run_project_hooks::boolean as arg_source_freshness_run_project_hooks
,x.file_json:args:macro_debugging::boolean as arg_macro_debugging
,x.file_json:args:favor_state::boolean as arg_favor_state
,x.file_json:args:partial_parse_file_diff::boolean as arg_partial_parse_file_diff
,x.file_json:args:printer_width::integer as arg_printer_width
,x.file_json:args:cache_selected_only::boolean as arg_cache_selected_only
,x.file_json:args:log_format::varchar as arg_log_format
,x.file_json:args:which::varchar as arg_which
,x.file_json:args:log_level_file::varchar as arg_log_level_file
,x.file_json:args:log_level::varchar as arg_log_level
,x.file_json:args:print::boolean as arg_print
,x.file_json:args:full_refresh::boolean as arg_full_refresh
,x.file_json:args:use_colors::boolean as arg_use_colors
,x.file_row_number
,x.file_last_modified
,x.row_hash

{% if is_incremental() %}
  -- this will only be applied on an incremental run
,coalesce(pv.created_by_user_name,current_user()) as created_by_user_name
,coalesce(pv.created_by_timestamp,current_timestamp()) as created_by_timestamp
{% else %}
  -- this will only be applied on the initial run or full refresh
,current_user() as created_by_user_name
,current_timestamp() as created_by_timestamp
{% endif %}

,current_user() as updated_by_user_name
,current_timestamp() as updated_by_timestamp
from {{ ref("dbt_run_results_json") }} x

{% if is_incremental() %}
  -- this filter will only be applied on an incremental run

    left join prior_vals pv 
      on x.invocation_id = pv.invocation_id
    where (x.row_hash != pv.row_hash or pv.row_hash is null)

{% endif %}