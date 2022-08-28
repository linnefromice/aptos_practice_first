import { AptosAccount, AptosClient } from "aptos";
import { Aggregator } from "./src";

const NODE_URL = "https://fullnode.devnet.aptoslabs.com";

const SWITCHBOARD_DEVNET_ADDRESS =
  "0x348ecb66a5d9edab8d175f647d5e99d6962803da7f5d3d2eb839387aeb118300";

const main = async () => {
  const user = new AptosAccount(
    Uint8Array.from(Buffer.from("a7a24af673ce282acb6cd951dabf95c7aa46ff9d154d75d5aa3022e331c43120", "hex"))
  );
  const client = new AptosClient(NODE_URL);
  const aggregator_address = "0x33072be7d33a72975acea3e0e17bfe672765fe88c1f63fda964a556c3b4d4268"

  const aggregator: Aggregator = new Aggregator(
    client,
    aggregator_address,
    SWITCHBOARD_DEVNET_ADDRESS,
    SWITCHBOARD_DEVNET_ADDRESS
  );

  console.log("await aggregator.openRound(user)")
  await aggregator.openRound(user);
}

main()
  .then(_ => console.log("SUCCESS: open_round"))
  .catch(e => console.log(e))
