# for mac
ADDR=$(aptos account lookup-address | jq -r '.Result')
aptos move run --function-id 0x${ADDR}::price_oracle::initialize --assume-yes
aptos move run --function-id 0x${ADDR}::price_oracle::add_aggregator --type-args 0x${ADDR}::price_oracle::BTC --args address:0xc07d068fe17f67a85147702359b5819d226591307a5bb54139794f8931327e88 --assume-yes
aptos move run --function-id 0x${ADDR}::price_oracle::add_aggregator --type-args 0x${ADDR}::price_oracle::ETH --args address:0xcaccdee7954db165b1b0923a619b58808937dbf4afb19091fdbb7f0584f41da1 --assume-yes
aptos move run --function-id 0x${ADDR}::price_oracle::add_aggregator --type-args 0x${ADDR}::price_oracle::SOL --args address:0xe2677e5bd7473c13b7a8849d463b0b920b9bb02e98bbb6e638992dcf02394688 --assume-yes
aptos move run --function-id 0x${ADDR}::price_oracle::add_aggregator --type-args 0x${ADDR}::price_oracle::USDC --args address:0x1f7b23e6d81fa2102b2e994d2e54d26d116426c7dda5417925265f7b46f50c73 --assume-yes
aptos move run --function-id 0x${ADDR}::price_oracle::add_aggregator --type-args 0x${ADDR}::price_oracle::NEAR --args address:0x33b7483ec735e6b82a2410e80db68980faf5c462873a75539a57cc26e4347ce8 --assume-yes
aptos move run --function-id 0x${ADDR}::price_oracle::add_aggregator --type-args 0x${ADDR}::price_oracle::APT --args address:0x7ac62190ba57b945975146f3d8725430ad3821391070b965b38206fe4cec9fd5 --assume-yes
