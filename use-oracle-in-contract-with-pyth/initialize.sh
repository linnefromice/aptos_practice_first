# for mac
ADDR=$(aptos account lookup-address | jq -r '.Result')
# ref: https://pyth.network/developers/price-feed-ids#aptos-testnet
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::initialize --assume-yes
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::add_price_feed --type-args 0x${ADDR}::coins::APT --args hex:44a93dddd8effa54ea51076c4e851b6cbbfd938e82eb90197de38fe8876bb66e --assume-yes
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::add_price_feed --type-args 0x${ADDR}::coins::USDC --args hex:41f3625971ca2ed2263e78573fe5ce23e13d2558ed3f2e47ab0f84fb9e7ae722 --assume-yes
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::add_price_feed --type-args 0x${ADDR}::coins::USDT --args hex:1fc18861232290221461220bd4e2acd1dcdfbc89c84092c93c18bdc7756c1588 --assume-yes
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::add_price_feed --type-args 0x${ADDR}::coins::DAI --args hex:87a67534df591d2dd5ec577ab3c75668a8e3d35e92e27bf29d9e2e52df8de412 --assume-yes
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::add_price_feed --type-args 0x${ADDR}::coins::BTC --args hex:f9c0172ba10dfa4d19088d94f5bf61d3b54d5bd7483a322a982e1373ee8ea31b --assume-yes
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::add_price_feed --type-args 0x${ADDR}::coins::ETH --args hex:ca80ba6dc32e08d06f1aa886011eed1d77c77be9eb761cc10d72b7d0a2fd57a6 --assume-yes
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::add_price_feed --type-args 0x${ADDR}::coins::MATIC --args hex:d2c2c1f2bba8e0964f9589e060c2ee97f5e19057267ac3284caef3bd50bd2cb5 --assume-yes
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::add_price_feed --type-args 0x${ADDR}::coins::EQUITY_AAPL_USD --args hex:afcc9a5bb5eefd55e12b6f0b4c8e6bccf72b785134ee232a5d175afd082e8832 --assume-yes
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::add_price_feed --type-args 0x${ADDR}::coins::EQUITY_AMZN_USD --args hex:095e126b86f4f416a21da0c44b997a379e8647514a1b78204ca0a6267801d00f --assume-yes
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::add_price_feed --type-args 0x${ADDR}::coins::EQUITY_DIS_USD --args hex:5f70ddbab5034fe97cf8722437f7f3a7f575a9f369e751c9567e2c55c9bb554f --assume-yes
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::add_price_feed --type-args 0x${ADDR}::coins::EQUITY_GOOG_USD --args hex:abb1a3382ab1c96282e4ee8c847acc0efdb35f0564924b35f3246e8f401b2a3d --assume-yes
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::add_price_feed --type-args 0x${ADDR}::coins::EQUITY_MSFT_USD --args hex:4e10201a9ad79892f1b4e9a468908f061f330272c7987ddc6506a254f77becd7 --assume-yes
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::add_price_feed --type-args 0x${ADDR}::coins::EQUITY_TSLA_USD --args hex:7dac7cafc583cc4e1ce5c6772c444b8cd7addeecd5bedb341dfa037c770ae71e --assume-yes
aptos move run --function-id 0x${ADDR}::pyth_oracle_v1::add_price_feed --type-args 0x${ADDR}::coins::FX_USD_JPY --args hex:20a938f54b68f1f2ef18ea0328f6dd0747f8ea11486d22b021e83a900be89776 --assume-yes
