const { spawn } = require("child_process");

export function transformError(error) {
  console.error("External process returned error: " + error.message)

  if (Number.isInteger(error.message)) {
    process.exitCode = error.message 
  }
  else {
    process.exitCode = 1
  }
}

export async function runActionScript(cmd, args = []) {
  const cmdWithPath = `${__dirname}/${cmd}`  
  return runShellCommand(cmdWithPath, args)
}

export async function runShellCommand(cmd, args=[]) {
  return new Promise((resolve, reject) => {
    console.log(`Executing ${cmd} ${args.join(" ")}`)

    const subprocess = spawn(cmd, args, { stdio: "inherit", shell: true });
    subprocess.on("exit", (exitCode) => {
      if (exitCode == 0) {
        resolve(exitCode)
      } else {
        reject(new Error(exitCode))
      }
    });
  })
}