"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var fs_1 = require("fs");
var path_1 = require("path");
var worker_threads_1 = require("worker_threads");
var writeFile_1 = require("../util/writeFile");
/**
 * @ignore
 *
 * This variable holds the AssemblyScript compiler.
 */
var asc = require(path_1.join(worker_threads_1.workerData.assemblyScriptFolder, "dist", "asc"));
/**
 * @ignore
 *
 * This variable holds the fileMap for the compiler.
 */
var fileMap = new Map();
/**
 * @ignore
 *
 * This variable holds the folderMap for the compiler.
 */
var folderMap = new Map();
/**
 * @ignore
 *
 * Run a worklet command.
 * @param {ICommand} command - The command to run. (This is the compiler worklet command.)
 */
function run(command) {
    var binary;
    var filePromises = [];
    asc.main(command.props.args, {
        stdout: process.stdout,
        stderr: process.stderr,
        listFiles: function (dirname, baseDir) {
            var folder = path_1.join(baseDir, dirname);
            if (folderMap.has(folder)) {
                return folderMap.get(folder);
            }
            try {
                var results = fs_1.readdirSync(folder).filter(function (file) {
                    return /^(?!.*\.d\.ts$).*\.ts$/.test(file);
                });
                folderMap.set(folder, results);
                return results;
            }
            catch (e) {
                return [];
            }
        },
        readFile: function (filename, baseDir) {
            var fileName = path_1.join(baseDir, filename);
            if (fileMap.has(fileName)) {
                return fileMap.get(fileName);
            }
            try {
                var contents = fs_1.readFileSync(fileName, { encoding: "utf8" });
                fileMap.set(fileName, contents);
                return contents;
            }
            catch (e) {
                return null;
            }
        },
        writeFile: function (name, contents) {
            var ext = path_1.extname(name);
            // get the wasm file
            if (ext === ".wasm") {
                binary = contents;
                if (!command.props.outputBinary)
                    return;
            }
            var file = command.props.file;
            var outfileName = path_1.join(path_1.dirname(file), path_1.basename(file, path_1.extname(file)) + ext);
            filePromises.push(writeFile_1.writeFile(outfileName, contents));
        },
    }, function (error) {
        return Promise.all(filePromises)
            .then(function () {
            worker_threads_1.parentPort.postMessage({
                type: "Result",
                props: {
                    error: error
                        ? {
                            message: error.message,
                            stack: error.stack,
                            name: error.name,
                        }
                        : null,
                    binary: binary,
                    file: command.props.file,
                },
            }, binary ? [binary.buffer] : []);
        })
            .catch(function (error) {
            worker_threads_1.parentPort.postMessage({
                type: "Error",
                props: {
                    error: error
                        ? {
                            message: error.message,
                            stack: error.stack,
                            name: error.name,
                        }
                        : null,
                },
            });
        });
    });
}
worker_threads_1.parentPort.on("message", run);
//# sourceMappingURL=compiler.js.map