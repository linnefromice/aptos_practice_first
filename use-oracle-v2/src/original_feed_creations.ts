import dotenv from 'dotenv'
const parsed = dotenv.config().parsed
if (!parsed) throw new Error("not parsed from dotenv")
const NODE_URL = parsed["NODE_URL"];
const FAUCET_URL = parsed["FAUCET_URL"];
const SWITCHBOARD_DEVNET_ADDRESS = parsed["SWITCHBOARD_DEVNET_ADDRESS"]
const SWITCHBOARD_QUEUE_ADDRESS = parsed["SWITCHBOARD_QUEUE_ADDRESS"]
const SWITCHBOARD_CRANK_ADDRESS = parsed["SWITCHBOARD_CRANK_ADDRESS"]

import { Buffer } from "buffer";
import { AptosClient, AptosAccount, FaucetClient } from "aptos";
import {
  LeaseAccount,
  OracleJob,
  createFeed,
} from "@switchboard-xyz/aptos.js";
import Big from "big.js";

// example
// url: "https://www.binance.us/api/v3/ticker/price?symbol=BTCUSD"
// path: "$.price"
// name: "BTC/USD"
// metadata: "binance"
const generateAggregatorWithJob = async ({
  user, url, path, name, metadata
}: {
  user: AptosAccount,
  url: string,
  path: string,
  name: string,
  metadata: string
}) => {
  const client = new AptosClient(NODE_URL);
  const faucetClient = new FaucetClient(NODE_URL, FAUCET_URL);

  const aggregator_acct = new AptosAccount();
  await faucetClient.fundAccount(aggregator_acct.address(), 50000);

  const serializedJob = Buffer.from(
    OracleJob.encodeDelimited(
      OracleJob.create({
        tasks: [
          {
            httpTask: {
              url: url,
            },
          },
          {
            jsonParseTask: {
              path: path,
            },
          },
        ],
      })
    ).finish()
  );

  const [aggregator, createFeedTx] = await createFeed(
    client,
    user,
    {
      authority: user.address(),
      queueAddress: SWITCHBOARD_QUEUE_ADDRESS,
      batchSize: 1,
      minJobResults: 1,
      minOracleResults: 1,
      minUpdateDelaySeconds: 5,
      varianceThreshold: new Big(0),
      coinType: "0x1::aptos_coin::AptosCoin",
      crank: SWITCHBOARD_CRANK_ADDRESS,
      initialLoadAmount: 1000,
      jobs: [
        {
          name: name,
          metadata: metadata,
          authority: user.address().hex(),
          data: serializedJob.toString(),
          weight: 1,
        },
      ],
    },
    SWITCHBOARD_DEVNET_ADDRESS
  );

  console.log(
    `Created Aggregator and Lease resources at account address ${aggregator.address}. Tx hash ${createFeedTx}`
  );

  /**
   * Log Data Objects
   */
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

const main = async () => {
  const faucetClient = new FaucetClient(NODE_URL, FAUCET_URL);

  // create new user
  let user = new AptosAccount();
  await faucetClient.fundAccount(user.address(), 500000);
  console.log(`User account ${user.address().hex()} created + funded.`);

  await generateAggregatorWithJob({
    user,
    url: "https://www.binance.us/api/v3/ticker/price?symbol=BTCUSD",
    path: "$.price",
    name: "BTC/USD (by binance)",
    metadata: "binance"
  })
  // await generateAggregatorWithJob({
  //   user,
  //   url: "https://www.binance.us/api/v3/ticker/price?symbol=ETHUSD",
  //   path: "$.price",
  //   name: "ETH/USD (by binance)",
  //   metadata: "binance"
  // })
  // await generateAggregatorWithJob({
  //   user,
  //   url: "https://www.binance.us/api/v3/ticker/price?symbol=USDCUSD",
  //   path: "$.price",
  //   name: "USDC/USD (by binance)",
  //   metadata: "binance"
  // })
  // await generateAggregatorWithJob({
  //   user,
  //   url: "https://www.binance.us/api/v3/ticker/price?symbol=USDTUSD",
  //   path: "$.price",
  //   name: "USDT/USD (by binance)",
  //   metadata: "binance"
  // })
  // await generateAggregatorWithJob({
  //   user,
  //   url: "https://www.binance.us/api/v3/ticker/price?symbol=UNIUSD",
  //   path: "$.price",
  //   name: "UNI/USD (by binance)",
  //   metadata: "binance"
  // })
  // await generateAggregatorWithJob({
  //   user,
  //   url: "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=USD",
  //   path: "$.ethereum.usd",
  //   name: "ETH/USD (by coingecko)",
  //   metadata: "coingecko"
  // })
}

main().then(_ => console.log("SUCCESS")).catch(_ => console.log("FAILURE"))
