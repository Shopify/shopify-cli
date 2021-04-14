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
exports.SnapshotDiff = void 0;
var SnapshotDiffResult_1 = require("./SnapshotDiffResult");
var diff_1 = require("diff");
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
//# sourceMappingURL=SnapshotDiff.js.map