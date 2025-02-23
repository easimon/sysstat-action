const { runActionScript } = require("./run")

runActionScript("../scripts/launch.sh")
  .catch((error) => { 
    if (Number.isInteger(error.message)) {
      process.exitCode = error.message 
    }
    else {
      console.error(error.message)
      process.exitCode = 1
    }
  })
