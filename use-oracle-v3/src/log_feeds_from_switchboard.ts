import fs from "fs";
import { AptosClient } from "aptos";
import { NODE_URL } from "./utils/env";
import { aggregators } from "./utils/env_switchboard";
import { currentRound } from "./utils/log_resource";

const logCurrentRound = (
  name: string,
  datetime: string,
  data: Awaited<ReturnType<AptosClient["getAccountResource"]>>
) => {
  fs.writeFileSync(
    `temp/currentRound-${name}-${datetime}.log`,
    JSON.stringify(data, null, 2),
    { flag: "a" }
  );
}
const logLatestConfirmedRound = (
  name: string,
  datetime: string,
  data: Awaited<ReturnType<AptosClient["getAccountResource"]>>
) => {
  fs.writeFileSync(
    `temp/latestConfirmedRound-${name}-${datetime}.log`,
    JSON.stringify(data, null, 2),
    { flag: "a" }
  );
}

(async () => {
  const client = new AptosClient(NODE_URL)
  
  const currentDatetime = new Date().toISOString().replace(/(-|T|:)/g, "").substring(0, 14)
  logCurrentRound(
    "usdcusd",
    currentDatetime,
    await currentRound(client, aggregators.usdcusd)
  )
  logCurrentRound(
    "btcusd",
    currentDatetime,
    await currentRound(client, aggregators.btcusd)
  )
})();
