const { spawn } = require("child_process");

function run(cmd) {
  const cmdWithPath = `${__dirname}/${cmd}`
  console.log(`Executing ${cmdWithPath}`)
  const subprocess = spawn(cmdWithPath, { stdio: "inherit", shell: true });
  subprocess.on("exit", (exitCode) => {
    process.exitCode = exitCode;
  });
}

run("scripts/graph.sh")
