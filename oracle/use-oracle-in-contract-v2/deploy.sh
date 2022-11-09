ADDR=$(aptos account lookup-address | jq -r '.Result')
sed -i '' -E "s/\"0xAAAAAAAA\"/\"0x$ADDR\"/g" Move.toml
aptos account fund-with-faucet --account ${ADDR} --amount 100000000000
aptos move test
aptos move compile
aptos move publish --assume-yes