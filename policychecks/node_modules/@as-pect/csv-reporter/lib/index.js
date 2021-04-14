"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var csv_stringify_1 = __importDefault(require("csv-stringify"));
var fs_1 = require("fs");
var path_1 = require("path");
/**
 * This is a list of all the columns in the exported csv file.
 */
var csvColumns = [
    "Group",
    "Name",
    "Ran",
    "Negated",
    "Pass",
    "Runtime",
    "Message",
    "Actual",
    "Expected",
];
/**
 * This class is responsible for creating a csv file located at {testName}.spec.csv. It will
 * contain a set of tests with relevant pass and fail information.
 */
module.exports = /** @class */ (function () {
    function CSVReporter() {
        this.output = null;
        this.fileName = null;
    }
    CSVReporter.prototype.onEnter = function (ctx) {
        this.output = csv_stringify_1.default({ columns: csvColumns });
        var extension = path_1.extname(ctx.fileName);
        var dir = path_1.dirname(ctx.fileName);
        var base = path_1.basename(ctx.fileName, extension);
        var outPath = path_1.join(process.cwd(), dir, base + ".csv");
        this.fileName = fs_1.createWriteStream(outPath, "utf8");
        this.output.pipe(this.fileName);
        this.output.write(csvColumns);
    };
    CSVReporter.prototype.onExit = function (_ctx, node) {
        if (node.type === 1 /* Group */) {
            this.onGroupFinish(node);
        }
    };
    CSVReporter.prototype.onFinish = function () {
        this.output.end();
    };
    CSVReporter.prototype.onGroupFinish = function (group) {
        var _this = this;
        if (group.children.length === 0)
            return;
        group.groupTests.forEach(function (test) { return _this.onTestFinish(group, test); });
        group.groupTodos.forEach(function (desc) { return _this.onTodo(group, desc); });
    };
    CSVReporter.prototype.onTestFinish = function (group, test) {
        this.output.write([
            group.name,
            test.ran ? "RAN" : "NOT RUN",
            test.name,
            test.negated ? "TRUE" : "FALSE",
            test.pass ? "PASS" : "FAIL",
            test.deltaT.toString(),
            test.message,
            test.actual ? test.actual.stringify({ indent: 0 }) : "",
            test.expected
                ? "" + (test.negated ? "Not " : "") + test.expected.stringify({
                    indent: 0,
                })
                : "",
        ]);
    };
    CSVReporter.prototype.onTodo = function (group, desc) {
        this.output.write([group.name, "TODO", desc, "", "", "", "", "", ""]);
    };
    return CSVReporter;
}());
//# sourceMappingURL=index.js.map