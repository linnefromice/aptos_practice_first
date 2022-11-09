# use-oracle-in-contract-with-pyth

**add price feed**

-> `initialize.sh`

**feed**

```bash
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::price_entry --type-args 0x${ADDR}::coins::APT
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::price_entry --type-args 0x${ADDR}::coins::USDC
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::price_entry --type-args 0x${ADDR}::coins::USDT
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::price_entry --type-args 0x${ADDR}::coins::FX_USD_JPY
```