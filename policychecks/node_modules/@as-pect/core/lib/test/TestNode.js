"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TestNode = void 0;
var timeDifference_1 = require("../util/timeDifference");
var TestNode = /** @class */ (function () {
    function TestNode() {
        /** The TestNode type. */
        this.type = 0 /* Test */;
        /** The name of the TestNode */
        this.name = "";
        /** The callback pointer. */
        this.callback = -1;
        /** If the test is expected to fail. */
        this.negated = false;
        /** The namespace of this TestNode */
        this.namespace = "";
        /** The callback pointers that need to be called before each test. */
        this.beforeEach = [];
        /** The callback pointers that need to be called once before traversing through this node's children. */
        this.beforeAll = [];
        /** The callback pointers that need to be called after each test. */
        this.afterEach = [];
        /** The callback pointers that need to be called once after traversing through this node's children. */
        this.afterAll = [];
        /** Parent TestNode */
        this.parent = null;
        /** Children TestNodes */
        this.children = [];
        /** An indicator if the test suite passed. */
        this.pass = false;
        /** A set of warnings. */
        this.warnings = [];
        /** A set of errors. */
        this.errors = [];
        /** A set of logged values. */
        this.logs = [];
        /** A stack trace for the error. */
        this.stackTrace = null;
        /** The actual reported value. */
        this.actual = null;
        /** The expected reported value. */
        this.expected = null;
        /** Message provided by the abort() function. */
        this.message = null;
        /** A set of todo messages provided by the testnode. */
        this.todos = [];
        /** Start time. */
        this.start = 0;
        /** End time. */
        this.end = 0;
        /** The number of active heap allocations when the node started. */
        this.rtraceStart = 0;
        /** The number of active heap allocations when the node ended. */
        this.rtraceEnd = 0;
        /** If the TestNode ran. */
        this.ran = false;
        /** The node allocations. */
        this.allocations = 0;
        /** The node deallocations */
        this.frees = 0;
        /** The node reallocations. */
        this.moves = 0;
    }
    Object.defineProperty(TestNode.prototype, "rtraceDelta", {
        /** The delta number of heap allocations. */
        get: function () {
            return this.allocations - this.frees;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(TestNode.prototype, "deltaT", {
        /** The difference between the start and end TestNode runtime. */
        get: function () {
            return timeDifference_1.timeDifference(this.end, this.start);
        },
        enumerable: false,
        configurable: true
    });
    /**
     * Recursively visit this node's children conditionally. Return false to the callback
     * if you don't want to visit that particular node's children.
     */
    TestNode.prototype.visit = function (callback) {
        var children = this.children;
        for (var i = 0; i < children.length; i++) {
            var child = children[i];
            if (callback(child) !== false)
                child.visit(callback);
        }
    };
    Object.defineProperty(TestNode.prototype, "groupTodos", {
        /** Get this group's todos, recursively. */
        get: function () {
            return [].concat.apply(this.todos, this.groupTests.map(function (e) { return e.todos; }));
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(TestNode.prototype, "groupTests", {
        /** Get this group's tests, recursively. */
        get: function () {
            var result = [];
            this.visit(function (node) {
                if (node.type === 0 /* Test */) {
                    result.push(node);
                }
                else {
                    return false;
                }
            });
            return result;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(TestNode.prototype, "childGroups", {
        /** Get all the groups beneath this node. */
        get: function () {
            var result = [];
            this.visit(function (node) {
                if (node.type === 1 /* Group */)
                    result.push(node);
            });
            return result;
        },
        enumerable: false,
        configurable: true
    });
    return TestNode;
}());
exports.TestNode = TestNode;
//# sourceMappingURL=TestNode.js.map