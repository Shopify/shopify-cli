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
exports.VerboseReporter = void 0;
/**
 * This is the default test reporter class for the `asp` command line application. It will pipe
 * all relevant details about each tests to the `stdout` WriteStream.
 */
var VerboseReporter = /** @class */ (function () {
    function VerboseReporter(_options) {
        this.stdout = null;
        this.stderr = null;
        /** A set of default stringify properties that can be overridden. */
        this.stringifyProperties = {
            maxExpandLevel: 10,
        };
    }
    VerboseReporter.prototype.onEnter = function (_ctx, node) {
        if (node.type === 1 /* Group */) {
            this.onGroupStart(node);
        }
        else {
            this.onTestStart(node.parent, node);
        }
    };
    VerboseReporter.prototype.onExit = function (_ctx, node) {
        if (node.type === 1 /* Group */) {
            this.onGroupFinish(node);
        }
        else {
            this.onTestFinish(node.parent, node);
        }
    };
    /**
     * This method reports a TestGroup is starting.
     *
     * @param {TestNode} group - The started test group.
     */
    VerboseReporter.prototype.onGroupStart = function (group) {
        /* istanbul ignore next */
        if (group.groupTests.length === 0)
            return;
        var chalk = require("chalk");
        /* istanbul ignore next */
        if (group.name)
            this.stdout.write(chalk(templateObject_1 || (templateObject_1 = __makeTemplateObject(["[Describe]: ", "\n\n"], ["[Describe]: ", "\\n\\n"])), group.name));
    };
    /**
     * This method reports a completed TestGroup.
     *
     * @param {TestGroup} group - The finished TestGroup.
     */
    VerboseReporter.prototype.onGroupFinish = function (group) {
        var e_1, _a, e_2, _b;
        if (group.groupTests.length === 0)
            return;
        try {
            for (var _c = __values(group.groupTodos), _d = _c.next(); !_d.done; _d = _c.next()) {
                var todo = _d.value;
                this.onTodo(group, todo);
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
            for (var _e = __values(group.logs), _f = _e.next(); !_f.done; _f = _e.next()) {
                var logValue = _f.value;
                this.onLog(logValue);
            }
        }
        catch (e_2_1) { e_2 = { error: e_2_1 }; }
        finally {
            try {
                if (_f && !_f.done && (_b = _e.return)) _b.call(_e);
            }
            finally { if (e_2) throw e_2.error; }
        }
        this.stdout.write("\n");
    };
    /** This method is a stub for onTestStart(). */
    VerboseReporter.prototype.onTestStart = function (_group, _test) { };
    /**
     * This method reports a completed test.
     *
     * @param {TestNode} _group - The TestGroup that the TestResult belongs to.
     * @param {TestNode} test - The finished TestResult
     */
    VerboseReporter.prototype.onTestFinish = function (_group, test) {
        var e_3, _a;
        var chalk = require("chalk");
        if (test.pass) {
            /* istanbul ignore next */
            var rtraceDelta = 
            /* istanbul ignore next */
            test.rtraceDelta === 0
                /* istanbul ignore next */
                ? ""
                /* istanbul ignore next */
                : chalk(templateObject_2 || (templateObject_2 = __makeTemplateObject([" {yellow RTrace: ", "}"], [" {yellow RTrace: "
                    /* istanbul ignore next */
                    ,
                    "}"])), 
                /* istanbul ignore next */
                (test.rtraceDelta > 0
                    ? /* istanbul ignore next */
                        "+"
                    : /* istanbul ignore next */
                        "") + test.rtraceDelta.toString());
            this.stdout.write(test.negated
                ? chalk(templateObject_3 || (templateObject_3 = __makeTemplateObject([" {green  [Throws]: \u2714} ", "", "\n"], [" {green  [Throws]: \u2714} ", "", "\\n"])), test.name, rtraceDelta) : chalk(templateObject_4 || (templateObject_4 = __makeTemplateObject([" {green [Success]: \u2714} ", "", "\n"], [" {green [Success]: \u2714} ", "", "\\n"])), test.name, rtraceDelta));
        }
        else {
            this.stdout.write(chalk(templateObject_5 || (templateObject_5 = __makeTemplateObject(["    {red [Fail]: \u2716} ", "\n"], ["    {red [Fail]: \u2716} ", "\\n"])), test.name));
            var stringifyIndent2 = Object.assign({}, this.stringifyProperties, {
                indent: 2,
            });
            if (!test.negated) {
                if (test.actual) {
                    this.stdout.write("  [Actual]: " + test
                        .actual.stringify(stringifyIndent2)
                        .trimLeft() + "\n");
                }
                if (test.expected) {
                    var expected = test.expected;
                    this.stdout.write("[Expected]: " + (expected.negated ? "Not " : "") + expected
                        .stringify(stringifyIndent2)
                        .trimLeft() + "\n");
                }
            }
            /* istanbul ignore next */
            if (test.message) {
                this.stdout.write(chalk(templateObject_6 || (templateObject_6 = __makeTemplateObject([" [Message]: {yellow ", "}\n"], [" [Message]: {yellow ", "}\\n"])), test.message));
            }
            /* istanbul ignore next */
            if (test.stackTrace) {
                this.stdout.write("   [Stack]: " + test.stackTrace.split("\n").join("\n        ") + "\n");
            }
        }
        try {
            /** Log the values to stdout if this was a typical test. */
            for (var _b = __values(test.logs), _c = _b.next(); !_c.done; _c = _b.next()) {
                var logValue = _c.value;
                this.onLog(logValue);
            }
        }
        catch (e_3_1) { e_3 = { error: e_3_1 }; }
        finally {
            try {
                if (_c && !_c.done && (_a = _b.return)) _a.call(_b);
            }
            finally { if (e_3) throw e_3.error; }
        }
    };
    /**
     * This method reports that a TestContext has finished.
     *
     * @param {TestContext} suite - The finished test context.
     */
    VerboseReporter.prototype.onFinish = function (suite) {
        var e_4, _a, e_5, _b, e_6, _c, e_7, _d, e_8, _e;
        /* istanbul ignore next */
        if (suite.rootNode.children.length === 0)
            return;
        var chalk = require("chalk");
        var result = suite.pass ? chalk(templateObject_7 || (templateObject_7 = __makeTemplateObject(["{green \u2714 PASS}"], ["{green \u2714 PASS}"]))) : chalk(templateObject_8 || (templateObject_8 = __makeTemplateObject(["{red \u2716 FAIL}"], ["{red \u2716 FAIL}"])));
        var count = suite.testCount;
        var successCount = suite.testPassCount;
        var failText = count === successCount
            ? "0 fail"
            : chalk(templateObject_9 || (templateObject_9 = __makeTemplateObject(["{red ", " fail}"], ["{red ", " fail}"])), (count - successCount).toString());
        try {
            // There are currently no warnings provided by the as-pect testing suite
            /* istanbul ignore next */
            for (var _f = __values(suite.warnings), _g = _f.next(); !_g.done; _g = _f.next()) {
                var warning = _g.value;
                /* istanbul ignore next */
                this.stdout.write(chalk(templateObject_10 || (templateObject_10 = __makeTemplateObject(["\n{yellow  [Warning]}: ", " -> ", "\n"], ["\\n{yellow  [Warning]}: ", " -> ", "\\n"])), warning.type, warning.message));
                /* istanbul ignore next */
                var stack = warning.stackTrace.trim();
                /* istanbul ignore next */
                if (stack) {
                    /* istanbul ignore next */
                    this.stdout.write(chalk(templateObject_11 || (templateObject_11 = __makeTemplateObject(["{yellow    [Stack]}: {yellow ", "}\n"], ["{yellow    [Stack]}: {yellow ",
                        "}\\n"])), stack
                        .split("\n")
                        .join("\n      ")));
                }
                /* istanbul ignore next */
                this.stdout.write("\n");
            }
        }
        catch (e_4_1) { e_4 = { error: e_4_1 }; }
        finally {
            try {
                if (_g && !_g.done && (_a = _f.return)) _a.call(_f);
            }
            finally { if (e_4) throw e_4.error; }
        }
        try {
            for (var _h = __values(suite.errors), _j = _h.next(); !_j.done; _j = _h.next()) {
                var error = _j.value;
                this.stdout.write(chalk(templateObject_12 || (templateObject_12 = __makeTemplateObject(["\n{red    [Error]}: ", " ", ""], ["\\n{red    [Error]}: ", " ", ""])), error.type, error.message));
                this.stdout.write(chalk(templateObject_13 || (templateObject_13 = __makeTemplateObject(["\n{red    [Stack]}: {yellow ", "}\n"], ["\\n{red    [Stack]}: {yellow ",
                    "}\\n"])), error.stackTrace
                    .split("\n")
                    .join("\n           ")));
            }
        }
        catch (e_5_1) { e_5 = { error: e_5_1 }; }
        finally {
            try {
                if (_j && !_j.done && (_b = _h.return)) _b.call(_h);
            }
            finally { if (e_5) throw e_5.error; }
        }
        var diff = suite.snapshotDiff.results;
        var addedCount = 0;
        var removedCount = 0;
        var differentCount = 0;
        var totalCount = 0;
        try {
            for (var _k = __values(diff.entries()), _l = _k.next(); !_l.done; _l = _k.next()) {
                var _m = __read(_l.value, 2), name_1 = _m[0], result_1 = _m[1];
                if (result_1.type !== 0 /* NoChange */) {
                    this.stdout.write(chalk(templateObject_14 || (templateObject_14 = __makeTemplateObject(["{red [Snapshot]}: ", "\n"], ["{red [Snapshot]}: ", "\\n"])), name_1));
                    var changes = result_1.changes;
                    try {
                        for (var changes_1 = (e_7 = void 0, __values(changes)), changes_1_1 = changes_1.next(); !changes_1_1.done; changes_1_1 = changes_1.next()) {
                            var change = changes_1_1.value;
                            var lines = change.value.split("\n");
                            try {
                                for (var lines_1 = (e_8 = void 0, __values(lines)), lines_1_1 = lines_1.next(); !lines_1_1.done; lines_1_1 = lines_1.next()) {
                                    var line = lines_1_1.value;
                                    if (!line.trim())
                                        continue;
                                    if (change.added) {
                                        this.stdout.write(chalk(templateObject_15 || (templateObject_15 = __makeTemplateObject(["{green + ", "}\n"], ["{green + ", "}\\n"])), line));
                                    }
                                    else if (change.removed) {
                                        this.stdout.write(chalk(templateObject_16 || (templateObject_16 = __makeTemplateObject(["{red - ", "}\n"], ["{red - ", "}\\n"])), line));
                                    }
                                    else {
                                        this.stdout.write(chalk(templateObject_17 || (templateObject_17 = __makeTemplateObject(["  ", "\n"], ["  ", "\\n"])), line));
                                    }
                                }
                            }
                            catch (e_8_1) { e_8 = { error: e_8_1 }; }
                            finally {
                                try {
                                    if (lines_1_1 && !lines_1_1.done && (_e = lines_1.return)) _e.call(lines_1);
                                }
                                finally { if (e_8) throw e_8.error; }
                            }
                        }
                    }
                    catch (e_7_1) { e_7 = { error: e_7_1 }; }
                    finally {
                        try {
                            if (changes_1_1 && !changes_1_1.done && (_d = changes_1.return)) _d.call(changes_1);
                        }
                        finally { if (e_7) throw e_7.error; }
                    }
                    this.stdout.write("\n");
                }
                totalCount += 1;
                addedCount += result_1.type === 1 /* Added */ ? 1 : 0;
                removedCount += result_1.type === 2 /* Removed */ ? 1 : 0;
                differentCount +=
                    result_1.type === 3 /* Different */ ? 1 : 0;
            }
        }
        catch (e_6_1) { e_6 = { error: e_6_1 }; }
        finally {
            try {
                if (_l && !_l.done && (_c = _k.return)) _c.call(_k);
            }
            finally { if (e_6) throw e_6.error; }
        }
        this.stdout.write(chalk(templateObject_18 || (templateObject_18 = __makeTemplateObject(["    [File]: ", "\n  [Groups]: {green ", " pass}, ", " total\n  [Result]: ", "\n[Snapshot]: ", " total, ", " added, ", " removed, ", " different\n [Summary]: {green ", " pass},  ", ", ", " total\n    [Time]: ", "ms\n\n", "\n\n"], ["    [File]: ", "\n  [Groups]: {green ", " pass}, ", " total\n  [Result]: ", "\n[Snapshot]: ", " total, ", " added, ", " removed, ", " different\n [Summary]: {green ", " pass},  ", ", ",
            " total\n    [Time]: ", "ms\n\n", "\\n\\n"])), suite.fileName, suite.groupCount, suite.groupCount, result, totalCount, addedCount, removedCount, differentCount, suite.testPassCount, failText, suite.testCount, suite.rootNode.deltaT, "~".repeat(80)));
    };
    /**
     * This method reports a todo to stdout.
     *
     * @param {TestGroup} _group - The test group the todo belongs to.
     * @param {string} todo - The todo.
     */
    /* istanbul ignore next */
    VerboseReporter.prototype.onTodo = function (_group, todo) {
        /* istanbul ignore next */
        var chalk = require("chalk");
        /* istanbul ignore next */
        this.stdout.write(chalk(templateObject_19 || (templateObject_19 = __makeTemplateObject(["    {yellow [Todo]:} ", "\n"], ["    {yellow [Todo]:} ", "\\n"])), todo));
    };
    /**
     * A custom logger function for the default reporter that writes the log values using `console.log()`
     *
     * @param {ReflectedValue} logValue - A value to be logged to the console
     */
    VerboseReporter.prototype.onLog = function (logValue) {
        var chalk = require("chalk");
        var indent12 = Object.assign({}, this.stringifyProperties, {
            indent: 12,
        });
        var output = logValue.stringify(indent12).trimLeft();
        this.stdout.write(chalk(templateObject_20 || (templateObject_20 = __makeTemplateObject(["     {yellow [Log]:} ", "\n"], ["     {yellow [Log]:} ", "\\n"])), output));
        var stack = logValue.stack.trim();
        /* istanbul ignore next */
        if (stack) {
            this.stdout.write(chalk(templateObject_21 || (templateObject_21 = __makeTemplateObject(["   {yellow [Stack]:} ", "\n"], ["   {yellow [Stack]:} ",
                "\\n"])), stack
                .trimLeft()
                .split("\n")
                .join("\n        ")));
        }
    };
    return VerboseReporter;
}());
exports.VerboseReporter = VerboseReporter;
var templateObject_1, templateObject_2, templateObject_3, templateObject_4, templateObject_5, templateObject_6, templateObject_7, templateObject_8, templateObject_9, templateObject_10, templateObject_11, templateObject_12, templateObject_13, templateObject_14, templateObject_15, templateObject_16, templateObject_17, templateObject_18, templateObject_19, templateObject_20, templateObject_21;
//# sourceMappingURL=VerboseReporter.js.map