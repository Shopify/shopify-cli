"use strict";
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
//# sourceMappingURL=grammar.js.map