"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.removeFile = void 0;
var fs_1 = require("fs");
/**
 * @ignore
 * This method promisifies the fs.writeFile function call, and is compatible with node 10.
 *
 * @param {string} file - The file location to write to.
 */
function removeFile(file) {
    return new Promise(function (resolve, reject) {
        fs_1.unlink(file, function (err) {
            if (err)
                reject(err);
            else
                resolve();
        });
    });
}
exports.removeFile = removeFile;
//# sourceMappingURL=removeFile.js.map