"use strict";
var __makeTemplateObject = (this && this.__makeTemplateObject) || function (cooked, raw) {
    if (Object.defineProperty) { Object.defineProperty(cooked, "raw", { value: raw }); } else { cooked.raw = raw; }
    return cooked;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
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
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __spread = (this && this.__spread) || function () {
    for (var ar = [], i = 0; i < arguments.length; i++) ar = ar.concat(__read(arguments[i]));
    return ar;
};
define("help", ["require", "exports", "chalk"], function (require, exports, chalk_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.help = void 0;
    chalk_1 = __importDefault(chalk_1);
    /**
     * @ignore
     *
     * This method prints the help text.
     */
    function help() {
        console.log(chalk_1.default(templateObject_1 || (templateObject_1 = __makeTemplateObject(["\n  {bold.blueBright SYNTAX}\n    {bold.green asp} --init                          Create a test config, an assembly/__tests__ folder and exit.\n    {bold.green asp} -i\n    {bold.green asp} --config=as-pect.config.js      Use a specified configuration\n    {bold.green asp} -c as-pect.config.js\n    {bold.green asp} --version                       View the version.\n    {bold.green asp} -v\n    {bold.green asp} --help                          Show this help screen.\n    {bold.green asp} -h\n    {bold.green asp} --types                         Copy the types file to assembly/__tests__/as-pect.d.ts\n    {bold.green asp} -t\n    {bold.green asp} --nologo                        Suppress ASCII art from printing.\n    {bold.green asp} --compiler                      Path to folder relative to project root which contains\n                                        {italic.magenta folder}/dist/asc for the compiler and {italic.magenta folder}/lib/loader for loader. {yellow (Default: assemblyscript)}\n\n  {bold.blueBright MODULE OPTIONS}\n    {bold.green --memory-size=[integer]}              Initial size of imported memory in pages of 64kb. {yellow (Default: 10 pages)}\n    {bold.green --memory-max=[integer]}               Set the maximum amount of memory pages the wasm test modules can use. {yellow (Default: -1)}\n\n  {bold.blueBright TEST OPTIONS}\n    {bold.green --file=[regex]}                       Run the tests of each file that matches this regex. {yellow (Default: /./)}\n      {bold.green --files=[regex]}\n      {bold.green -f=[regex]}\n\n    {bold.green --group=[regex]}                      Run each describe block that matches this regex {yellow (Default: /(:?)/)}\n      {bold.green --groups=[regex]}\n      {bold.green -g=[regex]}\n\n    {bold.green --test=[regex]}                       Run each test that matches this regex {yellow (Default: /(:?)/)}\n      {bold.green --tests=[regex]}\n      {bold.green -t=[regex]}\n\n    {bold.green --output-binary}                      Create a (.wasm) file can contains all the tests to be run later.\n      {bold.green -o}\n\n    {bold.green --norun}                              Skip running tests and output the compiler files.\n      {bold.green -n}\n\n    {bold.green --nortrace}                           Skip rtrace reference counting calculations.\n      {bold.green -nr}\n\n    {bold.green asp --workers} 3                      Enable the experimental worker worklets {yellow (default: 0 {gray [disabled]})}\n      {bold.green asp} -w\n\n    {bold.green --update}                             Update the snapshots for each tested module.\n      {bold.green asp} -u\n\n  {bold.blueBright REPORTER OPTIONS}\n    --summary                            Use the summary reporter. {yellow (This is the default if no reporter is specified.)}\n    --verbose                            Use a more verbose reporter.\n    --csv                                Use the csv reporter (output results to csv files.)\n    --json                               Use the json reporter (output results to json files.)\n    --reporter                           Define a custom reporter (path or module)\n  "], ["\n  {bold.blueBright SYNTAX}\n    {bold.green asp} --init                          Create a test config, an assembly/__tests__ folder and exit.\n    {bold.green asp} -i\n    {bold.green asp} --config=as-pect.config.js      Use a specified configuration\n    {bold.green asp} -c as-pect.config.js\n    {bold.green asp} --version                       View the version.\n    {bold.green asp} -v\n    {bold.green asp} --help                          Show this help screen.\n    {bold.green asp} -h\n    {bold.green asp} --types                         Copy the types file to assembly/__tests__/as-pect.d.ts\n    {bold.green asp} -t\n    {bold.green asp} --nologo                        Suppress ASCII art from printing.\n    {bold.green asp} --compiler                      Path to folder relative to project root which contains\n                                        {italic.magenta folder}/dist/asc for the compiler and {italic.magenta folder}/lib/loader for loader. {yellow (Default: assemblyscript)}\n\n  {bold.blueBright MODULE OPTIONS}\n    {bold.green --memory-size=[integer]}              Initial size of imported memory in pages of 64kb. {yellow (Default: 10 pages)}\n    {bold.green --memory-max=[integer]}               Set the maximum amount of memory pages the wasm test modules can use. {yellow (Default: -1)}\n\n  {bold.blueBright TEST OPTIONS}\n    {bold.green --file=[regex]}                       Run the tests of each file that matches this regex. {yellow (Default: /./)}\n      {bold.green --files=[regex]}\n      {bold.green -f=[regex]}\n\n    {bold.green --group=[regex]}                      Run each describe block that matches this regex {yellow (Default: /(:?)/)}\n      {bold.green --groups=[regex]}\n      {bold.green -g=[regex]}\n\n    {bold.green --test=[regex]}                       Run each test that matches this regex {yellow (Default: /(:?)/)}\n      {bold.green --tests=[regex]}\n      {bold.green -t=[regex]}\n\n    {bold.green --output-binary}                      Create a (.wasm) file can contains all the tests to be run later.\n      {bold.green -o}\n\n    {bold.green --norun}                              Skip running tests and output the compiler files.\n      {bold.green -n}\n\n    {bold.green --nortrace}                           Skip rtrace reference counting calculations.\n      {bold.green -nr}\n\n    {bold.green asp --workers} 3                      Enable the experimental worker worklets {yellow (default: 0 {gray [disabled]})}\n      {bold.green asp} -w\n\n    {bold.green --update}                             Update the snapshots for each tested module.\n      {bold.green asp} -u\n\n  {bold.blueBright REPORTER OPTIONS}\n    --summary                            Use the summary reporter. {yellow (This is the default if no reporter is specified.)}\n    --verbose                            Use a more verbose reporter.\n    --csv                                Use the csv reporter (output results to csv files.)\n    --json                               Use the json reporter (output results to json files.)\n    --reporter                           Define a custom reporter (path or module)\n  "]))));
    }
    exports.help = help;
    var templateObject_1;
});
define("util/strings", ["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.toCamelCase = exports.capitalize = void 0;
    /**
     * @ignore
     * Capitalize a word.
     *
     * @param {string} word - The word to be capitalized.
     */
    function capitalize(word) {
        return word[0].toLocaleUpperCase() + word.substring(1);
    }
    exports.capitalize = capitalize;
    /**
     * @ignore
     * CamelCase a single string. Usually used with `dash-cased` words.
     *
     * @param {string} str - The string to be camelCased.
     * @param {string} from - The string seperator.
     */
    function toCamelCase(str, from) {
        if (from === void 0) { from = "-"; }
        return str
            .split(from)
            .map(function (word, idx) { return (idx > 0 ? capitalize(word) : word); })
            .join("");
    }
    exports.toCamelCase = toCamelCase;
});
define("util/CommandLineArg", ["require", "exports", "util/strings"], function (require, exports, strings_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.parse = exports.defaultCliArgs = exports.makeArgMap = exports.CommandLineArg = void 0;
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
});
define("index", ["require", "exports", "util/CommandLineArg", "util/CommandLineArg"], function (require, exports, CommandLineArg_1, CommandLineArg_2) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.asp = exports.defaultCliArgs = exports.parse = exports.version = void 0;
    /**
     * @ignore
     *
     * Package version is always displayed, either for version or cli ascii art.
     */
    var pkg = require("../package.json");
    /**
     * This is the command line package version.
     */
    exports.version = pkg.version;
    Object.defineProperty(exports, "parse", { enumerable: true, get: function () { return CommandLineArg_2.parse; } });
    Object.defineProperty(exports, "defaultCliArgs", { enumerable: true, get: function () { return CommandLineArg_2.defaultCliArgs; } });
    /**
     * This is the cli entry point and expects an array of arguments from the command line.
     *
     * @param {string[]} args - The arguments from the command line
     */
    function asp(args) {
        var splitIndex = args.indexOf("--");
        var hasCompilerArgs = splitIndex !== -1;
        var aspectArgs = hasCompilerArgs
            ? args.slice(0, splitIndex)
            : args;
        var compilerArgs = hasCompilerArgs
            ? args.slice(splitIndex + 1)
            : [];
        // parse the arguments
        var cliOptions = CommandLineArg_1.parse(aspectArgs);
        // Skip ascii art if asked for the version
        if (!cliOptions.version && !cliOptions.nologo) {
            var printAsciiArt = require("./util/asciiArt").printAsciiArt;
            printAsciiArt(pkg.version);
        }
        if (cliOptions.types) {
            var types = require("./types").types;
            types();
        }
        else if (cliOptions.init) {
            var init = require("./init").init;
            // init script
            init();
        }
        else if (cliOptions.version) {
            // display the version
            console.log(pkg.version);
        }
        else if (cliOptions.help) {
            // display the help file
            var help = require("./help").help;
            help();
        }
        else if (cliOptions.portable) {
            var portable = require("./portable").portable;
            portable();
        }
        else {
            // run the compiler and test suite
            var run = require("./run").run;
            run(cliOptions, compilerArgs);
        }
    }
    exports.asp = asp;
    if (typeof require != "undefined" && require.main == module) {
        asp(process.argv.slice(2));
    }
});
define("init", ["require", "exports", "chalk", "fs", "path"], function (require, exports, chalk_2, fs_1, path_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.init = void 0;
    chalk_2 = __importDefault(chalk_2);
    /**
     * @ignore
     *
     * This method initializes a new test project. It is opinionated and reflects the needs of 99% of
     * AssemblyScript developers following the standard way of creating a new AssemblyScript project.
     */
    function init() {
        var assemblyFolder = path_1.join(process.cwd(), "assembly");
        var testFolder = path_1.join(assemblyFolder, "__tests__");
        var typesFileSource = require.resolve("@as-pect/cli/init/init-types.d.ts");
        var typesFile = path_1.join(testFolder, "as-pect.d.ts");
        console.log("");
        console.log(chalk_2.default(templateObject_2 || (templateObject_2 = __makeTemplateObject(["{bgWhite.black [Log]} Initializing test suite files."], ["{bgWhite.black [Log]} Initializing test suite files."]))));
        console.log("");
        // create the assembly folder if it doesn't exist
        if (!fs_1.existsSync(assemblyFolder)) {
            console.log(chalk_2.default(templateObject_3 || (templateObject_3 = __makeTemplateObject(["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/}"], ["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/}"]))));
            fs_1.mkdirSync(assemblyFolder);
        }
        // Create the test folder if it doesn't exist
        if (!fs_1.existsSync(testFolder)) {
            console.log(chalk_2.default(templateObject_4 || (templateObject_4 = __makeTemplateObject(["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/__tests__/}"], ["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/__tests__/}"]))));
            fs_1.mkdirSync(testFolder);
            // create the example file only if the __tests__ folder does not exist
            var exampleFile = path_1.join(testFolder, "example.spec.ts");
            var exampleFileSource = path_1.join(__dirname, "../init/example.spec.ts");
            if (!fs_1.existsSync(exampleFile)) {
                console.log(chalk_2.default(templateObject_5 || (templateObject_5 = __makeTemplateObject(["{bgWhite.black [Log]} Creating file: {yellow ./assembly/__tests__/example.spec.ts}"], ["{bgWhite.black [Log]} Creating file: {yellow ./assembly/__tests__/example.spec.ts}"]))));
                fs_1.createReadStream(exampleFileSource, "utf-8").pipe(fs_1.createWriteStream(exampleFile, "utf-8"));
            }
        }
        // create the types file if it doesn't exist for typescript tooling users
        if (!fs_1.existsSync(typesFile)) {
            console.log(chalk_2.default(templateObject_6 || (templateObject_6 = __makeTemplateObject(["{bgWhite.black [Log]} Creating file: {yellow ./assembly/__tests__/as-pect.d.ts}"], ["{bgWhite.black [Log]} Creating file: {yellow ./assembly/__tests__/as-pect.d.ts}"]))));
            fs_1.createReadStream(typesFileSource, "utf-8").pipe(fs_1.createWriteStream(typesFile, "utf-8"));
        }
        // create the default configuration file
        var configFile = path_1.join(process.cwd(), "as-pect.config.js");
        var configFileSource = path_1.join(__dirname, "../init/as-pect.config.js");
        if (!fs_1.existsSync(configFile)) {
            console.log(chalk_2.default(templateObject_7 || (templateObject_7 = __makeTemplateObject(["{bgWhite.black [Log]} Creating file: {yellow ./as-pect.config.js}"], ["{bgWhite.black [Log]} Creating file: {yellow ./as-pect.config.js}"]))));
            fs_1.createReadStream(configFileSource, "utf-8").pipe(fs_1.createWriteStream(configFile, "utf-8"));
        }
    }
    exports.init = init;
    var templateObject_2, templateObject_3, templateObject_4, templateObject_5, templateObject_6, templateObject_7;
});
define("portable", ["require", "exports", "chalk", "fs", "path"], function (require, exports, chalk_3, fs_2, path_2) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.portable = void 0;
    chalk_3 = __importDefault(chalk_3);
    /**
     * @ignore
     *
     * This method creates a portable types file to the current testing directory located at
     * `./assembly/__tests__/` for the current project.
     */
    function portable() {
        var assemblyFolder = path_2.join(process.cwd(), "assembly");
        var testFolder = path_2.join(assemblyFolder, "__tests__");
        var typesFileSource = require.resolve("@as-pect/cli/init/portable-types.d.ts");
        var typesFile = path_2.join(testFolder, "as-pect.d.ts");
        console.log("");
        console.log(chalk_3.default(templateObject_8 || (templateObject_8 = __makeTemplateObject(["{bgWhite.black [Log]} Initializing portable types."], ["{bgWhite.black [Log]} Initializing portable types."]))));
        console.log("");
        // Create the assembly folder if it doesn't exist
        if (!fs_2.existsSync(assemblyFolder)) {
            console.log(chalk_3.default(templateObject_9 || (templateObject_9 = __makeTemplateObject(["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/}"], ["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/}"]))));
            fs_2.mkdirSync(assemblyFolder);
        }
        // Create the test folder if it doesn't exist
        if (!fs_2.existsSync(testFolder)) {
            console.log(chalk_3.default(templateObject_10 || (templateObject_10 = __makeTemplateObject(["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/__tests__/}"], ["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/__tests__/}"]))));
            fs_2.mkdirSync(testFolder);
        }
        // Always create the types file
        console.log(chalk_3.default(templateObject_11 || (templateObject_11 = __makeTemplateObject(["{bgWhite.black [Log]} Creating file: {yellow ./assembly/__tests__/as-pect.d.ts}"], ["{bgWhite.black [Log]} Creating file: {yellow ./assembly/__tests__/as-pect.d.ts}"]))));
        fs_2.createReadStream(typesFileSource, "utf-8").pipe(fs_2.createWriteStream(typesFile, "utf-8"));
    }
    exports.portable = portable;
    var templateObject_8, templateObject_9, templateObject_10, templateObject_11;
});
define("util/IConfiguration", ["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
});
define("util/collectReporter", ["require", "exports", "querystring", "chalk"], function (require, exports, querystring_1, chalk_4) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.collectReporter = void 0;
    querystring_1 = __importDefault(querystring_1);
    chalk_4 = __importDefault(chalk_4);
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
            process.stdout.write(chalk_4.default(templateObject_12 || (templateObject_12 = __makeTemplateObject(["{bgWhite.black [Log]} Using {yellow CSVReporter}\n"], ["{bgWhite.black [Log]} Using {yellow CSVReporter}\\n"]))));
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
            process.stdout.write(chalk_4.default(templateObject_13 || (templateObject_13 = __makeTemplateObject(["{bgWhite.black [Log]} Using {yellow JSONReporter}\n"], ["{bgWhite.black [Log]} Using {yellow JSONReporter}\\n"]))));
        }
        if (cliOptions.verbose) {
            var VerboseReporter = require("@as-pect/core").VerboseReporter;
            var reporter = new VerboseReporter(typeof cliOptions.summary === "string"
                ? querystring_1.default.parse(cliOptions.summary || "")
                : {});
            reporter.stdout = process.stdout;
            reporter.stderr = process.stderr;
            reporters.push(reporter);
            process.stdout.write(chalk_4.default(templateObject_14 || (templateObject_14 = __makeTemplateObject(["{bgWhite.black [Log]} Using {yellow VerboseReporter}\n"], ["{bgWhite.black [Log]} Using {yellow VerboseReporter}\\n"]))));
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
                console.error(chalk_4.default(templateObject_15 || (templateObject_15 = __makeTemplateObject(["{red [Error]} Cannot find a reporter at {yellow ", "}"], ["{red [Error]} Cannot find a reporter at {yellow ", "}"])), url.pathname));
                console.error(ex);
                process.exit(1);
            }
            process.stdout.write(chalk_4.default(templateObject_16 || (templateObject_16 = __makeTemplateObject(["{bgWhite.black [Log]} Using custom reporter at: {yellow ", "}\n"], ["{bgWhite.black [Log]} Using custom reporter at: {yellow ", "}\\n"])), url.pathname));
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
            process.stdout.write(chalk_4.default(templateObject_17 || (templateObject_17 = __makeTemplateObject(["{bgWhite.black [Log]} Using {yellow SummaryReporter}\n"], ["{bgWhite.black [Log]} Using {yellow SummaryReporter}\\n"]))));
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
    var templateObject_12, templateObject_13, templateObject_14, templateObject_15, templateObject_16, templateObject_17;
});
define("util/getTestEntryFiles", ["require", "exports", "glob"], function (require, exports, glob_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.getTestEntryFiles = void 0;
    glob_1 = __importDefault(glob_1);
    /**
     * @ignore
     * This method returns a `Set<string>` of entry files for the compiler to compile.
     *
     * @param {Options} cliOptions - The command line arguments.
     * @param {string[]} include - An array of globs provided by the configuration.
     * @param {RegExp[]} disclude - An array of RegExp provided by the configuration.
     */
    function getTestEntryFiles(cliOptions, include, disclude) {
        var e_1, _a, e_2, _b, e_3, _c;
        var testEntryFiles = new Set();
        var fileRegexArg = cliOptions.file;
        var fileRegex = new RegExp(fileRegexArg);
        try {
            // for each pattern to be included
            for (var include_1 = __values(include), include_1_1 = include_1.next(); !include_1_1.done; include_1_1 = include_1.next()) {
                var pattern = include_1_1.value;
                try {
                    // push all the resulting files so that each file gets tested individually
                    entry: for (var _d = (e_2 = void 0, __values(glob_1.default.sync(pattern))), _e = _d.next(); !_e.done; _e = _d.next()) {
                        var entry = _e.value;
                        try {
                            // test for discludes
                            for (var disclude_1 = (e_3 = void 0, __values(disclude)), disclude_1_1 = disclude_1.next(); !disclude_1_1.done; disclude_1_1 = disclude_1.next()) {
                                var test_1 = disclude_1_1.value;
                                if (test_1.test(entry))
                                    continue entry;
                            }
                        }
                        catch (e_3_1) { e_3 = { error: e_3_1 }; }
                        finally {
                            try {
                                if (disclude_1_1 && !disclude_1_1.done && (_c = disclude_1.return)) _c.call(disclude_1);
                            }
                            finally { if (e_3) throw e_3.error; }
                        }
                        // if the fileRegex matches the test, add it to the entry file Set
                        if (fileRegex.test(entry))
                            testEntryFiles.add(entry);
                    }
                }
                catch (e_2_1) { e_2 = { error: e_2_1 }; }
                finally {
                    try {
                        if (_e && !_e.done && (_b = _d.return)) _b.call(_d);
                    }
                    finally { if (e_2) throw e_2.error; }
                }
            }
        }
        catch (e_1_1) { e_1 = { error: e_1_1 }; }
        finally {
            try {
                if (include_1_1 && !include_1_1.done && (_a = include_1.return)) _a.call(include_1);
            }
            finally { if (e_1) throw e_1.error; }
        }
        return testEntryFiles;
    }
    exports.getTestEntryFiles = getTestEntryFiles;
});
define("util/writeFile", ["require", "exports", "fs"], function (require, exports, fs_3) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.writeFile = void 0;
    /**
     * @ignore
     * This method promisifies the fs.writeFile function call, and is compatible with node 10.
     *
     * @param {string} file - The file location to write to.
     * @param {Uint8Array} contents - The file contents to write to the disk.
     */
    function writeFile(file, contents) {
        return new Promise(function (resolve, reject) {
            fs_3.writeFile(file, contents, function (err) {
                if (err)
                    reject(err);
                else
                    resolve();
            });
        });
    }
    exports.writeFile = writeFile;
});
define("worklets/ICommand", ["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
});
define("util/removeFile", ["require", "exports", "fs"], function (require, exports, fs_4) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.removeFile = void 0;
    /**
     * @ignore
     * This method promisifies the fs.writeFile function call, and is compatible with node 10.
     *
     * @param {string} file - The file location to write to.
     */
    function removeFile(file) {
        return new Promise(function (resolve, reject) {
            fs_4.unlink(file, function (err) {
                if (err)
                    reject(err);
                else
                    resolve();
            });
        });
    }
    exports.removeFile = removeFile;
});
define("run", ["require", "exports", "fs", "perf_hooks", "path", "chalk", "@as-pect/core", "glob", "util/collectReporter", "util/getTestEntryFiles", "util/writeFile", "@as-pect/core/lib/util/timeDifference", "@as-pect/snapshots", "util/removeFile"], function (require, exports, fs, perf_hooks_1, path, chalk_5, core_1, glob_2, collectReporter_1, getTestEntryFiles_1, writeFile_1, timeDifference_1, snapshots_1, removeFile_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.run = void 0;
    fs = __importStar(fs);
    path = __importStar(path);
    chalk_5 = __importDefault(chalk_5);
    glob_2 = __importDefault(glob_2);
    /**
     * @ignore
     * This method actually runs the test suites in sequential order synchronously.
     *
     * @param {Options} cliOptions - The command line arguments.
     * @param {string[]} compilerArgs - The `asc` compiler arguments.
     */
    function run(cliOptions, compilerArgs) {
        var e_4, _a, e_5, _b, e_6, _c;
        var _d, _e, _f;
        var start = perf_hooks_1.performance.now();
        var worklets = [];
        /** Collect the assemblyscript module path. */
        var assemblyScriptFolder = cliOptions.compiler.startsWith(".")
            ? path.join(process.cwd(), cliOptions.compiler)
            : cliOptions.compiler;
        /**
         * Create the compiler worklets if the worker flag is not 0.
         */
        if (cliOptions.workers !== 0) {
            var Worker_1 = require("worker_threads").Worker;
            if (!isFinite(cliOptions.workers)) {
                console.error(chalk_5.default(templateObject_18 || (templateObject_18 = __makeTemplateObject(["{red [Error]} Invalid worker configuration: {yellow ", "}"], ["{red [Error]} Invalid worker configuration: {yellow ", "}"])), cliOptions.workers.toString()));
                process.exit(1);
            }
            var workletPath = require.resolve("./worklets/compiler");
            for (var i = 0; i < cliOptions.workers; i++) {
                var worklet = new Worker_1(workletPath, {
                    workerData: {
                        assemblyScriptFolder: assemblyScriptFolder,
                    },
                });
                worklets.push(worklet);
            }
            console.log(chalk_5.default(templateObject_19 || (templateObject_19 = __makeTemplateObject(["{bgWhite.black [Log]} Using experimental compiler worklets: {yellow ", " worklets}"], ["{bgWhite.black [Log]} Using experimental compiler worklets: {yellow ", " worklets}"])), worklets.length.toString()));
        }
        /**
         * Instead of using `import`, the strategy is to encourage node to start the testing process
         * as soon as possible. Calling require and measuring the performance of compiler loading shows
         * developers a meaningful explaination of why it takes a few seconds for the software to start
         * running.
         */
        console.log(chalk_5.default(templateObject_20 || (templateObject_20 = __makeTemplateObject(["{bgWhite.black [Log]} Loading asc compiler"], ["{bgWhite.black [Log]} Loading asc compiler"]))));
        var asc;
        var instantiateSync;
        var parse;
        var exportTable = false;
        try {
            var folderUsed = "cli";
            try {
                console.log("Assemblyscript Folder:" + assemblyScriptFolder);
                /** Next, obtain the compiler, and assert it has a main function. */
                asc = require(path.join(assemblyScriptFolder, "cli", "asc"));
            }
            catch (ex) {
                try {
                    folderUsed = "dist";
                    asc = require(path.join(assemblyScriptFolder, "dist", "asc"));
                }
                catch (ex) {
                    throw ex;
                }
            }
            if (!asc) {
                throw new Error(cliOptions.compiler + "/" + folderUsed + "/asc has no exports.");
            }
            if (!asc.main) {
                throw new Error(cliOptions.compiler + "/" + folderUsed + "/asc does not export a main() function.");
            }
            /** Next, collect the loader, and assert it has an instantiateSync method. */
            var loader = void 0;
            try {
                loader = require(path.join(assemblyScriptFolder, "lib", "loader"));
            }
            catch (ex) {
                loader = require(path.join(assemblyScriptFolder, "lib", "loader", "umd"));
            }
            if (!loader) {
                throw new Error(cliOptions.compiler + "/lib/loader has no exports.");
            }
            if (!loader.instantiateSync) {
                throw new Error(cliOptions.compiler + "/lib/loader does not export an instantiateSync() method.");
            }
            instantiateSync = loader.instantiateSync;
            /** Finally, collect the cli options from assemblyscript. */
            var options = require(path.join(assemblyScriptFolder, "cli", "util", "options"));
            if (!options) {
                throw new Error(cliOptions.compiler + "/cli/util/options exports null");
            }
            if (!options.parse) {
                throw new Error(cliOptions.compiler + "/cli/util/options does not export a parse() method.");
            }
            if (asc.options.exportTable) {
                exportTable = true;
            }
            parse = options.parse;
        }
        catch (ex) {
            console.error(chalk_5.default(templateObject_21 || (templateObject_21 = __makeTemplateObject(["{bgRedBright.black [Error]} There was a problem loading {bold [", "]}."], ["{bgRedBright.black [Error]} There was a problem loading {bold [", "]}."])), cliOptions.compiler));
            console.error(ex);
            process.exit(1);
        }
        console.log(chalk_5.default(templateObject_22 || (templateObject_22 = __makeTemplateObject(["{bgWhite.black [Log]} Compiler loaded in {yellow ", "ms}."], ["{bgWhite.black [Log]} Compiler loaded in {yellow ",
            "ms}."])), timeDifference_1.timeDifference(perf_hooks_1.performance.now(), start).toString()));
        // obtain the configuration file
        var configurationPath = path.resolve(process.cwd(), cliOptions.config);
        console.log(chalk_5.default(templateObject_23 || (templateObject_23 = __makeTemplateObject(["{bgWhite.black [Log]} Using configuration {yellow ", "}"], ["{bgWhite.black [Log]} Using configuration {yellow ", "}"])), configurationPath));
        var configuration = {};
        try {
            configuration = require(configurationPath) || {};
        }
        catch (ex) {
            console.error("");
            console.error(chalk_5.default(templateObject_24 || (templateObject_24 = __makeTemplateObject(["{bgRedBright.black [Error]} There was a problem loading {bold [", "]}."], ["{bgRedBright.black [Error]} There was a problem loading {bold [", "]}."])), configurationPath));
            console.error(ex);
            process.exit(1);
        }
        // configuration must be an object
        if (!configuration) {
            console.error(chalk_5.default(templateObject_25 || (templateObject_25 = __makeTemplateObject(["{bgRedBright.black [Error]} Configuration at {bold [", "]} is null or not an object."], ["{bgRedBright.black [Error]} Configuration at {bold [", "]} is null or not an object."])), configurationPath));
            process.exit(1);
        }
        var include = configuration.include || [
            "assembly/__tests__/**/*.spec.ts",
        ];
        var add = configuration.add || [
            "assembly/__tests__/**/*.include.ts",
        ];
        // parse passed cli compiler arguments and determine if there are any bad arguments.
        if (compilerArgs.length > 0) {
            var output = parse(compilerArgs, asc.options);
            // if there are any unknown flags, report them and exit 1
            if (output.unknown.length > 0) {
                console.error(chalk_5.default(templateObject_26 || (templateObject_26 = __makeTemplateObject(["{bgRedBright.black [Error]} Unknown compiler arguments {bold.yellow [", "]}."], ["{bgRedBright.black [Error]} Unknown compiler arguments {bold.yellow [",
                    "]}."])), output.unknown.join(", ")));
                process.exit(1);
            }
        }
        // Create the compiler flags
        var flags = Object.assign({}, configuration.flags, {
            "--debug": [],
            "--binaryFile": ["output.wasm"],
            "--explicitStart": [],
        });
        if (!flags["--use"] ||
            flags["--use"].includes("ASC_RTRACE=1") ||
            !compilerArgs.includes("ASC_RTRACE=1")) {
            if (!flags["--use"]) {
                flags["--use"] = ["ASC_RTRACE=1"];
                // inspect to see if the flag is used already
            }
            else if (!flags["--use"].includes("ASC_RTRACE=1")) {
                flags["--use"].push("--use", "ASC_RTRACE=1");
            }
        }
        /** If the export table flag exists on the cli options, use the export table flag. */
        if (exportTable) {
            flags["--exportTable"] = [];
        }
        /** Always import the memory now so that we expose the WebAssembly.Memory object to imports. */
        flags["--importMemory"] = [];
        /** It's useful to notify the user that optimizations will make test compile times slower. */
        if (flags.hasOwnProperty("-O3") ||
            flags.hasOwnProperty("-O2") ||
            flags.hasOwnProperty("--optimize") ||
            compilerArgs.includes("-O3") ||
            compilerArgs.includes("-O2") ||
            compilerArgs.includes("--optimize")) {
            console.log(chalk_5.default(templateObject_27 || (templateObject_27 = __makeTemplateObject(["{yellow [Warning]} Using optimizations. This may result in slow test compilation times."], ["{yellow [Warning]} Using optimizations. This may result in slow test compilation times."]))));
        }
        var disclude = configuration.disclude || [];
        // if a reporter is specified in cli arguments, override configuration
        var reporter = configuration.reporter || collectReporter_1.collectReporter(cliOptions);
        // include all the file globs
        console.log(chalk_5.default(templateObject_28 || (templateObject_28 = __makeTemplateObject(["{bgWhite.black [Log]} Including files: ", ""], ["{bgWhite.black [Log]} Including files: ", ""])), include.join(", ")));
        // Create the test and group matchers
        var testRegex = new RegExp(cliOptions.test, "i");
        configuration.testRegex = testRegex;
        console.log(chalk_5.default(templateObject_29 || (templateObject_29 = __makeTemplateObject(["{bgWhite.black [Log]} Running tests that match: {yellow ", "}"], ["{bgWhite.black [Log]} Running tests that match: {yellow ", "}"])), testRegex.source));
        var groupRegex = new RegExp(cliOptions.group, "i");
        configuration.groupRegex = groupRegex;
        console.log(chalk_5.default(templateObject_30 || (templateObject_30 = __makeTemplateObject(["{bgWhite.black [Log]} Running groups that match: {yellow ", "}"], ["{bgWhite.black [Log]} Running groups that match: {yellow ", "}"])), groupRegex.source));
        /**
         * Check to see if the binary files should be written to the fileSystem.
         */
        var outputBinary = (_d = (cliOptions.changed.has("outputBinary")
            ? cliOptions.outputBinary
            : configuration.outputBinary)) !== null && _d !== void 0 ? _d : false;
        if (outputBinary) {
            console.log(chalk_5.default(templateObject_31 || (templateObject_31 = __makeTemplateObject(["{bgWhite.black [Log]} Outputing Binary *.wasm files."], ["{bgWhite.black [Log]} Outputing Binary *.wasm files."]))));
        }
        /**
         * Check to see if the tests should be run in the first place.
         */
        var runTests = !cliOptions.norun;
        if (!runTests) {
            console.log(chalk_5.default(templateObject_32 || (templateObject_32 = __makeTemplateObject(["{bgWhite.black [Log]} Not running tests, only outputting files."], ["{bgWhite.black [Log]} Not running tests, only outputting files."]))));
        }
        /**
         * Check for memory flags from the cli options.
         */
        var memorySize = (_e = (cliOptions.changed.has("memorySize")
            ? cliOptions.memorySize
            : configuration.memorySize)) !== null && _e !== void 0 ? _e : 10;
        var memoryMax = (_f = (cliOptions.changed.has("memoryMax")
            ? cliOptions.memoryMax
            : configuration.memoryMax)) !== null && _f !== void 0 ? _f : -1;
        if (!Number.isInteger(memorySize) || memorySize <= 0) {
            console.error(chalk_5.default(templateObject_33 || (templateObject_33 = __makeTemplateObject(["{red [Error]} Invalid {yellow memorySize} value (", ") [valid range is a positive interger]"], ["{red [Error]} Invalid {yellow memorySize} value (", ") [valid range is a positive interger]"])), memorySize));
            process.exit(1);
        }
        if (!Number.isInteger(memoryMax) || memoryMax < -1) {
            console.error(chalk_5.default(templateObject_34 || (templateObject_34 = __makeTemplateObject(["{red [Error]} Invalid {yellow memoryMax} value (", ") [valid range is a positive interger greater than {yellow memorySize}]"], ["{red [Error]} Invalid {yellow memoryMax} value (", ") [valid range is a positive interger greater than {yellow memorySize}]"])), memoryMax));
            process.exit(1);
        }
        if (memoryMax > 0 && memoryMax < memorySize) {
            console.error(chalk_5.default(templateObject_35 || (templateObject_35 = __makeTemplateObject(["{red [Error]} Invalid module memory configuration, memorySize (", ") is greater than memoryMax (", ")."], ["{red [Error]} Invalid module memory configuration, memorySize (", ") is greater than memoryMax (", ")."])), memorySize, memoryMax));
            process.exit(1);
        }
        /**
         * Add the proper trasform.
         */
        flags["--transform"] = flags["--transform"] || [];
        flags["--transform"].push(require.resolve("@as-pect/core/lib/transform"));
        /**
         * Concatenate compiler flags.
         */
        if (compilerArgs.length > 0) {
            console.log(chalk_5.default(templateObject_36 || (templateObject_36 = __makeTemplateObject(["{bgWhite.black [Log]} Adding compiler arguments: "], ["{bgWhite.black [Log]} Adding compiler arguments: "]))) +
                compilerArgs.join(" "));
        }
        var addedTestEntryFiles = new Set();
        /** Get all the test entry files. */
        var testEntryFiles = getTestEntryFiles_1.getTestEntryFiles(cliOptions, include, disclude);
        if (testEntryFiles.size === 0) {
            console.error(chalk_5.default(templateObject_37 || (templateObject_37 = __makeTemplateObject(["{red [Error]} No files matching the pattern were found."], ["{red [Error]} No files matching the pattern were found."]))));
            process.exit(1);
        }
        try {
            for (var add_1 = __values(add), add_1_1 = add_1.next(); !add_1_1.done; add_1_1 = add_1.next()) {
                var pattern = add_1_1.value;
                try {
                    // push all the added files to the added entry point list
                    for (var _g = (e_5 = void 0, __values(glob_2.default.sync(pattern))), _h = _g.next(); !_h.done; _h = _g.next()) {
                        var entry = _h.value;
                        addedTestEntryFiles.add(entry);
                    }
                }
                catch (e_5_1) { e_5 = { error: e_5_1 }; }
                finally {
                    try {
                        if (_h && !_h.done && (_b = _g.return)) _b.call(_g);
                    }
                    finally { if (e_5) throw e_5.error; }
                }
            }
        }
        catch (e_4_1) { e_4 = { error: e_4_1 }; }
        finally {
            try {
                if (add_1_1 && !add_1_1.done && (_a = add_1.return)) _a.call(add_1);
            }
            finally { if (e_4) throw e_4.error; }
        }
        // must include the assembly/index.ts file located in the assembly package
        var entryPath = require.resolve("@as-pect/assembly/assembly/index.ts");
        var relativeEntryPath = path.relative(process.cwd(), entryPath);
        // add the relativeEntryPath of as-pect to the list of compiled files for each test
        addedTestEntryFiles.add(relativeEntryPath);
        // Create a test runner, and run each test
        var count = testEntryFiles.size;
        // create the array of compiler flags from the flags object
        var flagList = Object.entries(flags)
            .reduce(function (args, _a) {
            var _b = __read(_a, 2), flag = _b[0], options = _b[1];
            return args.concat(flag, options.length == 0 || typeof options == "string"
                ? options
                : options.join(","));
        }, [])
            .concat(compilerArgs);
        var testCount = 0;
        var successCount = 0;
        var groupSuccessCount = 0;
        var groupCount = 0;
        var errors = [];
        var filePromises = [];
        var failed = false;
        var folderMap = new Map();
        var fileMap = new Map();
        console.log(chalk_5.default(templateObject_38 || (templateObject_38 = __makeTemplateObject(["{bgWhite.black [Log]} Effective command line args:"], ["{bgWhite.black [Log]} Effective command line args:"]))));
        console.log(chalk_5.default(templateObject_39 || (templateObject_39 = __makeTemplateObject(["  {green [TestFile.ts]} {yellow ", "} ", ""], ["  {green [TestFile.ts]} {yellow ",
            "} ", ""])), Array.from(addedTestEntryFiles).join(" "), flagList.join(" ")));
        // add a line seperator between the next line and this line
        console.log("");
        var finalCompilerArguments = __spread(Array.from(addedTestEntryFiles), flagList);
        function runBinary(error, file, binary) {
            var e_7, _a, e_8, _b, e_9, _c;
            var _d;
            // if there are any compilation errors, stop the test suite
            if (error) {
                console.error(chalk_5.default(templateObject_40 || (templateObject_40 = __makeTemplateObject(["{red [Error]} There was a compilation error when trying to create the wasm binary for file: ", "."], ["{red [Error]} There was a compilation error when trying to create the wasm binary for file: ", "."])), file));
                console.error(error);
                return process.exit(1);
            }
            // if the binary wasn't emitted, stop the test suite
            if (!binary) {
                console.error(chalk_5.default(templateObject_41 || (templateObject_41 = __makeTemplateObject(["{red [Error]} There was no output binary file: ", ". Did you forget to emit the binary with {yellow --binaryFile}?"], ["{red [Error]} There was no output binary file: ", ". Did you forget to emit the binary with {yellow --binaryFile}?"])), file));
                return process.exit(1);
            }
            if (runTests) {
                // get the folder and test basename
                var testFolderName = path.dirname(file);
                var testBaseName = path.basename(file, path.extname(file));
                var snapshotFolder = path.resolve(path.join(testFolderName, "__snapshots__"));
                // collect the expected snapshots
                var snapshotsLocation = path.join(snapshotFolder, testBaseName + ".snap");
                var wasi = null;
                if (configuration.wasi) {
                    var WASI = require("wasi").WASI;
                    wasi = new WASI(configuration.wasi);
                }
                // create a test runner
                var runner = new core_1.TestContext({
                    fileName: file,
                    groupRegex: configuration.groupRegex,
                    testRegex: configuration.testRegex,
                    reporter: reporter,
                    binary: binary,
                    snapshots: fs.existsSync(snapshotsLocation)
                        ? snapshots_1.Snapshot.parse(fs.readFileSync(snapshotsLocation, "utf8"))
                        : new snapshots_1.Snapshot(),
                    wasi: wasi,
                });
                // detect custom imports
                var customImportFileLocation = path.resolve(path.join(testFolderName, testBaseName + ".imports.js"));
                var configurationImports = fs.existsSync(customImportFileLocation)
                    ? require(customImportFileLocation)
                    : (_d = configuration.imports) !== null && _d !== void 0 ? _d : {};
                var memoryDescriptor = {
                    initial: memorySize,
                };
                if (memoryMax > 0) {
                    memoryDescriptor.maximum = memoryMax;
                }
                var memory = new WebAssembly.Memory(memoryDescriptor);
                var result = void 0;
                if (typeof configurationImports === "function") {
                    var createImports = runner.createImports.bind(runner, {
                        env: { memory: memory },
                    });
                    result = configurationImports(memory, createImports, instantiateSync, binary);
                    if (!result) {
                        console.error(chalk_5.default(templateObject_42 || (templateObject_42 = __makeTemplateObject(["{red [Error]} Imports configuration function did not return an AssemblyScript module. (Did you forget to return it?)"], ["{red [Error]} Imports configuration function did not return an AssemblyScript module. (Did you forget to return it?)"]))));
                        process.exit(1);
                    }
                }
                else {
                    var imports = runner.createImports(configurationImports);
                    imports.env.memory = memory;
                    result = instantiateSync(binary, imports);
                }
                if (runner.errors.length > 0) {
                    errors.push.apply(errors, __spread(runner.errors));
                }
                else {
                    // call run buffer because it's already compiled
                    runner.run(result);
                    var runnerTestCount = runner.testCount;
                    var runnerTestPassCount = runner.testPassCount;
                    var runnerGroupCount = runner.groupCount;
                    var runnerGroupPassCount = runner.groupPassCount;
                    // a snapshot may have failed or a test may have failed
                    if (!runner.pass) {
                        // if we are updating snapshots
                        if (cliOptions.update) {
                            // check the pass count, because we are ignoring snapshot results
                            if (runnerTestCount !== runnerTestPassCount ||
                                runnerGroupCount !== runnerGroupPassCount) {
                                failed = true;
                            }
                        }
                        else {
                            failed = true;
                        }
                    }
                    // statistics
                    testCount += runnerTestCount;
                    successCount += runnerTestPassCount;
                    groupCount += runnerGroupCount;
                    groupSuccessCount += runnerGroupPassCount;
                    errors.push.apply(errors, __spread(runner.errors)); // if there are any errors, add them
                    // if the update flag was passed, update the snapshots
                    if (cliOptions.update) {
                        var snapshots = runner.snapshots;
                        if (snapshots.values.size > 0) {
                            var output = snapshots.stringify();
                            if (!fs.existsSync(snapshotFolder))
                                fs.mkdirSync(snapshotFolder);
                            filePromises.push(writeFile_1.writeFile(snapshotsLocation, output));
                        }
                        else {
                            if (fs.existsSync(snapshotsLocation)) {
                                filePromises.push(removeFile_1.removeFile(snapshotsLocation));
                            }
                        }
                    }
                    else {
                        // check for any added snapshots
                        var result_1 = runner.expectedSnapshots;
                        var diff = runner.snapshotDiff;
                        try {
                            for (var _e = __values(diff.results.entries()), _f = _e.next(); !_f.done; _f = _e.next()) {
                                var _g = __read(_f.value, 2), name_2 = _g[0], diffResult = _g[1];
                                if (diffResult.type === 1 /* Added */) {
                                    result_1.values.set(name_2, diffResult.left);
                                }
                            }
                        }
                        catch (e_7_1) { e_7 = { error: e_7_1 }; }
                        finally {
                            try {
                                if (_f && !_f.done && (_a = _e.return)) _a.call(_e);
                            }
                            finally { if (e_7) throw e_7.error; }
                        }
                        // if there are any snapshots to report, report them
                        if (result_1.values.size > 0) {
                            var output = result_1.stringify();
                            if (!fs.existsSync(snapshotFolder))
                                fs.mkdirSync(snapshotFolder);
                            filePromises.push(writeFile_1.writeFile(snapshotsLocation, output));
                        }
                    }
                }
            }
            count -= 1;
            // if any tests failed, and they all ran, exit(1)
            if (count === 0) {
                if (runTests) {
                    var end = perf_hooks_1.performance.now();
                    failed = failed || errors.length > 0;
                    var result = failed ? chalk_5.default(templateObject_43 || (templateObject_43 = __makeTemplateObject(["{red \u2716 FAIL}"], ["{red \u2716 FAIL}"]))) : chalk_5.default(templateObject_44 || (templateObject_44 = __makeTemplateObject(["{green \u2714 PASS}"], ["{green \u2714 PASS}"])));
                    try {
                        for (var errors_1 = __values(errors), errors_1_1 = errors_1.next(); !errors_1_1.done; errors_1_1 = errors_1.next()) {
                            var error_1 = errors_1_1.value;
                            console.log(chalk_5.default(templateObject_45 || (templateObject_45 = __makeTemplateObject(["\n [Error]: {red ", "}: ", "\n [Stack]: {yellow ", "}\n"], ["\n [Error]: {red ", "}: ", "\n [Stack]: {yellow ", "}\n"])), error_1.type, error_1.message, error_1.stackTrace.split("\n").join("\n            ")));
                        }
                    }
                    catch (e_8_1) { e_8 = { error: e_8_1 }; }
                    finally {
                        try {
                            if (errors_1_1 && !errors_1_1.done && (_b = errors_1.return)) _b.call(errors_1);
                        }
                        finally { if (e_8) throw e_8.error; }
                    }
                    console.log(chalk_5.default(templateObject_46 || (templateObject_46 = __makeTemplateObject(["  [Result]: ", "\n   [Files]: ", " total\n  [Groups]: ", " count, ", " pass\n   [Tests]: ", " pass, ", " fail, ", " total\n    [Time]: ", "ms"], ["  [Result]: ", "\n   [Files]: ", " total\n  [Groups]: ", " count, ", " pass\n   [Tests]: ", " pass, ",
                        " fail, ", " total\n    [Time]: ", "ms"])), result, testEntryFiles.size.toString(), groupCount.toString(), groupSuccessCount.toString(), successCount.toString(), (testCount - successCount).toString(), testCount.toString(), timeDifference_1.timeDifference(end, start).toString()));
                    if (worklets.length > 0) {
                        try {
                            for (var worklets_1 = __values(worklets), worklets_1_1 = worklets_1.next(); !worklets_1_1.done; worklets_1_1 = worklets_1.next()) {
                                var worklet = worklets_1_1.value;
                                worklet.terminate();
                            }
                        }
                        catch (e_9_1) { e_9 = { error: e_9_1 }; }
                        finally {
                            try {
                                if (worklets_1_1 && !worklets_1_1.done && (_c = worklets_1.return)) _c.call(worklets_1);
                            }
                            finally { if (e_9) throw e_9.error; }
                        }
                    }
                }
                Promise.all(filePromises).then(function () {
                    if (failed) {
                        console.error(errors);
                        process.exit(1);
                    }
                });
            }
            return 0;
        }
        if (worklets.length > 0) {
            var i = 0;
            var length_1 = worklets.length;
            try {
                for (var _j = __values(Array.from(testEntryFiles)), _k = _j.next(); !_k.done; _k = _j.next()) {
                    var entry = _k.value;
                    var workload = {
                        type: "compile",
                        props: {
                            file: entry,
                            args: __spread([entry], finalCompilerArguments),
                            outputBinary: outputBinary,
                        },
                    };
                    worklets[i % length_1].postMessage(workload);
                }
            }
            catch (e_6_1) { e_6 = { error: e_6_1 }; }
            finally {
                try {
                    if (_k && !_k.done && (_c = _j.return)) _c.call(_j);
                }
                finally { if (e_6) throw e_6.error; }
            }
            worklets.forEach(function (worklet) {
                worklet.on("message", function (e) {
                    runBinary(e.props.error, e.props.file, e.props.binary);
                });
            });
        }
        else {
            // for each file, synchronously run each test
            Array.from(testEntryFiles).forEach(function (file) {
                var binary;
                asc.main(__spread([file], finalCompilerArguments), {
                    stdout: process.stdout,
                    stderr: process.stderr,
                    listFiles: function (dirname, baseDir) {
                        var folder = path.join(baseDir, dirname);
                        if (folderMap.has(folder)) {
                            return folderMap.get(folder);
                        }
                        try {
                            var results = fs
                                .readdirSync(folder)
                                .filter(function (file) { return /^(?!.*\.d\.ts$).*\.ts$/.test(file); });
                            folderMap.set(folder, results);
                            return results;
                        }
                        catch (e) {
                            return [];
                        }
                    },
                    readFile: function (filename, baseDir) {
                        var fileName = path.join(baseDir, filename);
                        if (fileMap.has(fileName)) {
                            return fileMap.get(fileName);
                        }
                        try {
                            var contents = fs.readFileSync(fileName, { encoding: "utf8" });
                            fileMap.set(fileName, contents);
                            return contents;
                        }
                        catch (e) {
                            return null;
                        }
                    },
                    writeFile: function (name, contents, baseDir) {
                        if (baseDir === void 0) { baseDir = "."; }
                        var ext = path.extname(name);
                        // get the wasm file
                        if (ext === ".wasm") {
                            binary = contents;
                            if (!outputBinary)
                                return;
                        }
                        else if (ext === ".ts") {
                            filePromises.push(writeFile_1.writeFile(path.join(baseDir, name), contents));
                            return;
                        }
                        var outfileName = path.join(path.dirname(file), path.basename(file, path.extname(file)) + ext);
                        filePromises.push(writeFile_1.writeFile(outfileName, contents));
                    },
                }, function (error) { return runBinary(error, file, binary); });
            });
        }
    }
    exports.run = run;
    var templateObject_18, templateObject_19, templateObject_20, templateObject_21, templateObject_22, templateObject_23, templateObject_24, templateObject_25, templateObject_26, templateObject_27, templateObject_28, templateObject_29, templateObject_30, templateObject_31, templateObject_32, templateObject_33, templateObject_34, templateObject_35, templateObject_36, templateObject_37, templateObject_38, templateObject_39, templateObject_40, templateObject_41, templateObject_42, templateObject_43, templateObject_44, templateObject_45, templateObject_46;
});
require("../lib/index.js").asp(process.argv.slice(2));
define("types", ["require", "exports", "chalk", "fs", "path"], function (require, exports, chalk_6, fs_5, path_3) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.types = void 0;
    chalk_6 = __importDefault(chalk_6);
    /**
     * @ignore
     *
     * This method creates a types file to the current testing directory located at
     * `./assembly/__tests__/` for the current project.
     */
    function types() {
        var assemblyFolder = path_3.join(process.cwd(), "assembly");
        var testFolder = path_3.join(assemblyFolder, "__tests__");
        var typesFileSource = require.resolve("@as-pect/cli/init/init-types.d.ts");
        var typesFile = path_3.join(testFolder, "as-pect.d.ts");
        console.log("");
        console.log(chalk_6.default(templateObject_47 || (templateObject_47 = __makeTemplateObject(["{bgWhite.black [Log]} Initializing types."], ["{bgWhite.black [Log]} Initializing types."]))));
        console.log("");
        // Create the assembly folder if it doesn't exist
        if (!fs_5.existsSync(assemblyFolder)) {
            console.log(chalk_6.default(templateObject_48 || (templateObject_48 = __makeTemplateObject(["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/}"], ["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/}"]))));
            fs_5.mkdirSync(assemblyFolder);
        }
        // Create the test folder if it doesn't exist
        if (!fs_5.existsSync(testFolder)) {
            console.log(chalk_6.default(templateObject_49 || (templateObject_49 = __makeTemplateObject(["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/__tests__/}"], ["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/__tests__/}"]))));
            fs_5.mkdirSync(testFolder);
        }
        // Always create the types file
        console.log(chalk_6.default(templateObject_50 || (templateObject_50 = __makeTemplateObject(["{bgWhite.black [Log]} Creating file: {yellow ./assembly/__tests__/as-pect.d.ts}"], ["{bgWhite.black [Log]} Creating file: {yellow ./assembly/__tests__/as-pect.d.ts}"]))));
        fs_5.createReadStream(typesFileSource, "utf-8").pipe(fs_5.createWriteStream(typesFile, "utf-8"));
    }
    exports.types = types;
    var templateObject_47, templateObject_48, templateObject_49, templateObject_50;
});
define("util/asciiArt", ["require", "exports", "chalk"], function (require, exports, chalk_7) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.printAsciiArt = void 0;
    chalk_7 = __importDefault(chalk_7);
    /**
     * @ignore
     *
     * This method prints the ascii art.
     * @param {string} version - The cli version
     */
    function printAsciiArt(version) {
        console.log(chalk_7.default(templateObject_51 || (templateObject_51 = __makeTemplateObject(["{bold.bgWhite.black ", "       ___   _____                       __    \n      /   | / ___/      ____  ___  _____/ /_   \n     / /| | \\__ \\______/ __ \\/ _ \\/ ___/ __/   \n    / ___ |___/ /_____/ /_/ /  __/ /__/ /_     \n   /_/  |_/____/     / .___/\\___/\\___/\\__/     \n                    /_/                        }\n\n\u26A1AS-pect\u26A1 Test suite runner {bgGreenBright.bold.black [", "]}\n"], ["{bold.bgWhite.black ", "       ___   _____                       __    \n      /   | / ___/      ____  ___  _____/ /_   \n     / /| | \\\\__ \\\\______/ __ \\\\/ _ \\\\/ ___/ __/   \n    / ___ |___/ /_____/ /_/ /  __/ /__/ /_     \n   /_/  |_/____/     / .___/\\\\___/\\\\___/\\\\__/     \n                    /_/                        }\n\n\u26A1AS-pect\u26A1 Test suite runner {bgGreenBright.bold.black [", "]}\n"])), "", version));
    }
    exports.printAsciiArt = printAsciiArt;
    var templateObject_51;
});
define("worklets/compiler", ["require", "exports", "fs", "path", "worker_threads", "util/writeFile"], function (require, exports, fs_6, path_4, worker_threads_1, writeFile_2) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    /**
     * @ignore
     *
     * This variable holds the AssemblyScript compiler.
     */
    var asc = require(path_4.join(worker_threads_1.workerData.assemblyScriptFolder, "dist", "asc"));
    /**
     * @ignore
     *
     * This variable holds the fileMap for the compiler.
     */
    var fileMap = new Map();
    /**
     * @ignore
     *
     * This variable holds the folderMap for the compiler.
     */
    var folderMap = new Map();
    /**
     * @ignore
     *
     * Run a worklet command.
     * @param {ICommand} command - The command to run. (This is the compiler worklet command.)
     */
    function run(command) {
        var binary;
        var filePromises = [];
        asc.main(command.props.args, {
            stdout: process.stdout,
            stderr: process.stderr,
            listFiles: function (dirname, baseDir) {
                var folder = path_4.join(baseDir, dirname);
                if (folderMap.has(folder)) {
                    return folderMap.get(folder);
                }
                try {
                    var results = fs_6.readdirSync(folder).filter(function (file) {
                        return /^(?!.*\.d\.ts$).*\.ts$/.test(file);
                    });
                    folderMap.set(folder, results);
                    return results;
                }
                catch (e) {
                    return [];
                }
            },
            readFile: function (filename, baseDir) {
                var fileName = path_4.join(baseDir, filename);
                if (fileMap.has(fileName)) {
                    return fileMap.get(fileName);
                }
                try {
                    var contents = fs_6.readFileSync(fileName, { encoding: "utf8" });
                    fileMap.set(fileName, contents);
                    return contents;
                }
                catch (e) {
                    return null;
                }
            },
            writeFile: function (name, contents) {
                var ext = path_4.extname(name);
                // get the wasm file
                if (ext === ".wasm") {
                    binary = contents;
                    if (!command.props.outputBinary)
                        return;
                }
                var file = command.props.file;
                var outfileName = path_4.join(path_4.dirname(file), path_4.basename(file, path_4.extname(file)) + ext);
                filePromises.push(writeFile_2.writeFile(outfileName, contents));
            },
        }, function (error) {
            return Promise.all(filePromises)
                .then(function () {
                worker_threads_1.parentPort.postMessage({
                    type: "Result",
                    props: {
                        error: error
                            ? {
                                message: error.message,
                                stack: error.stack,
                                name: error.name,
                            }
                            : null,
                        binary: binary,
                        file: command.props.file,
                    },
                }, binary ? [binary.buffer] : []);
            })
                .catch(function (error) {
                worker_threads_1.parentPort.postMessage({
                    type: "Error",
                    props: {
                        error: error
                            ? {
                                message: error.message,
                                stack: error.stack,
                                name: error.name,
                            }
                            : null,
                    },
                });
            });
        });
    }
    worker_threads_1.parentPort.on("message", run);
});
//# sourceMappingURL=as-pect.cli.amd.js.map