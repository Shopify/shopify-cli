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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.Snapshot = void 0;
var SnapshotDiff_1 = require("./SnapshotDiff");
var nearley_1 = require("nearley");
var grammar_1 = __importDefault(require("./parser/grammar"));
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
//# sourceMappingURL=Snapshot.js.map