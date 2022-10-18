import { AptosClient } from "aptos";
import { SWITCHBOARD_ADDRESS } from "./env";

const resources = {
  aggregatorRound: "aggregator::AggregatorRound",
  currentRound: "aggregator::CurrentRound",
  latestConfirmedRound: "aggregator::LatestConfirmedRound",
}

export const currentRound = async (client: AptosClient, address: string) => {
  const resource = await client.getAccountResource(
    address,
    `${SWITCHBOARD_ADDRESS}::${resources.aggregatorRound}<${SWITCHBOARD_ADDRESS}::${resources.currentRound}>`,
  )

  return resource
}