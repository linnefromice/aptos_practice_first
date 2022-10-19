import { OracleJob } from "@switchboard-xyz/aptos.js";

const binance = Buffer.from(
  OracleJob.encodeDelimited(
    OracleJob.create({
      tasks: [
        {
          httpTask: {
            url: "https://www.binance.us/api/v3/ticker/price?symbol=ETHUSDT",
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
const ethJobs = {
  binance,
}

export { ethJobs }
