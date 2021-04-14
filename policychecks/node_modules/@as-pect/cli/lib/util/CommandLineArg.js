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
exports.parse = exports.defaultCliArgs = exports.makeArgMap = exports.CommandLineArg = void 0;
var strings_1 = require("./strings");
/**
 * @ignore
 *
 * This class represents a definition for a command line argument.
 */
var CommandLineArg = /** @class */ (function () {
    function CommandLineArg(name, command) {
        this.name = name;
        this.description = command.description;
        this.type = command.type;
        this.value = command.value;
        this.alias = command.alias;
        this.options = command.options;
        this.parent = command.parent;
    }
    CommandLineArg.prototype.parse = function (data) {
        switch (this.type) {
            case "s":
                return data;
            case "bs":
                return data;
            case "S":
                return data.split(",");
            case "b":
                if (data !== "true" && data !== "false") {
                    throw new Error("Bad value " + data + " for boolean for argument " + this.name);
                }
                return "true" === data;
            case "i":
                return parseInt(data);
            case "f":
                return parseFloat(data);
            default:
                throw new Error("Type " + this.type + " is not implemented yet");
        }
    };
    return CommandLineArg;
}());
exports.CommandLineArg = CommandLineArg;
/**
 * @ignore
 * The definition for the as-pect/cli arguments.
 */
var _Args = {
    compiler: {
        description: [
            "Path to folder relative to project root which contains",
            "{folder}/dist/asc for the compiler and {folder}/lib/loader for loader.",
        ],
        type: "s",
        value: "assemblyscript",
    },
    config: {
        description: "Use a specified configuration",
        type: "s",
        alias: { name: "c" },
        value: "as-pect.config.js",
    },
    csv: {
        description: "Use the csv reporter. It outputs test data to {testname}.spec.csv",
        type: "bs",
        value: false,
    },
    file: {
        description: "Run the tests of each file that matches this regex.",
        type: "s",
        alias: [{ name: "files", long: true }, { name: "f" }],
        value: ".",
    },
    group: {
        description: "Run each describe block that matches this regex",
        type: "s",
        alias: [{ name: "groups", long: true }, { name: "g" }],
        value: "(:?)",
    },
    help: {
        description: "Show this help screen.",
        type: "b",
        alias: { name: "h" },
        value: false,
    },
    init: {
        description: "Create a test config, an assembly/__tests__ folder and exit.",
        type: "b",
        alias: { name: "i" },
        value: false,
    },
    json: {
        description: [
            "Use the json reporter. It outputs test data to {testname}.spec.json",
        ],
        type: "bs",
        value: false,
    },
    "memory-max": {
        description: "Set the maximum amount of memory pages the wasm module can use.",
        type: "i",
        value: -1,
    },
    "memory-size": {
        description: "Set the initial wasm memory size in pages [64kb each].",
        type: "i",
        alias: { name: "m" },
        value: 10,
    },
    nologo: {
        description: "Suppress ASCII art from being printed.",
        type: "b",
        alias: { name: "nl" },
        value: false,
    },
    norun: {
        description: "Skip running tests and output the compiler files.",
        type: "b",
        alias: { name: "n" },
        value: false,
    },
    "output-binary": {
        description: "Create a (.wasm) file can contains all the tests to be run later.",
        type: "b",
        alias: { name: "o" },
        value: false,
    },
    portable: {
        description: "Add the portable jest/as-pect types to your project.",
        type: "b",
        value: false,
    },
    reporter: {
        description: "Define the reporter to be used.",
        type: "s",
        value: "",
        options: [
            [
                "./path/to/reporter.js?queryString",
                "Use the default exported object from this module as the reporter.",
            ],
        ],
    },
    summary: {
        description: [
            "Use the summary reporter. It outputs a summary of the test results to stdout.",
        ],
        type: "bs",
        value: false,
    },
    test: {
        description: "Run each test that matches this regex",
        type: "s",
        alias: [{ name: "tests", long: true }, { name: "t" }],
        value: "(:?)",
    },
    types: {
        description: "Copy the types file to assembly/__tests__/as-pect.d.ts",
        type: "b",
        value: false,
    },
    verbose: {
        description: [
            "Use the verbose reporter. It outputs all the test details to stdout.",
        ],
        type: "bs",
        value: false,
    },
    version: {
        description: "View the version.",
        type: "b",
        alias: { name: "v" },
        value: false,
    },
    workers: {
        description: "An experimental flag that enables parallel compilation in Worker worklets.",
        type: "i",
        alias: { name: "w" },
        value: 0,
    },
    update: {
        description: "Update the snapshots",
        type: "b",
        alias: { name: "u" },
        value: false,
    },
};
/**
 * @ignore
 * Take a CommandLineArgs object and turn it into an ArgMap.
 *
 * @param args
 */
function makeArgMap(args) {
    if (args === void 0) { args = _Args; }
    var res = new Map();
    Object.getOwnPropertyNames(args).forEach(function (element) {
        var arg = new CommandLineArg(element, _Args[element]);
        res.set(element, arg);
        var aliases = _Args[element].alias;
        if (aliases) {
            (Array.isArray(aliases) ? aliases : [aliases]).forEach(function (alias) {
                // short aliases have a `-` prefix to disguish them
                var name = (!alias.long ? "-" : "") + alias.name;
                res.set(name, arg);
            });
        }
    });
    return res;
}
exports.makeArgMap = makeArgMap;
/**
 * This is the set of stored command line arguments for the asp command line.
 */
exports.defaultCliArgs = makeArgMap(_Args);
/**
 * @ignore
 */
var reg = /(?:--([a-z][a-z\-]*)|(-[a-z][a-z\-]*))(?:=(.*))?/i;
/**
 * @ignore
 */
var invalidArg = /^[\-]/;
/**
 * This method parses command line options like the `asp` command does. It takes an optional
 * second parameter to modify the command line arguments used.
 *
 * @param {string[]} commands - The command line arguments.
 * @param {ArgMap} cliArgs - The set of parsable arguments.
 */
function parse(commands, cliArgs) {
    if (cliArgs === void 0) { cliArgs = exports.defaultCliArgs; }
    var opts = {
        changed: new Set(),
    };
    cliArgs.forEach(function (arg) {
        var camelCase = strings_1.toCamelCase(arg.name);
        if (arg.parent) {
            var parent_1 = opts[arg.parent] || {};
            if (arg.parent === arg.name) {
                parent_1.enabled = arg.value;
            }
            else {
                parent_1[camelCase] = arg.value;
            }
            opts[arg.parent] = parent_1;
        }
        else {
            opts[camelCase] = arg.value;
        }
    });
    for (var i = 0; i < commands.length; i++) {
        //@ts-ignore
        var _a = __read(commands[i].match(reg) || [], 4), _ = _a[0], flag = _a[1], alias = _a[2], data = _a[3];
        if (flag) {
            if (!cliArgs.has(flag)) {
                throw new Error("Flag " + flag + " doesn't exist.");
            }
        }
        else if (alias) {
            if (!cliArgs.has(alias)) {
                throw new Error("Alias " + alias + " doesn't exist.");
            }
        }
        else {
            throw new Error("Command " + commands[i] + " is not valid.");
        }
        var arg = cliArgs.get(flag || alias);
        var value = void 0;
        if (data) {
            // Data from =(.*)
            value = arg.parse(data);
        }
        else if (arg.type === "bs") {
            // boolean flag or string, do not parse further
            value = true;
        }
        else if (arg.type === "b") {
            // boolean flag
            value = true;
        }
        else {
            if (i >= commands.length - 1) {
                throw new Error("Command line ended without last argument.");
            }
            if (commands[i + 1].match(invalidArg)) {
                throw new Error("Passed value " + commands[i + i] + " is invalid.");
            }
            i += 1; // increment index
            value = arg.parse(commands[i]); // Parse data
        }
        var name_1 = strings_1.toCamelCase(arg.name);
        if (arg.parent) {
            if (arg.parent == name_1) {
                name_1 = "enabled";
            }
            opts[arg.parent][name_1] = value;
            opts.changed.add(arg.parent + "." + name_1);
        }
        else {
            opts[name_1] = value;
            opts.changed.add(name_1);
        }
    }
    return opts;
}
exports.parse = parse;
//# sourceMappingURL=CommandLineArg.js.map