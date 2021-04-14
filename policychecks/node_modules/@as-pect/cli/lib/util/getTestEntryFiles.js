"use strict";
var __values = (this && this.__values) || function(o) {
    var s = typeof Symbol === "function" && Symbol.iterator, m = s && o[s], i = 0;
    if (m) return m.call(o);
    if (o && typeof o.length === "number") return {
        next: function () {
            if (o && i >= o.length) o = void 0;
            return { value: o && o[i++], done: !o };
        }
    };
    throw new TypeError(s ? "Object is not iterable." : "Symbol.iterator is not defined.");
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getTestEntryFiles = void 0;
var glob_1 = __importDefault(require("glob"));
/**
 * @ignore
 * This method returns a `Set<string>` of entry files for the compiler to compile.
 *
 * @param {Options} cliOptions - The command line arguments.
 * @param {string[]} include - An array of globs provided by the configuration.
 * @param {RegExp[]} disclude - An array of RegExp provided by the configuration.
 */
function getTestEntryFiles(cliOptions, include, disclude) {
    var e_1, _a, e_2, _b, e_3, _c;
    var testEntryFiles = new Set();
    var fileRegexArg = cliOptions.file;
    var fileRegex = new RegExp(fileRegexArg);
    try {
        // for each pattern to be included
        for (var include_1 = __values(include), include_1_1 = include_1.next(); !include_1_1.done; include_1_1 = include_1.next()) {
            var pattern = include_1_1.value;
            try {
                // push all the resulting files so that each file gets tested individually
                entry: for (var _d = (e_2 = void 0, __values(glob_1.default.sync(pattern))), _e = _d.next(); !_e.done; _e = _d.next()) {
                    var entry = _e.value;
                    try {
                        // test for discludes
                        for (var disclude_1 = (e_3 = void 0, __values(disclude)), disclude_1_1 = disclude_1.next(); !disclude_1_1.done; disclude_1_1 = disclude_1.next()) {
                            var test_1 = disclude_1_1.value;
                            if (test_1.test(entry))
                                continue entry;
                        }
                    }
                    catch (e_3_1) { e_3 = { error: e_3_1 }; }
                    finally {
                        try {
                            if (disclude_1_1 && !disclude_1_1.done && (_c = disclude_1.return)) _c.call(disclude_1);
                        }
                        finally { if (e_3) throw e_3.error; }
                    }
                    // if the fileRegex matches the test, add it to the entry file Set
                    if (fileRegex.test(entry))
                        testEntryFiles.add(entry);
                }
            }
            catch (e_2_1) { e_2 = { error: e_2_1 }; }
            finally {
                try {
                    if (_e && !_e.done && (_b = _d.return)) _b.call(_d);
                }
                finally { if (e_2) throw e_2.error; }
            }
        }
    }
    catch (e_1_1) { e_1 = { error: e_1_1 }; }
    finally {
        try {
            if (include_1_1 && !include_1_1.done && (_a = include_1.return)) _a.call(include_1);
        }
        finally { if (e_1) throw e_1.error; }
    }
    return testEntryFiles;
}
exports.getTestEntryFiles = getTestEntryFiles;
//# sourceMappingURL=getTestEntryFiles.js.map