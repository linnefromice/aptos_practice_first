import { OracleJob } from "@switchboard-xyz/aptos.js";

const binance = Buffer.from(
  OracleJob.encodeDelimited(
    OracleJob.create({
      tasks: [
        {
          httpTask: {
            url: "https://www.binance.com/api/v3/ticker/price?symbol=USDCUSDT",
          },
        },
        {
          jsonParseTask: {
            path: "$.price",
          },
        },
        {
          multiplyTask: {
            aggregatorPubkey: "ETAaeeuQBwsh9mC2gCov9WdhJENZuffRMXY2HgjCcSL9",
          },
        },
      ],
    })
  ).finish()
);

const bitstamp = Buffer.from(
  OracleJob.encodeDelimited(
    OracleJob.create({
      tasks: [
        {
          httpTask: {
            url: "https://www.bitstamp.net/api/v2/ticker/usdcusd",
          },
        },
        {
          medianTask: {
            tasks: [
              {
                jsonParseTask: {
                  path: "$.ask",
                },
              },
              {
                jsonParseTask: {
                  path: "$.bid",
                },
              },
              {
                jsonParseTask: {
                  path: "$.last",
                },
              },
            ],
          },
        },
      ],
    })
  ).finish()
);

const bittrex = Buffer.from(
  OracleJob.encodeDelimited(
    OracleJob.create({
      tasks: [
        {
          httpTask: {
            url: "https://api.bittrex.com/v3/markets/usdc-usd/ticker",
          },
        },
        {
          medianTask: {
            tasks: [
              {
                jsonParseTask: {
                  path: "$.askRate",
                },
              },
              {
                jsonParseTask: {
                  path: "$.bidRate",
                },
              },
              {
                jsonParseTask: {
                  path: "$.lastTradeRate",
                },
              },
            ],
          },
        },
      ],
    })
  ).finish()
);

const kraken = Buffer.from(
  OracleJob.encodeDelimited(
    OracleJob.create({
      tasks: [
        {
          httpTask: {
            url: "https://api.kraken.com/0/public/Ticker?pair=USDCUSD",
          },
        },
        {
          medianTask: {
            tasks: [
              {
                jsonParseTask: {
                  path: "$.result.USDCUSD.a[0]",
                },
              },
              {
                jsonParseTask: {
                  path: "$.result.USDCUSD.b[0]",
                },
              },
              {
                jsonParseTask: {
                  path: "$.result.USDCUSD.c[0]",
                },
              },
            ],
          },
        },
      ],
    })
  ).finish()
);

const usdcJobs = {
  binance,
  bitstamp,
  bittrex,
  kraken
}

export { usdcJobs }
