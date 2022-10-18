import path from 'path'
import dotenv from 'dotenv'

const envName = process.env.ENV_NAME
if (!envName) throw new Error("[ERROR] Need ENV_NAME")
const ENV_PATH = path.join(process.cwd(), `.${envName}.env`);
const parsed = dotenv.config({ path: ENV_PATH }).parsed
if (!parsed) throw new Error("[ERROR] donot parse from dotenv")

const NODE_URL = parsed["NODE_URL"];
const FAUCET_URL = parsed["FAUCET_URL"];
const SWITCHBOARD_ADDRESS = parsed["SWITCHBOARD_ADDRESS"];

export {
  NODE_URL,
  FAUCET_URL,
  SWITCHBOARD_ADDRESS
}
