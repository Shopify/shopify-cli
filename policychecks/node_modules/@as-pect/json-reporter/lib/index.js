"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var fs_1 = require("fs");
var path_1 = require("path");
/**
 * This class reports all relevant test statistics to a JSON file located at
 * `{testLocation}.spec.json`.
 */
module.exports = /** @class */ (function () {
    function JSONReporter() {
        this.file = null;
        this.first = true;
    }
    JSONReporter.prototype.onEnter = function (ctx) {
        var extension = path_1.extname(ctx.fileName);
        var dir = path_1.dirname(ctx.fileName);
        var base = path_1.basename(ctx.fileName, extension);
        var outPath = path_1.join(process.cwd(), dir, base + ".json");
        this.file = fs_1.createWriteStream(outPath, "utf8");
        this.file.write("[");
        this.first = true;
    };
    JSONReporter.prototype.onExit = function (_ctx, node) {
        if (node.type === 1 /* Group */) {
            this.onGroupFinish(node);
        }
    };
    JSONReporter.prototype.onFinish = function (_ctx) {
        this.file.end();
    };
    JSONReporter.prototype.onGroupFinish = function (group) {
        var _this = this;
        if (group.children.length === 0)
            return;
        group.groupTests.forEach(function (test) { return _this.onTestFinish(group, test); });
        group.groupTodos.forEach(function (desc) { return _this.onTodo(group, desc); });
    };
    JSONReporter.prototype.onTestFinish = function (group, test) {
        this.file.write((this.first ? "\n" : ",\n") +
            JSON.stringify({
                group: group.name,
                name: test.name,
                ran: test.ran,
                pass: test.pass,
                negated: test.negated,
                runtime: test.deltaT,
                message: test.message,
                actual: test.actual ? test.actual.stringify({ indent: 0 }) : null,
                expected: test.expected
                    ? "" + (test.negated ? "Not " : "") + test.expected.stringify({
                        indent: 0,
                    })
                    : null,
            }));
        this.first = false;
    };
    JSONReporter.prototype.onTodo = function (group, desc) {
        this.file.write((this.first ? "\n" : ",\n") +
            JSON.stringify({
                group: group.name,
                name: "TODO: " + desc,
                ran: false,
                pass: null,
                negated: false,
                runtime: 0,
                message: "",
                actual: null,
                expected: null,
            }));
        this.first = false;
    };
    return JSONReporter;
}());
//# sourceMappingURL=index.js.map