"use strict";
var __makeTemplateObject = (this && this.__makeTemplateObject) || function (cooked, raw) {
    if (Object.defineProperty) { Object.defineProperty(cooked, "raw", { value: raw }); } else { cooked.raw = raw; }
    return cooked;
};
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
exports.SummaryReporter = void 0;
/**
 * This test reporter should be used when logging output and test validation only needs happen on
 * the group level. It is useful for CI builds and also reduces IO output to speed up the testing
 * process.
 */
var SummaryReporter = /** @class */ (function () {
    function SummaryReporter(options) {
        this.enableLogging = true;
        this.stdout = null;
        this.stderr = null;
        /* istanbul ignore next */
        if (options) {
            // can be "false" from cli
            /* istanbul ignore next */
            if (!options.enableLogging ||
                /* istanbul ignore next */ options.enableLogging === "false")
                /* istanbul ignore next */
                this.enableLogging = false;
        }
    }
    SummaryReporter.prototype.onEnter = function (_ctx, _node) { };
    SummaryReporter.prototype.onExit = function (_ctx, _node) { };
    /* istanbul ignore next */
    SummaryReporter.prototype.onStart = function (_ctx) { };
    /* istanbul ignore next */
    SummaryReporter.prototype.onGroupStart = function (_node) { };
    /* istanbul ignore next */
    SummaryReporter.prototype.onGroupFinish = function (_node) { };
    /* istanbul ignore next */
    SummaryReporter.prototype.onTestStart = function (_group, _test) { };
    /* istanbul ignore next */
    SummaryReporter.prototype.onTestFinish = function (_group, _test) { };
    /* istanbul ignore next */
    SummaryReporter.prototype.onTodo = function () { };
    /**
     * This method reports a test context is finished running.
     *
     * @param {TestContext} suite - The finished test suite.
     */
    SummaryReporter.prototype.onFinish = function (suite) {
        var e_1, _a, e_2, _b, e_3, _c, e_4, _d, e_5, _e, e_6, _f, e_7, _g, e_8, _h, e_9, _j, e_10, _k, e_11, _l, e_12, _m, e_13, _o;
        var chalk = require("chalk");
        var testGroups = suite.rootNode.childGroups;
        // TODO: Figure out a better way to flatten this array.
        var todos = [].concat.apply([], testGroups.map(function (e) { return e.groupTodos; })).length;
        var total = suite.testCount;
        var passCount = suite.testPassCount;
        var deltaT = suite.rootNode.deltaT;
        /** Report if all the groups passed. */
        if (suite.pass) {
            this.stdout.write(chalk(templateObject_1 || (templateObject_1 = __makeTemplateObject(["{green.bold \u2714 ", "} Pass: ", " / ", " Todo: ", " Time: ", "ms\n"], ["{green.bold \u2714 ",
                "} Pass: ", " / ", " Todo: ", " Time: ", "ms\\n"])), suite.fileName, passCount.toString(), total.toString(), todos.toString(), deltaT.toString()));
            /** If logging is enabled, log all the values. */
            /* istanbul ignore next */
            if (this.enableLogging) {
                try {
                    for (var testGroups_1 = __values(testGroups), testGroups_1_1 = testGroups_1.next(); !testGroups_1_1.done; testGroups_1_1 = testGroups_1.next()) {
                        var group = testGroups_1_1.value;
                        try {
                            for (var _p = (e_2 = void 0, __values(group.logs)), _q = _p.next(); !_q.done; _q = _p.next()) {
                                var log = _q.value;
                                this.onLog(log);
                            }
                        }
                        catch (e_2_1) { e_2 = { error: e_2_1 }; }
                        finally {
                            try {
                                if (_q && !_q.done && (_b = _p.return)) _b.call(_p);
                            }
                            finally { if (e_2) throw e_2.error; }
                        }
                        try {
                            for (var _r = (e_3 = void 0, __values(group.groupTests)), _s = _r.next(); !_s.done; _s = _r.next()) {
                                var test_1 = _s.value;
                                try {
                                    for (var _t = (e_4 = void 0, __values(test_1.logs)), _u = _t.next(); !_u.done; _u = _t.next()) {
                                        var log = _u.value;
                                        this.onLog(log);
                                    }
                                }
                                catch (e_4_1) { e_4 = { error: e_4_1 }; }
                                finally {
                                    try {
                                        if (_u && !_u.done && (_d = _t.return)) _d.call(_t);
                                    }
                                    finally { if (e_4) throw e_4.error; }
                                }
                            }
                        }
                        catch (e_3_1) { e_3 = { error: e_3_1 }; }
                        finally {
                            try {
                                if (_s && !_s.done && (_c = _r.return)) _c.call(_r);
                            }
                            finally { if (e_3) throw e_3.error; }
                        }
                    }
                }
                catch (e_1_1) { e_1 = { error: e_1_1 }; }
                finally {
                    try {
                        if (testGroups_1_1 && !testGroups_1_1.done && (_a = testGroups_1.return)) _a.call(testGroups_1);
                    }
                    finally { if (e_1) throw e_1.error; }
                }
            }
        }
        else {
            this.stdout.write(chalk(templateObject_2 || (templateObject_2 = __makeTemplateObject(["{red.bold \u274C ", "} Pass: ", " / ", " Todo: ", " Time: ", "ms\n"], ["{red.bold \u274C ",
                "} Pass: ", " / ", " Todo: ", " Time: ", "ms\\n"])), suite.fileName, passCount.toString(), total.toString(), todos.toString(), deltaT.toString()));
            try {
                /** If the group failed, report that the group failed. */
                for (var testGroups_2 = __values(testGroups), testGroups_2_1 = testGroups_2.next(); !testGroups_2_1.done; testGroups_2_1 = testGroups_2.next()) {
                    var group = testGroups_2_1.value;
                    /* istanbul ignore next */
                    if (group.pass)
                        continue;
                    this.stdout.write(chalk(templateObject_3 || (templateObject_3 = __makeTemplateObject(["  {red Failed:} ", "\n"], ["  {red Failed:} ", "\\n"])), group.name));
                    /** Display the reason if there is one. */
                    // if (group.reason)
                    //   this.stdout!.write(chalk`    {yellow Reason:} ${group.reason}`);
                    /** Log each log item in the failed group. */
                    /* istanbul ignore next */
                    if (this.enableLogging) {
                        try {
                            for (var _v = (e_6 = void 0, __values(group.logs)), _w = _v.next(); !_w.done; _w = _v.next()) {
                                var log = _w.value;
                                this.onLog(log);
                            }
                        }
                        catch (e_6_1) { e_6 = { error: e_6_1 }; }
                        finally {
                            try {
                                if (_w && !_w.done && (_f = _v.return)) _f.call(_v);
                            }
                            finally { if (e_6) throw e_6.error; }
                        }
                    }
                    try {
                        inner: for (var _x = (e_7 = void 0, __values(group.groupTests)), _y = _x.next(); !_y.done; _y = _x.next()) {
                            var test_2 = _y.value;
                            if (test_2.pass)
                                continue inner;
                            this.stdout.write(chalk(templateObject_4 || (templateObject_4 = __makeTemplateObject(["    {red.bold \u274C ", "} - ", "\n"], ["    {red.bold \u274C ", "} - ", "\\n"])), test_2.name, test_2.message));
                            if (test_2.actual !== null)
                                this.stdout.write(chalk(templateObject_5 || (templateObject_5 = __makeTemplateObject(["      {red.bold [Actual]  :} ", "\n"], ["      {red.bold [Actual]  :} ",
                                    "\\n"])), test_2.actual
                                    .stringify({ indent: 2 })
                                    .trimLeft()));
                            if (test_2.expected !== null) {
                                var expected = test_2.expected;
                                this.stdout.write(chalk(templateObject_6 || (templateObject_6 = __makeTemplateObject(["      {green.bold [Expected]:} ", "", "\n"], ["      {green.bold [Expected]:} ",
                                    "", "\\n"])), expected.negated ? "Not " : "", expected.stringify({ indent: 2 }).trimLeft()));
                            }
                            /* istanbul ignore next */
                            if (this.enableLogging) {
                                try {
                                    for (var _z = (e_8 = void 0, __values(test_2.logs)), _0 = _z.next(); !_0.done; _0 = _z.next()) {
                                        var log = _0.value;
                                        this.onLog(log);
                                    }
                                }
                                catch (e_8_1) { e_8 = { error: e_8_1 }; }
                                finally {
                                    try {
                                        if (_0 && !_0.done && (_h = _z.return)) _h.call(_z);
                                    }
                                    finally { if (e_8) throw e_8.error; }
                                }
                            }
                        }
                    }
                    catch (e_7_1) { e_7 = { error: e_7_1 }; }
                    finally {
                        try {
                            if (_y && !_y.done && (_g = _x.return)) _g.call(_x);
                        }
                        finally { if (e_7) throw e_7.error; }
                    }
                }
            }
            catch (e_5_1) { e_5 = { error: e_5_1 }; }
            finally {
                try {
                    if (testGroups_2_1 && !testGroups_2_1.done && (_e = testGroups_2.return)) _e.call(testGroups_2);
                }
                finally { if (e_5) throw e_5.error; }
            }
        }
        try {
            // There are no warnings left in the as-pect test suite software
            for (var _1 = __values(suite.warnings), _2 = _1.next(); !_2.done; _2 = _1.next()) {
                var warning = _2.value;
                /* istanbul ignore next */
                this.stdout.write(chalk(templateObject_7 || (templateObject_7 = __makeTemplateObject(["{yellow  [Warning]}: ", " -> ", "\n"], ["{yellow  [Warning]}: ", " -> ", "\\n"])), warning.type, warning.message));
                /* istanbul ignore next */
                var stack = warning.stackTrace.trim();
                /* istanbul ignore next */
                if (stack) {
                    this.stdout.write(chalk(templateObject_8 || (templateObject_8 = __makeTemplateObject(["{yellow    [Stack]}: {yellow ", "}\n"], ["{yellow    [Stack]}: {yellow ",
                        "}\\n"])), stack
                        .split("\n")
                        .join("\n      ")));
                }
                /* istanbul ignore next */
                this.stdout.write("\n");
            }
        }
        catch (e_9_1) { e_9 = { error: e_9_1 }; }
        finally {
            try {
                if (_2 && !_2.done && (_j = _1.return)) _j.call(_1);
            }
            finally { if (e_9) throw e_9.error; }
        }
        try {
            for (var _3 = __values(suite.errors), _4 = _3.next(); !_4.done; _4 = _3.next()) {
                var error = _4.value;
                this.stdout.write(chalk(templateObject_9 || (templateObject_9 = __makeTemplateObject(["{red    [Error]}: ", " ", "\n"], ["{red    [Error]}: ", " ", "\\n"])), error.type, error.message));
                this.stdout.write(chalk(templateObject_10 || (templateObject_10 = __makeTemplateObject(["{red    [Stack]}: {yellow ", "}\n\n"], ["{red    [Stack]}: {yellow ",
                    "}\\n\\n"])), error.stackTrace
                    .split("\n")
                    .join("\n           ")));
            }
        }
        catch (e_10_1) { e_10 = { error: e_10_1 }; }
        finally {
            try {
                if (_4 && !_4.done && (_k = _3.return)) _k.call(_3);
            }
            finally { if (e_10) throw e_10.error; }
        }
        var diff = suite.snapshotDiff.results;
        try {
            for (var _5 = __values(diff.entries()), _6 = _5.next(); !_6.done; _6 = _5.next()) {
                var _7 = __read(_6.value, 2), name_1 = _7[0], result = _7[1];
                if (result.type !== 0 /* NoChange */) {
                    this.stdout.write(chalk(templateObject_11 || (templateObject_11 = __makeTemplateObject(["{red [Snapshot]}: ", "\n"], ["{red [Snapshot]}: ", "\\n"])), name_1));
                    var changes = result.changes;
                    try {
                        for (var changes_1 = (e_12 = void 0, __values(changes)), changes_1_1 = changes_1.next(); !changes_1_1.done; changes_1_1 = changes_1.next()) {
                            var change = changes_1_1.value;
                            var lines = change.value.split("\n");
                            try {
                                for (var lines_1 = (e_13 = void 0, __values(lines)), lines_1_1 = lines_1.next(); !lines_1_1.done; lines_1_1 = lines_1.next()) {
                                    var line = lines_1_1.value;
                                    if (!line.trim())
                                        continue;
                                    if (change.added) {
                                        this.stdout.write(chalk(templateObject_12 || (templateObject_12 = __makeTemplateObject(["{green + ", "}\n"], ["{green + ", "}\\n"])), line));
                                    }
                                    else if (change.removed) {
                                        this.stdout.write(chalk(templateObject_13 || (templateObject_13 = __makeTemplateObject(["{red - ", "}\n"], ["{red - ", "}\\n"])), line));
                                    }
                                    else {
                                        this.stdout.write(chalk(templateObject_14 || (templateObject_14 = __makeTemplateObject(["  ", "\n"], ["  ", "\\n"])), line));
                                    }
                                }
                            }
                            catch (e_13_1) { e_13 = { error: e_13_1 }; }
                            finally {
                                try {
                                    if (lines_1_1 && !lines_1_1.done && (_o = lines_1.return)) _o.call(lines_1);
                                }
                                finally { if (e_13) throw e_13.error; }
                            }
                        }
                    }
                    catch (e_12_1) { e_12 = { error: e_12_1 }; }
                    finally {
                        try {
                            if (changes_1_1 && !changes_1_1.done && (_m = changes_1.return)) _m.call(changes_1);
                        }
                        finally { if (e_12) throw e_12.error; }
                    }
                    this.stdout.write("\n");
                }
            }
        }
        catch (e_11_1) { e_11 = { error: e_11_1 }; }
        finally {
            try {
                if (_6 && !_6.done && (_l = _5.return)) _l.call(_5);
            }
            finally { if (e_11) throw e_11.error; }
        }
    };
    /**
     * A custom logger function for the default reporter that writes the log values using `console.log()`
     *
     * @param {ReflectedValue} logValue - A value to be logged to the console
     */
    SummaryReporter.prototype.onLog = function (logValue) {
        var chalk = require("chalk");
        var output = logValue.stringify({ indent: 12 }).trimLeft();
        this.stdout.write(chalk(templateObject_15 || (templateObject_15 = __makeTemplateObject(["     {yellow [Log]:} ", "\n"], ["     {yellow [Log]:} ", "\\n"])), output));
    };
    return SummaryReporter;
}());
exports.SummaryReporter = SummaryReporter;
var templateObject_1, templateObject_2, templateObject_3, templateObject_4, templateObject_5, templateObject_6, templateObject_7, templateObject_8, templateObject_9, templateObject_10, templateObject_11, templateObject_12, templateObject_13, templateObject_14, templateObject_15;
//# sourceMappingURL=SummaryReporter.js.map