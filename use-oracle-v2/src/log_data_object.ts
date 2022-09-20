import path from 'path'
import dotenv from 'dotenv'
import { AptosClient } from "aptos";
import { AggregatorAccount, LeaseAccount } from '@switchboard-xyz/aptos.js';

// parameters
const AGGREGATOR_ACCOUNT = "0x6973a4350224669214a9a5c6d46074b55f1e98831e439d8d760d6bc9360875d7"; // temp

// load envs
const envName = process.env.ENV_NAME
if (!envName) throw new Error("[ERROR] Need ENV_NAME")
const ENV_PATH = path.join(process.cwd(), `.${envName}.env`);
const parsed = dotenv.config({ path: ENV_PATH }).parsed
if (!parsed) throw new Error("[ERROR] donot parse from dotenv")

const NODE_URL = parsed["NODE_URL"];
const SWITCHBOARD_ADDRESS = parsed["SWITCHBOARD_ADDRESS"];
const SWITCHBOARD_QUEUE_ADDRESS = parsed["SWITCHBOARD_QUEUE_ADDRESS"];

(async () => {
  const client = new AptosClient(NODE_URL);
  const aggregator = new AggregatorAccount(
    client,
    AGGREGATOR_ACCOUNT,
    SWITCHBOARD_ADDRESS
  )

  console.log("logging all data objects");
  console.log("Aggregator:", await aggregator.loadData());
  console.log(
    "Lease:",
    await new LeaseAccount(
      client,
      aggregator.address,
      SWITCHBOARD_ADDRESS
    ).loadData(SWITCHBOARD_QUEUE_ADDRESS)
  );
  console.log("Load aggregator jobs data", JSON.stringify(await aggregator.loadJobs()));
})();
