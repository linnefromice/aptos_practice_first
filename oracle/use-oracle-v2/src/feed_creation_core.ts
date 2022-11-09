import path from 'path'
import dotenv from 'dotenv'
import { Buffer } from "buffer";
import { AptosClient, AptosAccount, FaucetClient } from "aptos";
import {
  LeaseAccount,
  OracleJob,
  createFeed,
} from "@switchboard-xyz/aptos.js";
import Big from "big.js";

// load envs
const envName = process.env.ENV_NAME
if (!envName) throw new Error("[ERROR] Need ENV_NAME")
const ENV_PATH = path.join(process.cwd(), `.${envName}.env`);
const parsed = dotenv.config({ path: ENV_PATH }).parsed
if (!parsed) throw new Error("[ERROR] donot parse from dotenv")
const NODE_URL = parsed["NODE_URL"];
const FAUCET_URL = parsed["FAUCET_URL"];
const SWITCHBOARD_ADDRESS = parsed["SWITCHBOARD_ADDRESS"]
const SWITCHBOARD_QUEUE_ADDRESS = parsed["SWITCHBOARD_QUEUE_ADDRESS"]
const SWITCHBOARD_CRANK_ADDRESS = parsed["SWITCHBOARD_CRANK_ADDRESS"]
export const generateAggregatorWithJob = async ({
  user, name, metadata, tasks
}: {
  user: AptosAccount,
  name: string,
  metadata: string,
  tasks: OracleJob.Task[]
}) => {
  const client = new AptosClient(NODE_URL);
  const faucetClient = new FaucetClient(NODE_URL, FAUCET_URL);

  const aggregator_acct = new AptosAccount();
  await faucetClient.fundAccount(aggregator_acct.address(), 50000);

  const serializedJob = Buffer.from(
    OracleJob.encodeDelimited(
      OracleJob.create({
        tasks,
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
      crankAddress: SWITCHBOARD_CRANK_ADDRESS,
      initialLoadAmount: 1000,
      jobs: [
        {
          name: name,
          metadata: metadata,
          authority: user.address().hex(),
          data: serializedJob.toString("base64"),
          weight: 1,
        },
      ],
    },
    SWITCHBOARD_ADDRESS
  );

  console.log(`name: ${name}`)
  console.log(`metadata: ${metadata}`)
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
       SWITCHBOARD_ADDRESS
     ).loadData(SWITCHBOARD_QUEUE_ADDRESS)
   );
   console.log("Load aggregator jobs data", JSON.stringify(await aggregator.loadJobs()));

   console.log(`aggregator holder: ${user.address()}`)
   console.log(`aggregator: ${aggregator.address}`)
   console.log({ name, metadata })
   console.dir(tasks, { depth: null });
}
