"use strict";
var __makeTemplateObject = (this && this.__makeTemplateObject) || function (cooked, raw) {
    if (Object.defineProperty) { Object.defineProperty(cooked, "raw", { value: raw }); } else { cooked.raw = raw; }
    return cooked;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.collectReporter = void 0;
var querystring_1 = __importDefault(require("querystring"));
var chalk_1 = __importDefault(require("chalk"));
/**
 * @ignore
 * This method inspects the command line arguments and returns the corresponding TestReporter.
 *
 * @param {Options} cliOptions - The command line arguments.
 */
function collectReporter(cliOptions) {
    var reporters = [];
    if (cliOptions.csv) {
        var CSVReporter = require("@as-pect/csv-reporter");
        if (typeof cliOptions.csv === "string") {
            var options = querystring_1.default.parse(cliOptions.csv || "");
            reporters.push(new CSVReporter(options));
        }
        else {
            reporters.push(new CSVReporter());
        }
        process.stdout.write(chalk_1.default(templateObject_1 || (templateObject_1 = __makeTemplateObject(["{bgWhite.black [Log]} Using {yellow CSVReporter}\n"], ["{bgWhite.black [Log]} Using {yellow CSVReporter}\\n"]))));
    }
    if (cliOptions.json) {
        var JSONReporter = require("@as-pect/json-reporter");
        if (typeof cliOptions.json === "string") {
            var options = querystring_1.default.parse(cliOptions.json || "");
            reporters.push(new JSONReporter(options));
        }
        else {
            reporters.push(new JSONReporter());
        }
        process.stdout.write(chalk_1.default(templateObject_2 || (templateObject_2 = __makeTemplateObject(["{bgWhite.black [Log]} Using {yellow JSONReporter}\n"], ["{bgWhite.black [Log]} Using {yellow JSONReporter}\\n"]))));
    }
    if (cliOptions.verbose) {
        var VerboseReporter = require("@as-pect/core").VerboseReporter;
        var reporter = new VerboseReporter(typeof cliOptions.summary === "string"
            ? querystring_1.default.parse(cliOptions.summary || "")
            : {});
        reporter.stdout = process.stdout;
        reporter.stderr = process.stderr;
        reporters.push(reporter);
        process.stdout.write(chalk_1.default(templateObject_3 || (templateObject_3 = __makeTemplateObject(["{bgWhite.black [Log]} Using {yellow VerboseReporter}\n"], ["{bgWhite.black [Log]} Using {yellow VerboseReporter}\\n"]))));
    }
    if (cliOptions.reporter) {
        var url = require("url").parse(cliOptions.reporter);
        try {
            var reporterValue = require(url.pathname);
            var Reporter = reporterValue.default || reporterValue;
            var options = require("querystring").parse(url.query);
            if (typeof Reporter === "function") {
                reporters.push(new Reporter(options));
            }
            else {
                reporters.push(Reporter);
            }
        }
        catch (ex) {
            console.error(chalk_1.default(templateObject_4 || (templateObject_4 = __makeTemplateObject(["{red [Error]} Cannot find a reporter at {yellow ", "}"], ["{red [Error]} Cannot find a reporter at {yellow ", "}"])), url.pathname));
            console.error(ex);
            process.exit(1);
        }
        process.stdout.write(chalk_1.default(templateObject_5 || (templateObject_5 = __makeTemplateObject(["{bgWhite.black [Log]} Using custom reporter at: {yellow ", "}\n"], ["{bgWhite.black [Log]} Using custom reporter at: {yellow ", "}\\n"])), url.pathname));
    }
    /**
     * If there are no other reporters summary is the default.
     */
    if (cliOptions.summary || reporters.length == 0) {
        var SummaryReporter = require("@as-pect/core").SummaryReporter;
        var reporter = new SummaryReporter(typeof cliOptions.summary === "string"
            ? querystring_1.default.parse(cliOptions.summary || "")
            : { enableLogging: true });
        reporter.stdout = process.stdout;
        reporter.stderr = process.stderr;
        reporters.push(reporter);
        process.stdout.write(chalk_1.default(templateObject_6 || (templateObject_6 = __makeTemplateObject(["{bgWhite.black [Log]} Using {yellow SummaryReporter}\n"], ["{bgWhite.black [Log]} Using {yellow SummaryReporter}\\n"]))));
    }
    // If only one reporter return it, otherwise, combine them.
    if (reporters.length === 1) {
        return reporters[0];
    }
    else {
        var CombinationReporter = require("@as-pect/core").CombinationReporter;
        return new CombinationReporter(reporters);
    }
}
exports.collectReporter = collectReporter;
var templateObject_1, templateObject_2, templateObject_3, templateObject_4, templateObject_5, templateObject_6;
//# sourceMappingURL=collectReporter.js.map