{{
  config(
    schema = 'eas_zksync',
    alias = 'schemas',
    materialized = 'incremental',
    file_format = 'delta',
    incremental_strategy = 'merge',
    unique_key = ['schema_uid'],
    incremental_predicates = [incremental_predicate('DBT_INTERNAL_DEST.block_time')]
  )
}}

{{
  eas_schemas(
    blockchain = 'zksync',
    project = 'eas',
    version = '1',
    decoded_project_name = 'attestationstation_v1'
  )
}}
