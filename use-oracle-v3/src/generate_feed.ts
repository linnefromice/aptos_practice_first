import * as fs from "fs";
import * as YAML from "yaml";
import jsonfile from "jsonfile";
import Big from "big.js";
import { AptosClient, AptosAccount, CoinClient, HexString } from "aptos";
import { createFeed } from "@switchboard-xyz/aptos.js";
// import { usdcJobs } from "./jobs/usdc";
import { ethJobs } from "./jobs/eth";
import { NODE_URL, SWITCHBOARD_ADDRESS } from "./utils/env";

const getAccounts = async (): Promise<{
  user: AptosAccount
  // aggregator_account: AptosAccount
}> => {
  const envName = process.env.ENV_NAME
  if (!envName) throw new Error("[ERROR] Need ENV_NAME")

  const parsedYaml = YAML.parse(
    fs.readFileSync(".aptos/config.yaml", "utf8")
  )
  if (envName == "devnet") {
    const user = new AptosAccount(
      HexString.ensure(parsedYaml.profiles.default.private_key).toUint8Array()
    );
    // const aggregator_account = new AptosAccount();
    // const faucetClient = new FaucetClient(NODE_URL, FAUCET_URL);
    // await faucetClient.fundAccount(aggregator_account.address(), 5000000);

    return {
      user,
      // aggregator_account
    }
  }
  if (envName == "testnet") {
    const user = new AptosAccount(
      HexString.ensure(parsedYaml.profiles.testnet.private_key).toUint8Array()
    );
    // const aggregator_account = new AptosAccount(
    //   HexString.ensure(parsedYaml.profiles.usdc_testnet.private_key).toUint8Array()
    // );
    return {
      user,
      // aggregator_account
    }
  }
  throw new Error("No applicable envName")
}

(async () => {
  const client = new AptosClient(NODE_URL);
  const { user } = await getAccounts()
  console.log(`user: ${user.address()}`)
  // console.log(`aggregator_account: ${aggregator_account.address()}`)

  const name = "ETH/USD"
  const metadata = "binance"
  const serializedJob = ethJobs.binance // temp
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
          name,
          metadata,
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
  const balance = await new CoinClient(client).checkBalance(user)
  console.log(`user's balance: ${(balance.toString())}`)

  // logging
  const filepath = `outputs/feeds-${process.env.ENV_NAME}.json`
  if (!fs.existsSync(filepath)) {
    fs.writeFileSync(filepath, JSON.stringify([]));
  }
  const base = (jsonfile.readFileSync(filepath) as any[]);
  base.push({
    name,
    metadata,
    addresses: {
      user: user.address().toString(),
      aggregator: aggregator.address
    },
    tx: createFeedTx,
    datetime: new Date().toISOString()
  })
  fs.writeFileSync(filepath, JSON.stringify(base, null, 2));
})();
