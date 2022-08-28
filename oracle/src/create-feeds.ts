import { Buffer } from "buffer";
import { AptosClient, AptosAccount, FaucetClient, HexString } from "aptos";
import {
  Aggregator,
  Job,
  Lease,
  AptosEvent,
  EventCallback,
  Crank,
} from "sbv2-aptos";
export { OracleJob } from "@switchboard-xyz/switchboard-v2/src/index";

const NODE_URL = "https://fullnode.devnet.aptoslabs.com";
const FAUCET_URL = "https://faucet.devnet.aptoslabs.com";

const SWITCHBOARD_DEVNET_ADDRESS =
  "0x348ecb66a5d9edab8d175f647d5e99d6962803da7f5d3d2eb839387aeb118300";

const SWITCHBOARD_QUEUE_ADDRESS =
  "0x348ecb66a5d9edab8d175f647d5e99d6962803da7f5d3d2eb839387aeb118300";

const SWITCHBOARD_CRANK_ADDRESS =
  "0x348ecb66a5d9edab8d175f647d5e99d6962803da7f5d3d2eb839387aeb118300";

const SWITCHBOARD_STATE_ADDRESS =
  "0x348ecb66a5d9edab8d175f647d5e99d6962803da7f5d3d2eb839387aeb118300";

const client = new AptosClient(NODE_URL);
const faucetClient = new FaucetClient(NODE_URL, FAUCET_URL);

const main = async () => {
  // create new user
  let user = new AptosAccount();
  await faucetClient.fundAccount(user.address(), 5000);
  console.log(`User account ${user.address().hex()} created + funded.`);

  // create and fund accounts to assign an aggregator and job to
  const aggregator_acct = new AptosAccount();
  const job_acct = new AptosAccount();
  await faucetClient.fundAccount(aggregator_acct.address(), 50000);
  await faucetClient.fundAccount(job_acct.address(), 5000);

  // initialize the aggregator
  const [aggregator, aggregatorTxHash] = await Aggregator.init(
    client,
    aggregator_acct,
    {
      authority: user.address(),
      queueAddress: SWITCHBOARD_QUEUE_ADDRESS,
      batchSize: 1,
      minJobResults: 1,
      minOracleResults: 1,
      minUpdateDelaySeconds: 5, // update every 5 seconds
      startAfter: 0,
      varianceThreshold: 0,
      varianceThresholdScale: 0,
      forceReportPeriod: 0,
      expiration: 0,
      coinType: "0x1::aptos_coin::AptosCoin",
    },
    SWITCHBOARD_DEVNET_ADDRESS,
    SWITCHBOARD_STATE_ADDRESS
  );

  console.log(`Aggregator: ${aggregator.address}, tx: ${aggregatorTxHash}`);

  // Make Job data for btc price
  // https://docs.switchboard.xyz/api/tasks
  const serializedJob = Buffer.from(
    OracleJob.encodeDelimited(
      OracleJob.create({
        tasks: [
          {
            httpTask: {
              url: "https://www.binance.us/api/v3/ticker/price?symbol=BTCUSD",
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

  // initialize job -- our data fetching definition
  const [job, jobTxHash] = await Job.init(
    client,
    job_acct,
    {
      name: "BTC/USD",
      metadata: "binance",
      authority: user.address().hex(),
      data: serializedJob.toString("hex"),
    },
    SWITCHBOARD_DEVNET_ADDRESS,
    SWITCHBOARD_STATE_ADDRESS
  );

  console.log(`Job created ${job.address}, hash: ${jobTxHash}`);

  // add btc usd to our aggregator
  const addJobTxHash = await aggregator.addJob(user, {
    job: job.address,
  });

  console.log(`Aggregator add job tx: ${addJobTxHash}`);

  const [lease, leaseTxHash] = await Lease.init(
    client,
    aggregator_acct,
    {
      queueAddress: SWITCHBOARD_QUEUE_ADDRESS,
      withdrawAuthority: user.address().hex(),
      initialAmount: 1000, // when this drains completely, the aggregator is booted from the crank
      coinType: "0x1::aptos_coin::AptosCoin",
    },
    SWITCHBOARD_DEVNET_ADDRESS,
    SWITCHBOARD_STATE_ADDRESS
  );

  console.log(lease, leaseTxHash);

  // Enable automatic updates
  const crank = new Crank(
    client,
    SWITCHBOARD_CRANK_ADDRESS,
    SWITCHBOARD_DEVNET_ADDRESS,
    SWITCHBOARD_STATE_ADDRESS
  );

  // Pushing to the crank enables automatic updates
  await crank.push(user, {
    aggregatorAddress: aggregator_acct.address().hex(),
  });

  // Manually trigger an update
  await aggregator.openRound(user);
}

main().then(() => console.log("SUCCESS")).catch(_ => console.log("FAILURE"))