"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.timeDifference = void 0;
/**
 * @ignore
 * This method calculates the start and end time difference, rounding off to the nearest thousandth
 * of a millisecond.
 *
 * @param {number} end - The end time.
 * @param {number} start - The start time.
 * @returns {number} - The difference of the two times rounded to the nearest three decimal places.
 */
var timeDifference = function (end, start) {
    return Math.round((end - start) * 1000) / 1000;
};
exports.timeDifference = timeDifference;
//# sourceMappingURL=timeDifference.js.map