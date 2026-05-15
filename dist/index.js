/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	/* webpack/runtime/compat */
/******/ 	
/******/ 	if (typeof __nccwpck_require__ !== 'undefined') __nccwpck_require__.ab = __dirname + "/";
/******/ 	
/************************************************************************/
var __webpack_exports__ = {};

;// CONCATENATED MODULE: external "child_process"
const external_child_process_namespaceObject = require("child_process");
;// CONCATENATED MODULE: ./functions.js


function transformError(error) {
  console.error("External process returned error: " + error.message);

  if (Number.isInteger(error.message)) {
    process.exitCode = error.message;
  } else {
    process.exitCode = 1;
  }
}

async function runActionScript(cmd, args = []) {
  const cmdWithPath = `${__dirname}/${cmd}`;
  return runShellCommand(cmdWithPath, args);
}

async function runShellCommand(cmd, args = []) {
  return new Promise((resolve, reject) => {
    console.log(`Executing ${cmd} ${args.join(" ")}`);

    const subprocess = (0,external_child_process_namespaceObject.spawn)(cmd, args, { stdio: "inherit", shell: true });
    subprocess.on("exit", (exitCode) => {
      if (exitCode == 0) {
        resolve(exitCode);
      } else {
        reject(new Error(exitCode));
      }
    });
  });
}

;// CONCATENATED MODULE: ./index.js


async function main() {
  try {
    await runActionScript("../scripts/launch.sh");
  } catch (error) {
    transformError(error);
  }
}

main();

module.exports = __webpack_exports__;
/******/ })()
;