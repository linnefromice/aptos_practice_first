# use-oracle-in-contract-with-pyth

**add price feed**

```bash
move run --function-id ${ADDR}::pyth_oracle_v1::add_price_feed --type-args ${ADDR}::coins::APT --args hex_array:[0x44a93dddd8effa54ea51076c4e851b6cbbfd938e82eb90197de38fe8876bb66e] --assume-yes
move run --function-id ${ADDR}::pyth_oracle_v1::add_price_feed --type-args ${ADDR}::coins::USDC --args hex_array:[0x41f3625971ca2ed2263e78573fe5ce23e13d2558ed3f2e47ab0f84fb9e7ae722] --assume-yes
move run --function-id ${ADDR}::pyth_oracle_v1::add_price_feed --type-args ${ADDR}::coins::USDT --args hex_array:[0x1fc18861232290221461220bd4e2acd1dcdfbc89c84092c93c18bdc7756c1588] --assume-yes
```

**feed**

```bash
move run --function-id ${ADDR}::pyth_oracle_v1::price --type-args ${ADDR}::coins::APT
move run --function-id ${ADDR}::pyth_oracle_v1::price --type-args ${ADDR}::coins::USDC
move run --function-id ${ADDR}::pyth_oracle_v1::price --type-args ${ADDR}::coins::USDT
```