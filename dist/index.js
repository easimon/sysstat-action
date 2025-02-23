/******/ (() => { // webpackBootstrap
/******/ 	var __webpack_modules__ = ({

/***/ 944:
/***/ ((__unused_webpack_module, __webpack_exports__, __nccwpck_require__) => {

"use strict";
__nccwpck_require__.r(__webpack_exports__);
/* harmony export */ __nccwpck_require__.d(__webpack_exports__, {
/* harmony export */   runActionScript: () => (/* binding */ runActionScript),
/* harmony export */   runShellCommand: () => (/* binding */ runShellCommand),
/* harmony export */   transformError: () => (/* binding */ transformError)
/* harmony export */ });
const { spawn } = __nccwpck_require__(317);

function transformError(error) {
  console.error("External process returned error: " + error.message)

  if (Number.isInteger(error.message)) {
    process.exitCode = error.message 
  }
  else {
    process.exitCode = 1
  }
}

async function runActionScript(cmd, args = []) {
  const cmdWithPath = `${__dirname}/${cmd}`  
  return runShellCommand(cmdWithPath, args)
}

async function runShellCommand(cmd, args=[]) {
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

/***/ }),

/***/ 317:
/***/ ((module) => {

"use strict";
module.exports = require("child_process");

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __nccwpck_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		var threw = true;
/******/ 		try {
/******/ 			__webpack_modules__[moduleId](module, module.exports, __nccwpck_require__);
/******/ 			threw = false;
/******/ 		} finally {
/******/ 			if(threw) delete __webpack_module_cache__[moduleId];
/******/ 		}
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/define property getters */
/******/ 	(() => {
/******/ 		// define getter functions for harmony exports
/******/ 		__nccwpck_require__.d = (exports, definition) => {
/******/ 			for(var key in definition) {
/******/ 				if(__nccwpck_require__.o(definition, key) && !__nccwpck_require__.o(exports, key)) {
/******/ 					Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
/******/ 				}
/******/ 			}
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/hasOwnProperty shorthand */
/******/ 	(() => {
/******/ 		__nccwpck_require__.o = (obj, prop) => (Object.prototype.hasOwnProperty.call(obj, prop))
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/make namespace object */
/******/ 	(() => {
/******/ 		// define __esModule on exports
/******/ 		__nccwpck_require__.r = (exports) => {
/******/ 			if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 				Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 			}
/******/ 			Object.defineProperty(exports, '__esModule', { value: true });
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/compat */
/******/ 	
/******/ 	if (typeof __nccwpck_require__ !== 'undefined') __nccwpck_require__.ab = __dirname + "/";
/******/ 	
/************************************************************************/
var __webpack_exports__ = {};
const { runActionScript, transformError } = __nccwpck_require__(944)

async function main() {
  try {
    await runActionScript("../scripts/launch.sh")
  } catch (error) {
    transformError(error)
  }
}

main()

module.exports = __webpack_exports__;
/******/ })()
;