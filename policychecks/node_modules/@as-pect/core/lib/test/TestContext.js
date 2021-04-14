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
var __spread = (this && this.__spread) || function () {
    for (var ar = [], i = 0; i < arguments.length; i++) ar = ar.concat(__read(arguments[i]));
    return ar;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TestContext = void 0;
var rTrace_1 = require("../util/rTrace");
// @ts-ignore: Constructor is new Long(low, high, signed);
var long_1 = __importDefault(require("long"));
var wasmTools_1 = require("../util/wasmTools");
var ReflectedValue_1 = require("../util/ReflectedValue");
var TestNode_1 = require("./TestNode");
var perf_hooks_1 = require("perf_hooks");
var snapshots_1 = require("@as-pect/snapshots");
var id = function (a) { return a; };
var stringifyOptions = {
    classNameFormatter: id,
    indent: 0,
    keywordFormatter: id,
    maxExpandLevel: Infinity,
    maxLineLength: Infinity,
    maxPropertyCount: Infinity,
    numberFormatter: id,
    stringFormatter: id,
    tab: 2,
};
/**
 * This function is a filter for stack trace lines.
 *
 * @param {string} input - The stack trace line.
 */
var wasmFilter = function (input) { return /wasm/i.test(input); };
/** This class is responsible for collecting and running all the tests in a test binary. */
var TestContext = /** @class */ (function () {
    function TestContext(props) {
        var _this = this;
        /** The web assembly module if it was set. */
        this.wasm = null;
        /** The name section for function name evaluation. */
        this.nameSection = null;
        /** The top level node for this test suite. */
        this.rootNode = new TestNode_1.TestNode();
        /** The current working node that is collecting logs and callback pointers. */
        this.targetNode = this.rootNode;
        /** The name of the AssemblyScript test file. */
        this.fileName = "";
        /** An indicator to see if the TestSuite passed. */
        this.pass = false;
        /** The place where stack traces are stored when a function pointer errors.  */
        this.stack = "";
        /** The place where the abort() messages are stored. */
        this.message = "";
        /** The collected actual value. */
        this.actual = null;
        /** The collected expected value. */
        this.expected = null;
        /** Filter the tests by regex. */
        this.testRegex = new RegExp("");
        /** Filter the groups by regex. */
        this.groupRegex = new RegExp("");
        /** The test count. */
        this.testCount = 0;
        /** The number of tests that ran. */
        this.testRunCount = 0;
        /** The number of passing tests count. */
        this.testPassCount = 0;
        /** The group count. */
        this.groupCount = 0;
        /** The number of groups that ran. */
        this.groupRunCount = 0;
        /** The number of passing groups count. */
        this.groupPassCount = 0;
        /** The number of todos. */
        this.todoCount = 0;
        /** A collection of all the generated namespaces for shapshot purposes. */
        this.namespaces = new Set();
        /** The wasi instance associated with this module */
        this.wasi = null;
        /** The WebAssembly.Instance object. */
        this.instance = null;
        /** The module instance. */
        // private instance: WebAssembly.Instance | null = null;
        /**
         * A collection of reflected values used to help cache and aid in the creation
         * of nested reflected values.
         */
        this.reflectedValueCache = [];
        /** A collection of errors. */
        this.errors = [];
        /** A collection of warnings. */
        this.warnings = [];
        /** A collection of collected snapshots. */
        this.snapshots = new snapshots_1.Snapshot();
        /** The resulting snapshot diff. */
        this.snapshotDiff = null;
        /** A map of strings that can be cached because they are static. */
        this.cachedStrings = new Map();
        "";
        this.rtrace = new rTrace_1.Rtrace({
            /* istanbul ignore next */
            getMemory: function () {
                /* istanbul ignore next */
                return _this.wasm.memory;
            },
            /* istanbul ignore next */
            onerror: function (err, info) {
                /* istanbul ignore next */
                return _this.onRtraceError(err, info);
            },
            /* istanbul ignore next */
            oninfo: function (msg) {
                /* istanbul ignore next */
                return _this.onRtraceInfo(msg);
            }
        });
        /* istanbul ignore next */
        if (props.fileName)
            this.fileName = props.fileName;
        /* istanbul ignore next */
        if (props.testRegex)
            this.testRegex = props.testRegex;
        /* istanbul ignore next */
        if (props.groupRegex)
            this.groupRegex = props.groupRegex;
        if (props.binary)
            this.nameSection = new wasmTools_1.NameSection(props.binary);
        if (props.wasi)
            this.wasi = props.wasi;
        this.expectedSnapshots = props.snapshots ? props.snapshots : new snapshots_1.Snapshot();
        this.reporter = props.reporter;
        /* istanbul ignore next */
        if (typeof props.reporter.onEnter !== "function") {
            /* istanbul ignore next */
            this.pushError({
                message: "Invalid reporter callback: onEnter is not a function",
                stackTrace: "",
                type: "TestContext Initialization",
            });
        }
        /* istanbul ignore next */
        if (typeof props.reporter.onExit !== "function") {
            /* istanbul ignore next */
            this.pushError({
                message: "Invalid reporter callback: onExit is not a function",
                stackTrace: "",
                type: "TestContext Initialization",
            });
        }
        /* istanbul ignore next */
        if (typeof props.reporter.onFinish !== "function") {
            /* istanbul ignore next */
            this.pushError({
                message: "Invalid reporter callback: onFinish is not a function",
                stackTrace: "",
                type: "TestContext Initialization",
            });
        }
        /** The root node is a group. */
        this.rootNode.type = 1 /* Group */;
    }
    /**
     * Track an rtrace error. This method should be bound and passed to the RTrace options.
     *
     * @param err - The error.
     * @param block - BlockInfo
     */
    // @ts-ignore
    TestContext.prototype.onRtraceError = function (err, block) {
        var _a;
        /* istanbul ignore next */
        this.pushError({
            message: "Block: " + block.ptr + " => " + err.message,
            stackTrace: 
            /* istanbul ignore next */
            ((_a = err.stack) === null || _a === void 0 ? void 0 : _a.split("\n").filter(wasmFilter).join("\n")) ||
                "No stack trace provided.",
            type: "rtrace",
        });
    };
    TestContext.prototype.onRtraceInfo = function (_message) {
        // this.pushWarning({
        //   message,
        //   stackTrace: this.getLogStackTrace(),
        //   type: "rtrace",
        // });
    };
    /**
     * Call this method to start the `__main()` method provided by the `as-pect` exports to start the
     * process of test collection and evaluation.
     */
    TestContext.prototype.run = function (wasm) {
        /* istanbul ignore next */
        this.wasm = wasm.exports || wasm;
        this.instance = wasm.instance;
        // start by visiting the root node
        this.visit(this.rootNode);
        // calculate snapshot diff
        var snapshotDiff = this.snapshots.diff(this.expectedSnapshots);
        // determine if this test suite passed
        var snapshotsPass = Array.from(snapshotDiff.results.values()).reduce(function (result, value) {
            if (result) {
                return (
                // @ts-ignore
                value.type === 1 /* Added */ ||
                    // @ts-ignore
                    value.type === 0 /* NoChange */);
            }
            return false;
        }, true);
        // store the diff results
        this.snapshotDiff = snapshotDiff;
        // determine if this test suite passed or failed
        this.pass = Boolean(snapshotsPass) && this.rootNode.pass;
        // finish the report
        this.reporter.onFinish(this);
    };
    /** Visit a node and evaluate it's children. */
    TestContext.prototype.visit = function (node) {
        // validate this node will run
        if (node !== this.rootNode) {
            var regexTester = node.type === 1 /* Group */ ? this.groupRegex : this.testRegex;
            if (!regexTester.test(node.name))
                return;
        }
        // this node is being tested for sure
        node.ran = true;
        if (node.type === 1 /* Group */) {
            this.groupRunCount += 1;
        }
        else {
            this.testRunCount += 1;
        }
        // set the start timer for this node
        node.start = perf_hooks_1.performance.now();
        // set the rtraceStart value
        node.rtraceStart = this.rtrace.blocks.size;
        // set the target node for collection
        this.targetNode = node;
        // in the case of a throws() test
        if (node.negated) {
            var success = this.tryCall(node.callback) === 0; // we want the value to be 0
            this.reporter.onEnter(this, node);
            if (success) {
                node.message = null;
                node.stackTrace = null;
                node.pass = true;
                node.actual = null;
                node.expected = null;
            }
            node.end = perf_hooks_1.performance.now();
            this.addResult(node, success);
            this.reporter.onExit(this, node);
            return;
        }
        // perform test collection and evaluate the node, each node must set pass to `true` if it passes
        if (node === this.rootNode) {
            try {
                if (this.wasi) {
                    this.wasi.start(this.instance);
                }
                else {
                    // collect all the top level function pointers, tests, groups, and logs
                    this.wasm._start();
                }
            }
            catch (ex) {
                this.reporter.onEnter(this, node);
                /**
                 * If this catch occurs, the entire test suite is completed.
                 * This is a sanity check.
                 */
                node.end = perf_hooks_1.performance.now();
                this.addResult(node, false);
                this.reporter.onExit(this, node);
                return;
            }
        }
        else {
            // gather all the tests and groups, validate program state at this level
            var success = this.tryCall(node.callback) === 1;
            this.reporter.onEnter(this, node);
            if (!success) {
                // collection or test failure, stop traversal of this node
                this.collectStatistics(node);
                this.addResult(node, false);
                this.reporter.onExit(this, node);
                return;
            }
        }
        // Errors can occur at any level before you visit them, even if nothing was thrown
        if (node.errors.length > 0) {
            this.collectStatistics(node);
            this.addResult(node, false);
            this.reporter.onExit(this, node);
            return;
        }
        // We now have the responsibility to run each beforeAll callback before traversing children
        if (!this.runFunctions(node.beforeAll)) {
            this.collectStatistics(node);
            this.addResult(node, false);
            this.reporter.onExit(this, node);
            return;
        }
        // now that the tests have been collected and the beforeAll has run, visit each child
        var children = node.children;
        for (var i = 0; i < children.length; i++) {
            var child = children[i];
            // in the context of running a test, run the beforeEach functions
            if (child.type === 0 /* Test */) {
                if (!this.runBeforeEach(node)) {
                    this.collectStatistics(node);
                    this.addResult(node, false);
                    this.reporter.onExit(this, node);
                    return;
                }
            }
            // now we can visit the child
            this.visit(child);
            // in the context of running a test, run the afterEach functions
            if (child.type === 0 /* Test */) {
                if (!this.runAfterEach(node)) {
                    this.collectStatistics(node);
                    this.addResult(node, false);
                    this.reporter.onExit(this, node);
                    return;
                }
            }
        }
        // We now have the responsibility to run each afterAll callback after traversing children
        if (!this.runFunctions(node.afterAll)) {
            this.collectStatistics(node);
            this.addResult(node, false);
            this.reporter.onExit(this, node);
            return;
        }
        // if any children failed, this node failed too, but assume it passes
        node.pass = node.children.reduce(function (pass, node) { return pass && node.pass; }, true);
        node.end = perf_hooks_1.performance.now();
        this.addResult(node, true);
        this.reporter.onExit(this, node);
    };
    /** Report a TestNode */
    TestContext.prototype.reportTestNode = function (type, descriptionPointer, callbackPointer, negated, messagePointer) {
        var parent = this.targetNode;
        var node = new TestNode_1.TestNode();
        node.type = type;
        node.name = this.getString(descriptionPointer, node.name);
        node.callback = callbackPointer;
        node.negated = negated === 1;
        node.message = node.negated
            ? this.getString(messagePointer, "No Message Provided.")
            : node.message;
        // namespacing for snapshots later
        var namespacePrefix = parent.namespace + "!~" + node.name;
        var i = 0;
        while (true) {
            var namespace = namespacePrefix + "[" + i + "]";
            if (this.namespaces.has(namespace)) {
                i++;
                continue;
            }
            node.namespace = namespace;
            this.namespaces.add(namespace);
            break;
        }
        // fix the node hierarchy
        node.parent = parent;
        parent.children.push(node);
    };
    /** Obtain the stack trace, actual, expected, and message values, and attach them to a given node. */
    TestContext.prototype.collectStatistics = function (node) {
        node.stackTrace = this.stack;
        node.actual = this.actual;
        node.expected = this.expected;
        node.message = this.message;
        node.end = perf_hooks_1.performance.now();
        node.rtraceEnd = this.rtrace.blocks.size;
    };
    /** Add a test or group result to the statistics. */
    TestContext.prototype.addResult = function (node, pass) {
        if (node.type === 1 /* Group */) {
            this.groupCount += 1;
            if (pass)
                this.groupPassCount += 1;
        }
        else {
            this.testCount += 1;
            if (pass)
                this.testPassCount += 1;
        }
        this.todoCount += node.todos.length;
    };
    /** Run a series of callbacks into web assembly. */
    TestContext.prototype.runFunctions = function (funcs) {
        for (var i = 0; i < funcs.length; i++) {
            if (this.tryCall(funcs[i]) === 0)
                return false;
        }
        return true;
    };
    /** Run every before each callback in the proper order. */
    TestContext.prototype.runBeforeEach = function (node) {
        return node.parent
            ? //run parents first and bail early if the parents failed
                this.runBeforeEach(node.parent) && this.runFunctions(node.beforeEach)
            : this.runFunctions(node.beforeEach);
    };
    /** Run every before each callback in the proper order. */
    TestContext.prototype.runAfterEach = function (node) {
        return node.parent
            ? //run parents first and bail early if the parents failed
                this.runAfterEach(node.parent) && this.runFunctions(node.afterEach)
            : this.runFunctions(node.afterEach);
    };
    /**
     * This method creates a WebAssembly imports object with all the TestContext functions
     * bound to the TestContext.
     *
     * @param {any[]} imports - Every import item specified.
     */
    TestContext.prototype.createImports = function () {
        var e_1, _a, e_2, _b;
        var _this = this;
        var imports = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            imports[_i] = arguments[_i];
        }
        var finalImports = {};
        try {
            for (var imports_1 = __values(imports), imports_1_1 = imports_1.next(); !imports_1_1.done; imports_1_1 = imports_1.next()) {
                var moduleImport = imports_1_1.value;
                try {
                    for (var _c = (e_2 = void 0, __values(Object.entries(moduleImport))), _d = _c.next(); !_d.done; _d = _c.next()) {
                        var _e = __read(_d.value, 2), key = _e[0], value = _e[1];
                        /* istanbul ignore next */
                        if (key === "__aspect")
                            continue;
                        /* istanbul ignore next */
                        finalImports[key] = Object.assign(finalImports[key] || {}, value);
                    }
                }
                catch (e_2_1) { e_2 = { error: e_2_1 }; }
                finally {
                    try {
                        if (_d && !_d.done && (_b = _c.return)) _b.call(_c);
                    }
                    finally { if (e_2) throw e_2.error; }
                }
            }
        }
        catch (e_1_1) { e_1 = { error: e_1_1 }; }
        finally {
            try {
                if (imports_1_1 && !imports_1_1.done && (_a = imports_1.return)) _a.call(imports_1);
            }
            finally { if (e_1) throw e_1.error; }
        }
        finalImports.__aspect = {
            attachStackTraceToReflectedValue: this.attachStackTraceToReflectedValue.bind(this),
            afterAll: this.reportAfterAll.bind(this),
            afterEach: this.reportAfterEach.bind(this),
            beforeAll: this.reportBeforeAll.bind(this),
            beforeEach: this.reportBeforeEach.bind(this),
            clearActual: this.clearActual.bind(this),
            clearExpected: this.clearExpected.bind(this),
            createReflectedValue: this.createReflectedValue.bind(this),
            createReflectedNumber: this.createReflectedNumber.bind(this),
            createReflectedLong: this.createReflectedLong.bind(this),
            debug: this.debug.bind(this),
            logReflectedValue: this.logReflectedValue.bind(this),
            pushReflectedObjectKey: this.pushReflectedObjectKey.bind(this),
            pushReflectedObjectValue: this.pushReflectedObjectValue.bind(this),
            reportActualReflectedValue: this.reportActualReflectedValue.bind(this),
            reportExpectedFalsy: this.reportExpectedFalsy.bind(this),
            reportExpectedFinite: this.reportExpectedFinite.bind(this),
            reportExpectedReflectedValue: this.reportExpectedReflectedValue.bind(this),
            reportNegatedTestNode: this.reportNegatedTestNode.bind(this),
            reportTodo: this.reportTodo.bind(this),
            reportTestTypeNode: this.reportTestTypeNode.bind(this),
            reportGroupTypeNode: this.reportGroupTypeNode.bind(this),
            reportExpectedSnapshot: this.reportExpectedSnapshot.bind(this),
            reportExpectedTruthy: this.reportExpectedTruthy.bind(this),
            tryCall: this.tryCall.bind(this),
        };
        this.rtrace.install(finalImports);
        finalImports.rtrace.onalloc = this.onalloc.bind(this);
        finalImports.rtrace.onfree = this.onfree.bind(this);
        /** add an env object */
        finalImports.env = finalImports.env || {};
        /** Override the abort function */
        var previousAbort = finalImports.env.abort || (function () { });
        finalImports.env.abort = function () {
            var args = [];
            for (var _i = 0; _i < arguments.length; _i++) {
                args[_i] = arguments[_i];
            }
            previousAbort.apply(void 0, __spread(args));
            // @ts-ignore
            _this.abort.apply(_this, __spread(args));
        };
        /** Override trace completely. */
        finalImports.env.trace = this.trace.bind(this);
        // add wasi support if requested
        if (this.wasi) {
            finalImports.wasi_snapshot_preview1 = this.wasi.wasiImport;
        }
        return finalImports;
    };
    /**
     * This function sets up a test group.
     *
     * @param {number} description - The test suite description string pointer.
     * @param {number} runner - The pointer to a test suite callback
     */
    TestContext.prototype.reportGroupTypeNode = function (description, runner) {
        this.reportTestNode(1 /* Group */, description, runner, 0, 0);
    };
    /**
     * This function sets up a test node.
     *
     * @param description - The test description string pointer
     * @param runner - The pointer to a test callback
     */
    TestContext.prototype.reportTestTypeNode = function (description, runner) {
        this.reportTestNode(0 /* Test */, description, runner, 0, 0);
    };
    /**
     * This function expects a throws from a test node.
     *
     * @param description - The test description string pointer
     * @param runner - The pointer to a test callback
     * @param message - The pointer to an additional assertion message in string
     */
    TestContext.prototype.reportNegatedTestNode = function (description, runner, message) {
        this.reportTestNode(0 /* Test */, description, runner, 1, message);
    };
    /**
     * This is called to stop the debugger.  e.g. `node --inspect-brk asp`.
     */
    /* istanbul ignore next */
    TestContext.prototype.debug = function () {
        /* istanbul ignore next */
        debugger;
    };
    /**
     * This is a web assembly utility function that wraps a function call in a try catch block to
     * report success or failure.
     *
     * @param {number} pointer - The function pointer to call. It must accept no parameters and return
     * void.
     * @returns {1 | 0} - If the callback was run successfully without error, it returns 1, else it
     * returns 0.
     */
    TestContext.prototype.tryCall = function (pointer) {
        /** This is a safety net conditional, no reason to test it. */
        /* istanbul ignore next */
        if (pointer < 0)
            return 1;
        try {
            this.wasm.__call(pointer);
        }
        catch (ex) {
            this.stack = this.getErrorStackTrace(ex);
            return 0;
        }
        return 1;
    };
    /**
     * This web assembly linked function sets the group's "beforeEach" callback pointer to
     * the current groupStackItem.
     *
     * @param {number} callbackPointer - The callback that should run before each test.
     */
    TestContext.prototype.reportBeforeEach = function (callbackPointer) {
        this.targetNode.beforeEach.push(callbackPointer);
    };
    /**
     * This web assembly linked function adds the group's "beforeAll" callback pointer to
     * the current groupStackItem.
     *
     * @param {number} callbackPointer - The callback that should run before each test in the
     * current context.
     */
    TestContext.prototype.reportBeforeAll = function (callbackPointer) {
        this.targetNode.beforeAll.push(callbackPointer);
    };
    /**
     * This web assembly linked function sets the group's "afterEach" callback pointer.
     *
     * @param {number} callbackPointer - The callback that should run before each test group.
     */
    TestContext.prototype.reportAfterEach = function (callbackPointer) {
        this.targetNode.afterEach.push(callbackPointer);
    };
    /**
     * This web assembly linked function adds the group's "afterAll" callback pointer to
     * the current groupStackItem.
     *
     * @param {number} callbackPointer - The callback that should run before each test in the
     * current context.
     */
    TestContext.prototype.reportAfterAll = function (callbackPointer) {
        this.targetNode.afterAll.push(callbackPointer);
    };
    /**
     * This function reports a single "todo" item in a test suite.
     *
     * @param {number} todoPointer - The todo description string pointer.
     * @param {number} _callbackPointer - The test callback function pointer.
     */
    TestContext.prototype.reportTodo = function (todoPointer, _callbackPointer) {
        this.targetNode.todos.push(this.getString(todoPointer, "No todo() value provided."));
    };
    /**
     * This function overrides the provided AssemblyScript `env.abort()` function to catch abort
     * reasons.
     *
     * @param {number} reasonPointer - This points to the message value that causes the expectation to
     * fail.
     * @param {number} fileNamePointer - The file name that reported the error. (Ignored)
     * @param {number} line - The line that reported the error. (Ignored)
     * @param {number} col - The column that reported the error. (Ignored)
     */
    TestContext.prototype.abort = function (reasonPointer, fileNamePointer, line, col) {
        this.message = this.getString(reasonPointer, "Error in " + this.getString(fileNamePointer, "[No Filename Provided]") + ":" + line + ":" + col + " ");
    };
    /**
     * Gets an error stack trace.
     */
    TestContext.prototype.getErrorStackTrace = function (ex) {
        var stackItems = ex.stack.toString().split("\n");
        return __spread([stackItems[0]], stackItems.slice(1).filter(wasmFilter)).join("\n");
    };
    /**
     * Gets a log stack trace.
     */
    TestContext.prototype.getLogStackTrace = function () {
        return new Error("Get stack trace.")
            .stack.toString()
            .split("\n")
            .slice(1)
            .filter(wasmFilter)
            .join("\n");
    };
    /**
     * This method is called when a memory block is deallocated from the heap.
     *
     * @param {number} block - This is a unique identifier for the affected block.
     */
    TestContext.prototype.onfree = function (block) {
        this.targetNode.frees += 1;
        // remove any cached strings at this pointer
        this.cachedStrings.delete(block + rTrace_1.TOTAL_OVERHEAD);
        this.rtrace.onfree(block);
    };
    /**
     * This method is called when a memory block is allocated on the heap.
     *
     * @param {number} block - This is a unique identifier for the affected block.
     */
    TestContext.prototype.onalloc = function (block) {
        this.targetNode.allocations += 1;
        this.rtrace.onalloc(block);
    };
    /**
     * Gets a string from the wasm module, unless the module string is null. Otherwise it returns
     * a default value.
     */
    TestContext.prototype.getString = function (pointer, defaultValue) {
        pointer >>>= 0;
        if (pointer === 0)
            return defaultValue;
        if (this.cachedStrings.has(pointer)) {
            return this.cachedStrings.get(pointer);
        }
        var result = this.wasm.__getString(pointer);
        this.cachedStrings.set(pointer, result);
        return result;
    };
    /**
     * An override implementation of the AssemblyScript trace function.
     *
     * @param {number} strPointer - The trace string.
     * @param {number} count - The number of arguments to be traced.
     * @param {number[]} args - The traced arguments.
     */
    TestContext.prototype.trace = function (strPointer, count) {
        var args = [];
        for (var _i = 2; _i < arguments.length; _i++) {
            args[_i - 2] = arguments[_i];
        }
        var reflectedValue = new ReflectedValue_1.ReflectedValue();
        reflectedValue.pointer = strPointer;
        reflectedValue.stack = this.getLogStackTrace();
        reflectedValue.typeName = "trace";
        reflectedValue.type = 2 /* String */;
        reflectedValue.value = "trace: " + this.getString(strPointer, "") + " " + args.slice(0, count).join(", ");
        // push the log value to the logs
        this.targetNode.logs.push(reflectedValue);
    };
    /**
     * Retrieve the function name of a given web assembly function.
     *
     * @param {number} index - The function index
     */
    TestContext.prototype.funcName = function (index) {
        var nameSection = this.nameSection;
        /* istanbul ignore next */
        if (nameSection) {
            var result = this.wasm.table.get(index);
            return nameSection.fromIndex(parseInt(result.name));
        }
        /* istanbul ignore next */
        return "";
    };
    TestContext.prototype.createReflectedValue = function (isNull, hasKeys, nullable, offset, // offsetof<T>("propName")
    pointer, // changetype<usize>(this) | 0
    signed, // isSigned<T>()
    size, // sizeof<T>()
    reflectedTypeValue, typeId, // idof<T>()
    typeName, // nameof<T>()
    value, // usize
    hasValues, // bool
    isManaged) {
        var reflectedValue = new ReflectedValue_1.ReflectedValue();
        reflectedValue.isNull = isNull === 1;
        reflectedValue.keys = hasKeys ? [] : null;
        reflectedValue.nullable = nullable === 1;
        reflectedValue.offset = offset;
        reflectedValue.pointer = pointer;
        reflectedValue.signed = signed === 1;
        reflectedValue.size = size;
        reflectedValue.type = reflectedTypeValue;
        reflectedValue.typeId = typeId;
        reflectedValue.typeName = this.getString(typeName, "");
        reflectedValue.values = hasValues ? [] : null;
        reflectedValue.isManaged = isManaged === 1;
        if (reflectedTypeValue === 2 /* String */) {
            reflectedValue.value = this.getString(value, "");
        }
        else if (reflectedTypeValue === 6 /* Function */) {
            reflectedValue.value = this.funcName(value);
        }
        else {
            reflectedValue.value = value;
        }
        return this.reflectedValueCache.push(reflectedValue) - 1;
    };
    /**
     * Create a reflected number value.
     *
     * @param {1 | 0} signed - Indicate if the value is signed.
     * @param {number} size - The size of the value in bytes.
     * @param {ReflectedValueType} reflectedTypeValue - The ReflectedValueType
     * @param {number} typeName - The name of the type.
     * @param {number} value - The value itself
     */
    TestContext.prototype.createReflectedNumber = function (signed, // isSigned<T>()
    size, // sizeof<T>()
    reflectedTypeValue, typeName, // nameof<T>()
    value) {
        var reflectedValue = new ReflectedValue_1.ReflectedValue();
        reflectedValue.signed = signed === 1;
        reflectedValue.size = size;
        reflectedValue.type = reflectedTypeValue;
        reflectedValue.typeName = this.getString(typeName, "");
        reflectedValue.value = value;
        return this.reflectedValueCache.push(reflectedValue) - 1;
    };
    /**
     * Create reflection of a long number (not supported directly from javascript)
     */
    TestContext.prototype.createReflectedLong = function (signed, // isSigned<T>()
    size, // sizeof<T>()
    reflectedTypeValue, typeName, // nameof<T>()
    lowValue, // i32
    highValue) {
        var reflectedValue = new ReflectedValue_1.ReflectedValue();
        reflectedValue.signed = signed === 1;
        reflectedValue.size = size;
        reflectedValue.type = reflectedTypeValue;
        reflectedValue.typeName = this.getString(typeName, "");
        reflectedValue.value = long_1.default.fromBits(lowValue >>> 0, highValue >>> 0, signed === 0).toString();
        return this.reflectedValueCache.push(reflectedValue) - 1;
    };
    /**
     * Log a reflected value.
     *
     * @param {number} id - The ReflectedValue id
     */
    TestContext.prototype.logReflectedValue = function (id) {
        /* istanbul ignore next */
        if (id >= this.reflectedValueCache.length || id < 0) {
            /* istanbul ignore next */
            this.pushError({
                message: "Cannot log ReflectedValue of id " + id + ". Index out of bounds.",
                stackTrace: this.getLogStackTrace(),
                type: "ReflectedValue",
            });
            /* istanbul ignore next */
            return;
        }
        this.targetNode.logs.push(this.reflectedValueCache[id]);
    };
    /**
     * Report an actual reflected value.
     *
     * @param {number} id - The ReflectedValue id
     */
    TestContext.prototype.reportActualReflectedValue = function (id) {
        // ignored lines are santiy checks for error reporting
        /* istanbul ignore next */
        if (id >= this.reflectedValueCache.length || id < 0) {
            /* istanbul ignore next */
            this.pushError({
                message: "Cannot report actual ReflectedValue of id " + id + ". Index out of bounds.",
                stackTrace: this.getLogStackTrace(),
                type: "ReflectedValue",
            });
            /* istanbul ignore next */
            return;
        }
        this.actual = this.reflectedValueCache[id];
    };
    /**
     * Report an expected reflected value.
     *
     * @param {number} id - The ReflectedValue id
     */
    TestContext.prototype.reportExpectedReflectedValue = function (id, negated) {
        // ignored lines are error reporting for sanity checks
        /* istanbul ignore next */
        if (id >= this.reflectedValueCache.length || id < 0) {
            /* istanbul ignore next */
            this.pushError({
                message: "Cannot report expected ReflectedValue of id " + id + ". Index out of bounds.",
                stackTrace: this.getLogStackTrace(),
                type: "ReflectedValue",
            });
            /* istanbul ignore next */
            return;
        }
        this.expected = this.reflectedValueCache[id];
        this.expected.negated = negated === 1;
    };
    /**
     * Push a reflected value to a given reflected value.
     *
     * @param {number} reflectedValueID - The target reflected value parent.
     * @param {number} childID - The child value by it's id to be pushed.
     */
    TestContext.prototype.pushReflectedObjectValue = function (reflectedValueID, childID) {
        // each ignored line for test coverage is error reporting for sanity checks
        /* istanbul ignore next */
        if (reflectedValueID >= this.reflectedValueCache.length ||
            reflectedValueID < 0) {
            /* istanbul ignore next */
            this.pushError({
                message: "Cannot push ReflectedValue of id " + childID + " to ReflectedValue " + reflectedValueID + ". ReflectedValue id out of bounds.",
                stackTrace: this.getLogStackTrace(),
                type: "ReflectedValue",
            });
            /* istanbul ignore next */
            return;
        }
        /* istanbul ignore next */
        if (childID >= this.reflectedValueCache.length || childID < 0) {
            /* istanbul ignore next */
            this.pushError({
                message: "Cannot push ReflectedValue of id " + childID + " to ReflectedValue " + reflectedValueID + ". ReflectedValue id out of bounds.",
                stackTrace: this.getLogStackTrace(),
                type: "ReflectedValue",
            });
            /* istanbul ignore next */
            return;
        }
        var reflectedParentValue = this.reflectedValueCache[reflectedValueID];
        var childValue = this.reflectedValueCache[childID];
        /* istanbul ignore next */
        if (!reflectedParentValue.values) {
            /* istanbul ignore next */
            this.pushError({
                message: "Cannot push ReflectedValue of id " + childID + " to ReflectedValue " + reflectedValueID + ". ReflectedValue was not initialized with a values array.",
                stackTrace: this.getLogStackTrace(),
                type: "ReflectedValue",
            });
            /* istanbul ignore next */
            return;
        }
        reflectedParentValue.values.push(childValue);
    };
    /**
     * Push a reflected value key to a given reflected value.
     *
     * @param {number} reflectedValueID - The target reflected value parent.
     * @param {number} keyId - The target reflected value key to be pushed.
     */
    TestContext.prototype.pushReflectedObjectKey = function (reflectedValueID, keyId) {
        // every ignored line for test coverage in this function are sanity checks
        /* istanbul ignore next */
        if (reflectedValueID >= this.reflectedValueCache.length ||
            reflectedValueID < 0) {
            /* istanbul ignore next */
            this.pushError({
                message: "Cannot push ReflectedValue of id " + keyId + " to ReflectedValue " + reflectedValueID + ". ReflectedValue id out of bounds.",
                stackTrace: this.getLogStackTrace(),
                type: "ReflectedValue",
            });
            /* istanbul ignore next */
            return;
        }
        /* istanbul ignore next */
        if (keyId >= this.reflectedValueCache.length || keyId < 0) {
            /* istanbul ignore next */
            this.pushError({
                message: "Cannot push ReflectedValue of id " + keyId + " to ReflectedValue " + reflectedValueID + ". ReflectedValue key id out of bounds.",
                stackTrace: this.getLogStackTrace(),
                type: "ReflectedValue",
            });
            /* istanbul ignore next */
            return;
        }
        var reflectedValue = this.reflectedValueCache[reflectedValueID];
        var key = this.reflectedValueCache[keyId];
        // this is a failsafe if a keys[] does not exist on the ReflectedValue
        /* istanbul ignore next */
        if (!reflectedValue.keys) {
            /* istanbul ignore next */
            this.pushError({
                message: "Cannot push ReflectedValue of id " + keyId + " to ReflectedValue " + reflectedValueID + ". ReflectedValue was not initialized with a keys array.",
                stackTrace: this.getLogStackTrace(),
                type: "ReflectedValue",
            });
            /* istanbul ignore next */
            return;
        }
        reflectedValue.keys.push(key);
    };
    /**
     * Clear the expected value.
     */
    TestContext.prototype.clearExpected = function () {
        this.expected = null;
    };
    /**
     * Clear the actual value.
     */
    TestContext.prototype.clearActual = function () {
        this.actual = null;
    };
    /**
     * Report an expected truthy value, and if it's negated.
     *
     * @param {1 | 0} negated - An indicator if the expectation is negated.
     */
    TestContext.prototype.reportExpectedTruthy = function (negated) {
        var expected = (this.expected = new ReflectedValue_1.ReflectedValue());
        expected.negated = negated === 1;
        expected.type = 13 /* Truthy */;
    };
    /**
     * Report an expected truthy value, and if it's negated.
     *
     * @param {1 | 0} negated - An indicator if the expectation is negated.
     */
    TestContext.prototype.reportExpectedFalsy = function (negated) {
        var expected = (this.expected = new ReflectedValue_1.ReflectedValue());
        expected.negated = negated === 1;
        expected.type = 14 /* Falsy */;
    };
    /**
     * Report an expected finite value, and if it's negated.
     *
     * @param {1 | 0} negated - An indicator if the expectation is negated.
     */
    TestContext.prototype.reportExpectedFinite = function (negated) {
        var expected = (this.expected = new ReflectedValue_1.ReflectedValue());
        expected.negated = negated === 1;
        expected.type = 12 /* Finite */;
    };
    /**
     * Attaches a stack trace to the given reflectedValue by it's id.
     *
     * @param {number} reflectedValueID - The given reflected value by it's id.
     */
    TestContext.prototype.attachStackTraceToReflectedValue = function (reflectedValueID) {
        /* istanbul ignore next */
        if (reflectedValueID >= this.reflectedValueCache.length ||
            reflectedValueID < 0) {
            /* istanbul ignore next */
            this.pushError({
                message: "Cannot push a stack trace to ReflectedValue " + reflectedValueID + ". ReflectedValue id out of bounds.",
                stackTrace: this.getLogStackTrace(),
                type: "ReflectedValue",
            });
            /* istanbul ignore next */
            return;
        }
        this.reflectedValueCache[reflectedValueID].stack = this.getLogStackTrace();
    };
    /** Push an error to the errors array. */
    TestContext.prototype.pushError = function (error) {
        this.targetNode.errors.push(error);
        this.errors.push(error);
    };
    /** Push an warning to the warnings array. */
    /* istanbul ignore next */
    TestContext.prototype.pushWarning = function (warning) {
        /* istanbul ignore next */
        this.targetNode.warnings.push(warning);
        /* istanbul ignore next */
        this.warnings.push(warning);
    };
    /**
     * Report an expected snapshot.
     *
     * @param {number} reflectedValueID - The id of the reflected actual value.
     * @param {number} namePointer - The name of the snapshot.
     */
    TestContext.prototype.reportExpectedSnapshot = function (reflectedValueID, namePointer) {
        var name = this.targetNode.name + "!~" + this.getString(namePointer, "");
        /* istanbul ignore next */
        if (reflectedValueID >= this.reflectedValueCache.length ||
            reflectedValueID < 0) {
            /* istanbul ignore next */
            this.pushError({
                message: "Cannot add snapshot " + name + " with reflected value " + reflectedValueID + ". ReflectedValue id out of bounds.",
                stackTrace: this.getLogStackTrace(),
                type: "ReflectedValue",
            });
            /* istanbul ignore next */
            return;
        }
        this.snapshots.add(name, this.reflectedValueCache[reflectedValueID].stringify(stringifyOptions));
    };
    return TestContext;
}());
exports.TestContext = TestContext;
//# sourceMappingURL=TestContext.js.map