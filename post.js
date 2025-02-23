const { runActionScript, transformError } = require("./functions")
const { DefaultArtifactClient } = require('@actions/artifact')
const { globSync } = require("glob")

async function uploadArtifacts() {
  const root = `${process.env['SAR_BUILDDIR']}/`
  const files = globSync('/**', { root: root, nodir: true })
  const artifact = new DefaultArtifactClient()
  console.log(`Files to archive: [${files.join(", ")}]`)
  return artifact.uploadArtifact(
    'sysstat-report',
    files,
    root
  )
}

async function post() {
  try {
    await runActionScript("../scripts/graph.sh")
    await uploadArtifacts()
  } catch (error) {
    transformError(error)
  } finally {
    await runActionScript("../scripts/cleanup.sh")
  }
}

post()
