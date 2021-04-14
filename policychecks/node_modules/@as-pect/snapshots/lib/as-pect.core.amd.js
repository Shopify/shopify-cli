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
var __read = (this && this.__read) || function (o, n) {
    var m = typeof Symbol === "function" && o[Symbol.iterator];
    if (!m) return o;
    var i = m.call(o), r, ar = [], e;
    try {
        while ((n === void 0 || n-- > 0) && !(r = i.next()).done) ar.push(r.value);
    }
    catch (error) { e = { error: error }; }
    finally {
        try {
            if (r && !r.done && (m = i["return"])) m.call(i);
        }
        finally { if (e) throw e.error; }
    }
    return ar;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
define("SnapshotDiffResult", ["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.SnapshotDiffResult = void 0;
    var SnapshotDiffResult = /** @class */ (function () {
        function SnapshotDiffResult() {
            this.type = 0 /* NoChange */;
            this.left = null;
            this.right = null;
            this.changes = [];
        }
        return SnapshotDiffResult;
    }());
    exports.SnapshotDiffResult = SnapshotDiffResult;
});
define("SnapshotDiff", ["require", "exports", "SnapshotDiffResult", "diff"], function (require, exports, SnapshotDiffResult_1, diff_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.SnapshotDiff = void 0;
    var SnapshotDiff = /** @class */ (function () {
        function SnapshotDiff(left, right) {
            this.left = left;
            this.right = right;
            this.results = new Map();
            this.calculateDiff();
        }
        SnapshotDiff.prototype.calculateDiff = function () {
            var e_1, _a, e_2, _b;
            var left = this.left.values;
            var right = this.right.values;
            try {
                // loop over the items on the left side
                for (var _c = __values(left.entries()), _d = _c.next(); !_d.done; _d = _c.next()) {
                    var _e = __read(_d.value, 2), key = _e[0], value = _e[1];
                    // the snapshot exists, NoChange or Different
                    if (right.has(key)) {
                        var rightValue = right.get(key);
                        var lines = diff_1.diffLines(rightValue, value);
                        var result = new SnapshotDiffResult_1.SnapshotDiffResult();
                        result.left = value;
                        result.right = rightValue;
                        result.type =
                            value === rightValue
                                ? 0 /* NoChange */
                                : 3 /* Different */;
                        result.changes = lines;
                        this.results.set(key, result);
                    }
                    else {
                        // it was added
                        var result = new SnapshotDiffResult_1.SnapshotDiffResult();
                        result.left = value;
                        result.right = null;
                        result.type = 1 /* Added */;
                        result.changes = diff_1.diffLines("", value);
                        this.results.set(key, result);
                    }
                }
            }
            catch (e_1_1) { e_1 = { error: e_1_1 }; }
            finally {
                try {
                    if (_d && !_d.done && (_a = _c.return)) _a.call(_c);
                }
                finally { if (e_1) throw e_1.error; }
            }
            try {
                // loop over the items on the right side
                for (var _f = __values(right.entries()), _g = _f.next(); !_g.done; _g = _f.next()) {
                    var _h = __read(_g.value, 2), key = _h[0], value = _h[1];
                    if (!left.has(key)) {
                        // it was removed
                        var result = new SnapshotDiffResult_1.SnapshotDiffResult();
                        result.left = null;
                        result.right = value;
                        result.changes = diff_1.diffLines(value, "");
                        result.type = 2 /* Removed */;
                        this.results.set(key, result);
                    }
                }
            }
            catch (e_2_1) { e_2 = { error: e_2_1 }; }
            finally {
                try {
                    if (_g && !_g.done && (_b = _f.return)) _b.call(_f);
                }
                finally { if (e_2) throw e_2.error; }
            }
        };
        return SnapshotDiff;
    }());
    exports.SnapshotDiff = SnapshotDiff;
});
define("parser/grammar", ["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    // Generated automatically by nearley, version 2.20.1
    // http://github.com/Hardmath123/nearley
    // Bypasses TS6133. Allow declared but unused functions.
    // @ts-ignore
    function id(d) { return d[0]; }
    ;
    ;
    ;
    ;
    var grammar = {
        Lexer: undefined,
        ParserRules: [
            { "name": "start$ebnf$1$subexpression$1", "symbols": ["lines", "_"] },
            { "name": "start$ebnf$1", "symbols": ["start$ebnf$1$subexpression$1"], "postprocess": id },
            { "name": "start$ebnf$1", "symbols": [], "postprocess": function () { return null; } },
            { "name": "start", "symbols": ["_", "start$ebnf$1"], "postprocess": function (d) {
                    var results = d[1];
                    var map = new Map();
                    if (results) {
                        for (var i = 0; i < results[0].length; i++) {
                            var _a = __read(results[0][i], 2), key = _a[0], value = _a[1];
                            if (map.has(key))
                                throw new Error("Invalid snapshot.");
                            map.set(key, value);
                        }
                    }
                    return map;
                } },
            { "name": "lines$ebnf$1", "symbols": [] },
            { "name": "lines$ebnf$1$subexpression$1", "symbols": ["_", "line"] },
            { "name": "lines$ebnf$1", "symbols": ["lines$ebnf$1", "lines$ebnf$1$subexpression$1"], "postprocess": function (d) { return d[0].concat([d[1]]); } },
            { "name": "lines", "symbols": ["line", "lines$ebnf$1"], "postprocess": function (d) { return [d[0]].concat(d[1].map(function (e) { return e[1]; })); } },
            { "name": "line$string$1", "symbols": [{ "literal": "e" }, { "literal": "x" }, { "literal": "p" }, { "literal": "o" }, { "literal": "r" }, { "literal": "t" }, { "literal": "s" }, { "literal": "[" }], "postprocess": function (d) { return d.join(''); } },
            { "name": "line", "symbols": ["line$string$1", "_", "string", "_", { "literal": "]" }, "_", { "literal": "=" }, "_", "string", "_", { "literal": ";" }], "postprocess": function (d) { return [d[2], d[8]]; } },
            { "name": "_$ebnf$1", "symbols": [] },
            { "name": "_$ebnf$1", "symbols": ["_$ebnf$1", /[ \t\r\n]/], "postprocess": function (d) { return d[0].concat([d[1]]); } },
            { "name": "_", "symbols": ["_$ebnf$1"] },
            { "name": "string$ebnf$1", "symbols": [] },
            { "name": "string$ebnf$1$subexpression$1", "symbols": ["escaped"] },
            { "name": "string$ebnf$1$subexpression$1", "symbols": [/[^`]/] },
            { "name": "string$ebnf$1", "symbols": ["string$ebnf$1", "string$ebnf$1$subexpression$1"], "postprocess": function (d) { return d[0].concat([d[1]]); } },
            { "name": "string", "symbols": [{ "literal": "`" }, "string$ebnf$1", { "literal": "`" }], "postprocess": function (d) { return d[1].join(""); } },
            { "name": "escaped$string$1", "symbols": [{ "literal": "\\" }, { "literal": "`" }], "postprocess": function (d) { return d.join(''); } },
            { "name": "escaped", "symbols": ["escaped$string$1"], "postprocess": function () { return "`"; } }
        ],
        ParserStart: "start",
    };
    exports.default = grammar;
});
define("Snapshot", ["require", "exports", "SnapshotDiff", "nearley", "parser/grammar"], function (require, exports, SnapshotDiff_1, nearley_1, grammar_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.Snapshot = void 0;
    grammar_1 = __importDefault(grammar_1);
    var tick = /`/g;
    var Snapshot = /** @class */ (function () {
        function Snapshot() {
            this.values = new Map();
        }
        Snapshot.parse = function (input) {
            var parser = new nearley_1.Parser(nearley_1.Grammar.fromCompiled(grammar_1.default));
            parser.feed(input.replace(/\r/g, ""));
            if (parser.results.length !== 1)
                throw new Error("Ambiguous grammar or parsing.");
            var result = new Snapshot();
            result.values = parser.results[0];
            return result;
        };
        Snapshot.from = function (input) {
            var snapshot = new Snapshot();
            snapshot.values = input;
            return snapshot;
        };
        Snapshot.prototype.add = function (key, value) {
            var i = 0;
            while (true) {
                var snapshotKey = key + "[" + i + "]";
                if (!this.values.has(snapshotKey)) {
                    this.values.set(snapshotKey, value);
                    return this;
                }
                i++;
            }
        };
        Snapshot.prototype.diff = function (other) {
            return new SnapshotDiff_1.SnapshotDiff(this, other);
        };
        Snapshot.prototype.stringify = function () {
            return (Array.from(this.values.entries())
                .map(function (_a) {
                var _b = __read(_a, 2), key = _b[0], value = _b[1];
                return "exports[`" + key.replace(tick, "\\`") + "`] = `" + value.replace(tick, "\\`") + "`;";
            })
                .join("\n\n") + "\n");
        };
        return Snapshot;
    }());
    exports.Snapshot = Snapshot;
});
define("index", ["require", "exports", "Snapshot", "SnapshotDiff", "SnapshotDiffResult"], function (require, exports, Snapshot_1, SnapshotDiff_2, SnapshotDiffResult_2) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    __exportStar(Snapshot_1, exports);
    __exportStar(SnapshotDiff_2, exports);
    __exportStar(SnapshotDiffResult_2, exports);
});
//# sourceMappingURL=as-pect.core.amd.js.map