import { AptosClient } from "aptos";
import { NODE_URL, } from "./utils/env";
import { aggregators } from "./utils/env_switchboard";
import { currentRound } from "./utils/log_resource";

(async () => {
  const client = new AptosClient(NODE_URL)
  const resource = await currentRound(client, aggregators.btcusd)
  // console.log(JSON.stringify(resource, null, 2))
  console.log(JSON.stringify(resource["data"], null, 2))
})();
