import { AptosClient } from "aptos";
import { NODE_URL, AGGREGATOR_ADDRESS } from "./utils/env";
import { currentRound, latestConfirmedRound } from "./utils/log_resource";

const _currentRound = async (client: AptosClient, addr: string) => await currentRound(client, addr);
const _latestConfirmedRound = async (client: AptosClient, addr: string) => await latestConfirmedRound(client, addr);

(async () => {
  const client = new AptosClient(NODE_URL)

  const fnName = process.argv[2]
  const addr = process.argv[3] ?? AGGREGATOR_ADDRESS
  if (fnName == "current") {
    const data = await _currentRound(client, addr)
    console.log(JSON.stringify(data, null, 2))
    return
  }
  if (fnName == "latest") {
    const data = await _latestConfirmedRound(client, addr)
    console.log(JSON.stringify(data, null, 2))
    return
  }
  throw new Error("No applicable options")
})();
