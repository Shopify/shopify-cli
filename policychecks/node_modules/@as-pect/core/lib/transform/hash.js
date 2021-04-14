"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.djb2Hash = void 0;
/**
 * A simple djb2hash that returns a hash of a given string. See http://www.cse.yorku.ca/~oz/hash.html
 * for implementation details.
 *
 * @param {string} str - The string to be hashed
 * @returns {number} The hash of the string
 */
function djb2Hash(str) {
    var points = Array.from(str);
    var h = 5381;
    for (var p = 0; p < points.length; p++)
        // h = h * 33 + c;
        h = (h << 5) + h + points[p].codePointAt(0);
    return h;
}
exports.djb2Hash = djb2Hash;
//# sourceMappingURL=hash.js.map