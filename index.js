const { runActionScript, transformError } = require("./functions")

async function main() {
  try {
    await runActionScript("../scripts/launch.sh")
  } catch (error) {
    transformError(error)
  }
}

main()
