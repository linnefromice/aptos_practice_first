import { OracleJob } from "@switchboard-xyz/aptos.js";

const binance = Buffer.from(
  OracleJob.encodeDelimited(
    OracleJob.create({
      tasks: [
        {
          httpTask: {
            url: "https://www.binance.us/api/v3/ticker/price?symbol=USDTUSD",
          },
        },
        {
          jsonParseTask: {
            path: "$.price",
          },
        },
      ],
    })
  ).finish()
);

const ftxus = Buffer.from(
  OracleJob.encodeDelimited(
    OracleJob.create({
      tasks: [
        {
          httpTask: {
            url: "https://ftx.us/api/markets/usdt/usd"
          }
        },
        {
          jsonParseTask: {
            path: "$.result.price"
          }
        }
      ]
    })
  ).finish()
);

const usdtJobs = {
  binance,
  ftxus
}

export { usdtJobs }
