#!/bin/bash
ENV_NAME="testnet" # devnet
URL="fullnode.testnet.aptoslabs.com/v1"
ACCOUNT_ADDRESS="0x790e386260446eeea471da8050103df2b1cbb884a8a120478e04b8c9ff253f2"
RESOURCE_ADDRESS="0xb27f7bbf7caf2368b08032d005e8beab151a885054cdca55c4cc644f0a308d2b"
LOOP_COUNT=10
DURATION=5 # per seconds

# main
i=0
while [ "$i" -lt $LOOP_COUNT ]; do
  now_time=`date +%Y%m%d%H%M%S`
  echo `expr $i + 1`:$now_time
  curl https://${URL}/accounts/${ACCOUNT_ADDRESS}/resource/${RESOURCE_ADDRESS}::aggregator::Aggregator | jq > ${ENV_NAME}_switchboard_aggregator_${now_time}.log
  ## for debug
  # echo https://${URL}/accounts/${ACCOUNT_ADDRESS}/resource/${RESOURCE_ADDRESS}::aggregator::Aggregator
  # echo ${ENV_NAME}_switchboard_aggregator_${now_time}.log
  sleep ${DURATION}
  ((i++))
done
