import { runActionScript, transformError } from "./functions";

async function main() {
  try {
    await runActionScript("../scripts/launch.sh");
  } catch (error) {
    transformError(error);
  }
}

main();
