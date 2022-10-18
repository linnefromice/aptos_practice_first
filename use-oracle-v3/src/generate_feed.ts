import * as fs from "fs";
import * as YAML from "yaml";
import Big from "big.js";
import { AptosClient, FaucetClient, AptosAccount, HexString } from "aptos";
import { createFeed } from "@switchboard-xyz/aptos.js";
import { usdcJobs } from "./jobs/usdc";
import { NODE_URL, FAUCET_URL, SWITCHBOARD_ADDRESS } from "./utils/env";

(async () => {
  const client = new AptosClient(NODE_URL);
  const faucetClient = new FaucetClient(NODE_URL, FAUCET_URL);

  const parsedYaml = YAML.parse(
    fs.readFileSync(".aptos/config.yaml", "utf8")
  )
  const user = new AptosAccount(
    HexString.ensure(parsedYaml.profiles.default.private_key).toUint8Array()
  );
  const aggregator_acct = new AptosAccount();
  await faucetClient.fundAccount(aggregator_acct.address(), 50000);
  console.log(`user: ${user.address()}`)
  console.log(`aggregator_account: ${aggregator_acct.address()}`)

  const serializedJob = usdcJobs.binance // temp
  const [aggregator, createFeedTx] = await createFeed(
    client,
    user,
    {
      authority: user.address(),
      queueAddress: SWITCHBOARD_ADDRESS,
      batchSize: 1,
      minJobResults: 1,
      minOracleResults: 1,
      minUpdateDelaySeconds: 5,
      varianceThreshold: new Big(0),
      coinType: "0x1::aptos_coin::AptosCoin",
      crankAddress: SWITCHBOARD_ADDRESS,
      initialLoadAmount: 1000,
      jobs: [
        {
          name: "USDC/USD",
          metadata: "binance",
          authority: user.address().hex(),
          data: serializedJob.toString("base64"),
          weight: 1,
        },
      ],
    },
    SWITCHBOARD_ADDRESS
  );

  console.log(`aggregator.address: ${aggregator.address}`)
  console.log(`tx.hash: ${createFeedTx}`);
  console.log(`(Created Aggregator and Lease resources at account address)`)
})();
