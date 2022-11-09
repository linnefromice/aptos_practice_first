# use-oracle-in-contract-v2

```bash
ADDR=$(aptos account lookup-address | jq -r '.Result')
aptos move run --function-id 0x${ADDR}::price_oracle::price_entry --type-args 0x${ADDR}::price_oracle::USDC
aptos move run --function-id 0x${ADDR}::price_oracle::cached_price_entry --type-args 0x${ADDR}::price_oracle::USDC
aptos move run --function-id 0x${ADDR}::price_oracle::volume --type-args 0x${ADDR}::price_oracle::USDC --args 5000
aptos move run --function-id 0x${ADDR}::price_oracle::to_amount --type-args 0x${ADDR}::price_oracle::USDC --args 500000
```