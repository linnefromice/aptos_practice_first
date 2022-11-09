import path from 'path'
import dotenv from 'dotenv'
import { AptosClient } from "aptos";

// load envs
const envName = process.env.ENV_NAME
if (!envName) throw new Error("[ERROR] Need ENV_NAME")
const ENV_PATH = path.join(process.cwd(), `.${envName}.env`);
const parsed = dotenv.config({ path: ENV_PATH }).parsed
if (!parsed) throw new Error("[ERROR] donot parse from dotenv")

const NODE_URL = parsed["NODE_URL"];
const SWITCHBOARD_ADDRESS = parsed["SWITCHBOARD_ADDRESS"];

const logResource = async (client: AptosClient, resourceName: string) => {
  const resource = await client.getAccountResource(
    SWITCHBOARD_ADDRESS,
    resourceName
  )
  console.log(`#### ${resourceName}`)
  console.log(JSON.stringify(resource, null, 2))
}

(async () => {
  const client = new AptosClient(NODE_URL)

  // Crank
  await logResource(client, `${SWITCHBOARD_ADDRESS}::crank::Crank`)

  // State
  await logResource(client, `${SWITCHBOARD_ADDRESS}::switchboard::State`)
})();
