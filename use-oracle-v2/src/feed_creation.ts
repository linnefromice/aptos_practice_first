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

  // btc/usd
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
  await generateAggregatorWithJob({
    user,
    name: "BTC/USD (by bitstamp)",
    metadata: "bitstamp",
    tasks: [
      OracleJob.Task.create({
        httpTask: {
          url: "https://www.bitstamp.net/api/v2/ticker/btcusd"
        }
      }),
      OracleJob.Task.create({
        medianTask: {
          tasks: [
            { jsonParseTask: { path: "$.ask" } },
            { jsonParseTask: { path: "$.bid" } },
            { jsonParseTask: { path: "$.last" } }
          ]
        }
      })
    ]
  })
  await generateAggregatorWithJob({
    user,
    name: "BTC/USD (by coingecko)",
    metadata: "coingecko",
    tasks: [
      OracleJob.Task.create({
        httpTask: {
          url: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=USD",
        },
      }),
      OracleJob.Task.create({
        jsonParseTask: {
          path: "$.bitcoin.usd",
        },
      }),
    ]
  })
  await generateAggregatorWithJob({
    user,
    name: "BTC/USD (by coinbase)",
    metadata: "coinbase",
    tasks: [
      OracleJob.Task.create({
        websocketTask: {
          url: "wss://ws-feed.pro.coinbase.com",
          subscription: "{\"type\":\"subscribe\",\"product_ids\":[\"BTC-USD\"],\"channels\":[\"ticker\",{\"name\":\"ticker\",\"product_ids\":[\"BTC-USD\"]}]}",
          maxDataAgeSeconds: 15,
          filter: "$[?(@.type == 'ticker' && @.product_id == 'BTC-USD')]"
        }
      }),
      OracleJob.Task.create({ jsonParseTask: { path: "$.price" } })
    ]
  })
  await generateAggregatorWithJob({
    user,
    name: "meaned BTC/USD",
    metadata: "calculated",
    tasks: [
      OracleJob.Task.create({
        meanTask: {
          tasks: [
            // binance
            { httpTask: { url: "https://www.binance.us/api/v3/ticker/price?symbol=BTCUSD" } },
            { jsonParseTask: { path: "$.price" } },
            // coingecho
            { httpTask: { url: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=USD" } },
            { jsonParseTask: { path: "$.bitcoin.usd" } },
            // bitstamp
            { httpTask: { url: "https://www.bitstamp.net/api/v2/ticker/btcusd" } },
            { medianTask: { tasks: [
              { jsonParseTask: { path: "$.ask" } },
              { jsonParseTask: { path: "$.bid" } }
            ] }
            }
          ]
        }
      })
    ]
  })
})();
