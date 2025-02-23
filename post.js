const { runActionScript, runShellCommand } = require("./run")
const { DefaultArtifactClient } = require('@actions/artifact')
const { globSync } = require("glob")

runActionScript("../scripts/graph.sh")
  .then(() => { 
    runShellCommand("ls", ["-al", "build/"])
  })
  .then(() => { 
    runShellCommand("ls", ["-al", "build/sar-report"])
  })
  .then(() => { 
    const artifact = new DefaultArtifactClient()
    const files = globSync('/sar-report/**', { root: './build/', nodir: true})
    console.log(`Files to archive: [${files.join(", ")}]`)
    artifact.uploadArtifact(
      'sysstat-report',
      files,
      './build/'
    )
  })
  .catch((error) => { 
    if (Number.isInteger(error.message)) {
      process.exitCode = error.message 
    }
    else {
      console.error(error.message)
      process.exitCode = 1
    }
  })
