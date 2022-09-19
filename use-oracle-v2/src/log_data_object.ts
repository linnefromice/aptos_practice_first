import dotenv from 'dotenv'
import { AptosClient } from "aptos";
import { AggregatorAccount, LeaseAccount } from '@switchboard-xyz/aptos.js';

const parsed = dotenv.config().parsed
if (!parsed) throw new Error("not parsed from dotenv")
const NODE_URL = parsed["NODE_URL"];
const FAUCET_URL = parsed["FAUCET_URL"];
const SWITCHBOARD_DEVNET_ADDRESS = parsed["SWITCHBOARD_DEVNET_ADDRESS"]

const main = async () => {
  const client = new AptosClient(NODE_URL);
  const aggregator = new AggregatorAccount(
    client,
    "0x6973a4350224669214a9a5c6d46074b55f1e98831e439d8d760d6bc9360875d7",
    SWITCHBOARD_DEVNET_ADDRESS
  )

  console.log("logging all data objects");
  console.log("Aggregator:", await aggregator.loadData());
  console.log(
    "Lease:",
    await new LeaseAccount(
      client,
      aggregator.address,
      SWITCHBOARD_DEVNET_ADDRESS
    ).loadData()
  );
  console.log("Load aggregator jobs data", JSON.stringify(await aggregator.loadJobs()));
}

main().then(_ => console.log("SUCCESS")).catch(_ => console.log("FAILURE"))