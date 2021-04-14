"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.toCamelCase = exports.capitalize = void 0;
/**
 * @ignore
 * Capitalize a word.
 *
 * @param {string} word - The word to be capitalized.
 */
function capitalize(word) {
    return word[0].toLocaleUpperCase() + word.substring(1);
}
exports.capitalize = capitalize;
/**
 * @ignore
 * CamelCase a single string. Usually used with `dash-cased` words.
 *
 * @param {string} str - The string to be camelCased.
 * @param {string} from - The string seperator.
 */
function toCamelCase(str, from) {
    if (from === void 0) { from = "-"; }
    return str
        .split(from)
        .map(function (word, idx) { return (idx > 0 ? capitalize(word) : word); })
        .join("");
}
exports.toCamelCase = toCamelCase;
//# sourceMappingURL=strings.js.map