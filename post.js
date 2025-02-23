const { DefaultArtifactClient } = require('@actions/artifact')
const { globSync } = require("glob")
const { runActionScript, transformError } = require("./functions")
const { json2csv } = require('json-2-csv')
const { writeFile } = require('fs').promises

const github = require('@actions/github');
const core = require('@actions/core');

async function uploadArtifacts() {
  const root = `${process.env['SAR_BUILDDIR']}/`
  const files = globSync('/**', { root: root, nodir: true })
  const artifact = new DefaultArtifactClient()
  const artifactsuffix = Math.floor(Math.random() * 100)
  console.log(`Files to archive: [${files.join(", ")}]`)
  return artifact.uploadArtifact(
    // todo: this is a hack to circumvent conflicts on re-runs
    `sysstat-report-${artifactsuffix}`,
    files,
    root
  )
}

async function getJobStats() {
  const pageSize = 100
  const token = core.getInput('github_token')
  const octokit = github.getOctokit(token)

  for (let page = 0; ; page++) {
    const requestParams = {
      owner: github.context.repo.owner,
      repo: github.context.repo.repo,
      run_id: github.context.runId,
      per_page: pageSize
    }

    console.info(`Request Params: ${JSON.stringify(requestParams)}`)
    const jobsResult = await octokit.rest.actions.listJobsForWorkflowRun(requestParams)
    if (!jobsResult || !jobsResult.data || !jobsResult.data.jobs) {
      console.warn(`Unexpected listJobs result: ${JSON.stringify(jobsResult)}`)
      break
    }
    const jobs = jobsResult.data.jobs

    const currentJob = jobs.find(job => {
      // TODO: this is not necessarily the correct job
      // unfortunately the job id seems unknown at runtime 
      return job.status === 'in_progress' &&
        job.runner_name === process.env.RUNNER_NAME
    })

    if (currentJob) {
      const now = new Date().toISOString()
      return currentJob.steps.map(step => ({ 
        number: step.number,
        name: step.name,
        started_at: step.started_at || now,
        completed_at: step.completed_at || step.started_at || now,
        conclusion: step.conclusion || "not concluded yet",
        status: step.status,
      }))
    }
    if (jobs.length < pageSize) {
      break
    }
  }
  // current job not found
  console.warn(`Job ${github.context.job} not found, returning empty list.`)
  return []
}

async function createJobStatsData() {
  const builddir = process.env.SAR_BUILDDIR
  const stats = await getJobStats()

  const csv = json2csv(stats)
  await writeFile(`${builddir}/jobstats.csv`, csv)
}

async function post() {
  try {
    await createJobStatsData()
    await runActionScript("../scripts/graph.sh")
    await uploadArtifacts()
  } catch (error) {
    transformError(error)
  } finally {
    await runActionScript("../scripts/cleanup.sh")
  }
}

post()
