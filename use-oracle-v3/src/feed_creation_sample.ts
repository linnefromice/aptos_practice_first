import path from 'path'
import dotenv from 'dotenv'
import { AptosAccount, FaucetClient } from "aptos";
import {
  OracleJob,
} from "@switchboard-xyz/aptos.js";
import { generateAggregatorWithJob } from './feed_creation_core';

// load envs
const envName = process.env.ENV_NAME
if (!envName) throw new Error("[ERROR] Need ENV_NAME")
const ENV_PATH = path.join(process.cwd(), `.${envName}.env`);
const parsed = dotenv.config({ path: ENV_PATH }).parsed
if (!parsed) throw new Error("[ERROR] donot parse from dotenv")
const NODE_URL = parsed["NODE_URL"];
const FAUCET_URL = parsed["FAUCET_URL"];
(async () => {
  const faucetClient = new FaucetClient(NODE_URL, FAUCET_URL);

  // create new user
  let user = new AptosAccount();
  await faucetClient.fundAccount(user.address(), 500000);
  console.log(`User account ${user.address().hex()} created + funded.`);

  await generateAggregatorWithJob({
    user,
    name: "BTC/USD (by binance)",
    metadata: "binance",
    tasks: [
      OracleJob.Task.create({
        httpTask: {
          url: "https://www.binance.us/api/v3/ticker/price?symbol=BTCUSD",
        },
      }),
      OracleJob.Task.create({
        jsonParseTask: {
          path: "$.price",
        },
      }),
    ]
  })
  // await generateAggregatorWithJob({
  //   user,
  //   name: "ETH/USD (by binance)",
  //   metadata: "binance",
  //   tasks: [
  //     OracleJob.Task.create({
  //       httpTask: {
  //         url: "https://www.binance.us/api/v3/ticker/price?symbol=ETHUSD",
  //       },
  //     }),
  //     OracleJob.Task.create({
  //       jsonParseTask: {
  //         path: "$.price",
  //       },
  //     }),
  //   ]
  // })
  // await generateAggregatorWithJob({
  //   user,
  //   name: "USDC/USD (by binance)",
  //   metadata: "binance",
  //   tasks: [
  //     OracleJob.Task.create({
  //       httpTask: {
  //         url: "https://www.binance.us/api/v3/ticker/price?symbol=USDCUSD",
  //       },
  //     }),
  //     OracleJob.Task.create({
  //       jsonParseTask: {
  //         path: "$.price",
  //       },
  //     }),
  //   ]
  // })
  // await generateAggregatorWithJob({
  //   user,
  //   name: "USDT/USD (by binance)",
  //   metadata: "binance",
  //   tasks: [
  //     OracleJob.Task.create({
  //       httpTask: {
  //         url: "https://www.binance.us/api/v3/ticker/price?symbol=USDTUSD",
  //       },
  //     }),
  //     OracleJob.Task.create({
  //       jsonParseTask: {
  //         path: "$.price",
  //       },
  //     }),
  //   ]
  // })
  // await generateAggregatorWithJob({
  //   user,
  //   name: "UNI/USD (by binance)",
  //   metadata: "binance",
  //   tasks: [
  //     OracleJob.Task.create({
  //       httpTask: {
  //         url: "https://www.binance.us/api/v3/ticker/price?symbol=UNIUSD",
  //       },
  //     }),
  //     OracleJob.Task.create({
  //       jsonParseTask: {
  //         path: "$.price",
  //       },
  //     }),
  //   ]
  // })
  // await generateAggregatorWithJob({
  //   user,
  //   name: "ETH/USD (by coingecko)",
  //   metadata: "coingecko",
  //   tasks: [
  //     OracleJob.Task.create({
  //       httpTask: {
  //         url: "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=USD",
  //       },
  //     }),
  //     OracleJob.Task.create({
  //       jsonParseTask: {
  //         path: "$.ethereum.usd",
  //       },
  //     }),
  //   ]
  // })
})();
