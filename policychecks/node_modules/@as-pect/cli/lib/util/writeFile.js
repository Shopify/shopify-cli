"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.writeFile = void 0;
var fs_1 = require("fs");
/**
 * @ignore
 * This method promisifies the fs.writeFile function call, and is compatible with node 10.
 *
 * @param {string} file - The file location to write to.
 * @param {Uint8Array} contents - The file contents to write to the disk.
 */
function writeFile(file, contents) {
    return new Promise(function (resolve, reject) {
        fs_1.writeFile(file, contents, function (err) {
            if (err)
                reject(err);
            else
                resolve();
        });
    });
}
exports.writeFile = writeFile;
//# sourceMappingURL=writeFile.js.map