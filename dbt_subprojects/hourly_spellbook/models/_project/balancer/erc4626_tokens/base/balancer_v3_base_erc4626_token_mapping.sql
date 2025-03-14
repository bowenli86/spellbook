{{
    config(
        schema = 'balancer_v3_base',
        alias = 'erc4626_token_mapping', 
        materialized = 'table',
        file_format = 'delta'
    )
}}

WITH aave_tokens AS(
SELECT 
    b.output_0 AS erc4626_token,
    t2.symbol AS erc4626_token_name,
    t2.symbol AS erc4626_token_symbol,
    BYTEARRAY_SUBSTRING(b.salt, 13, 24) AS underlying_token,
    t1.symbol AS underlying_token_symbol,
    t2.decimals AS decimals
FROM {{ source('aave_v3_base', 'StataToken_evt_Initialized') }} a
JOIN {{ source('aave_v3_base', 'StataTokenFactory_call_createDeterministic') }} b
ON b.output_0 = a.contract_address
JOIN {{ source('tokens', 'erc20') }} t1
ON t1.blockchain = 'base'
AND BYTEARRAY_SUBSTRING(b.salt, 13, 36) = t1.contract_address
JOIN {{ source('tokens', 'erc20') }} t2
ON t2.blockchain = 'base'
AND b.output_0 = t2.contract_address),

morpho_tokens AS(
SELECT DISTINCT
    a.metaMorpho AS erc4626_token,
    a.name AS erc4626_token_name,
    a.symbol AS erc4626_token_symbol,
    a.asset AS underlying_token,
    t.symbol AS underlying_token_symbol,
    18 AS decimals
FROM {{ source('metamorpho_factory_base', 'MetaMorphoV1_1Factory_evt_CreateMetaMorpho') }} a
JOIN {{ source('tokens', 'erc20') }} t
ON t.blockchain = 'base'
AND a.asset = t.contract_address
),

yearn_tokens AS(
SELECT 
    erc4626_token,
    erc4626_token_name,
    erc4626_token_symbol,
    underlying_token,
    underlying_token_symbol,
    decimals
FROM (VALUES 
     (0xe9F2a5F9f3c846f29066d7fB3564F8E6B6b2D65b, 'SuperUSDC', 'ysUSDC', 0x833589fcd6edb6e08f4c7c32d4f71b54bda02913, 'USDC', 6),
     (0xffe8b2295cef70290819a8193834cc7900bcef5f, 'SuperUSDC SuperPosition', 'sp-ysUSDC', 0x833589fcd6edb6e08f4c7c32d4f71b54bda02913, 'USDC', 6)
    ) AS temp_table (erc4626_token, erc4626_token_name, erc4626_token_symbol, underlying_token, underlying_token_symbol, decimals)
)

SELECT 
    'base' AS blockchain, 
    * 
FROM aave_tokens

UNION

SELECT 
    'base' AS blockchain, 
    * 
FROM morpho_tokens

UNION

SELECT 
    'base' AS blockchain, 
    * 
FROM yearn_tokens