"use strict";
var __makeTemplateObject = (this && this.__makeTemplateObject) || function (cooked, raw) {
    if (Object.defineProperty) { Object.defineProperty(cooked, "raw", { value: raw }); } else { cooked.raw = raw; }
    return cooked;
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
exports.run = void 0;
var fs = __importStar(require("fs"));
var perf_hooks_1 = require("perf_hooks");
var path = __importStar(require("path"));
var chalk_1 = __importDefault(require("chalk"));
var core_1 = require("@as-pect/core");
var glob_1 = __importDefault(require("glob"));
var collectReporter_1 = require("./util/collectReporter");
var getTestEntryFiles_1 = require("./util/getTestEntryFiles");
var writeFile_1 = require("./util/writeFile");
var timeDifference_1 = require("@as-pect/core/lib/util/timeDifference");
var snapshots_1 = require("@as-pect/snapshots");
var removeFile_1 = require("./util/removeFile");
/**
 * @ignore
 * This method actually runs the test suites in sequential order synchronously.
 *
 * @param {Options} cliOptions - The command line arguments.
 * @param {string[]} compilerArgs - The `asc` compiler arguments.
 */
function run(cliOptions, compilerArgs) {
    var e_1, _a, e_2, _b, e_3, _c;
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
            console.error(chalk_1.default(templateObject_1 || (templateObject_1 = __makeTemplateObject(["{red [Error]} Invalid worker configuration: {yellow ", "}"], ["{red [Error]} Invalid worker configuration: {yellow ", "}"])), cliOptions.workers.toString()));
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
        console.log(chalk_1.default(templateObject_2 || (templateObject_2 = __makeTemplateObject(["{bgWhite.black [Log]} Using experimental compiler worklets: {yellow ", " worklets}"], ["{bgWhite.black [Log]} Using experimental compiler worklets: {yellow ", " worklets}"])), worklets.length.toString()));
    }
    /**
     * Instead of using `import`, the strategy is to encourage node to start the testing process
     * as soon as possible. Calling require and measuring the performance of compiler loading shows
     * developers a meaningful explaination of why it takes a few seconds for the software to start
     * running.
     */
    console.log(chalk_1.default(templateObject_3 || (templateObject_3 = __makeTemplateObject(["{bgWhite.black [Log]} Loading asc compiler"], ["{bgWhite.black [Log]} Loading asc compiler"]))));
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
        console.error(chalk_1.default(templateObject_4 || (templateObject_4 = __makeTemplateObject(["{bgRedBright.black [Error]} There was a problem loading {bold [", "]}."], ["{bgRedBright.black [Error]} There was a problem loading {bold [", "]}."])), cliOptions.compiler));
        console.error(ex);
        process.exit(1);
    }
    console.log(chalk_1.default(templateObject_5 || (templateObject_5 = __makeTemplateObject(["{bgWhite.black [Log]} Compiler loaded in {yellow ", "ms}."], ["{bgWhite.black [Log]} Compiler loaded in {yellow ",
        "ms}."])), timeDifference_1.timeDifference(perf_hooks_1.performance.now(), start).toString()));
    // obtain the configuration file
    var configurationPath = path.resolve(process.cwd(), cliOptions.config);
    console.log(chalk_1.default(templateObject_6 || (templateObject_6 = __makeTemplateObject(["{bgWhite.black [Log]} Using configuration {yellow ", "}"], ["{bgWhite.black [Log]} Using configuration {yellow ", "}"])), configurationPath));
    var configuration = {};
    try {
        configuration = require(configurationPath) || {};
    }
    catch (ex) {
        console.error("");
        console.error(chalk_1.default(templateObject_7 || (templateObject_7 = __makeTemplateObject(["{bgRedBright.black [Error]} There was a problem loading {bold [", "]}."], ["{bgRedBright.black [Error]} There was a problem loading {bold [", "]}."])), configurationPath));
        console.error(ex);
        process.exit(1);
    }
    // configuration must be an object
    if (!configuration) {
        console.error(chalk_1.default(templateObject_8 || (templateObject_8 = __makeTemplateObject(["{bgRedBright.black [Error]} Configuration at {bold [", "]} is null or not an object."], ["{bgRedBright.black [Error]} Configuration at {bold [", "]} is null or not an object."])), configurationPath));
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
            console.error(chalk_1.default(templateObject_9 || (templateObject_9 = __makeTemplateObject(["{bgRedBright.black [Error]} Unknown compiler arguments {bold.yellow [", "]}."], ["{bgRedBright.black [Error]} Unknown compiler arguments {bold.yellow [",
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
        console.log(chalk_1.default(templateObject_10 || (templateObject_10 = __makeTemplateObject(["{yellow [Warning]} Using optimizations. This may result in slow test compilation times."], ["{yellow [Warning]} Using optimizations. This may result in slow test compilation times."]))));
    }
    var disclude = configuration.disclude || [];
    // if a reporter is specified in cli arguments, override configuration
    var reporter = configuration.reporter || collectReporter_1.collectReporter(cliOptions);
    // include all the file globs
    console.log(chalk_1.default(templateObject_11 || (templateObject_11 = __makeTemplateObject(["{bgWhite.black [Log]} Including files: ", ""], ["{bgWhite.black [Log]} Including files: ", ""])), include.join(", ")));
    // Create the test and group matchers
    var testRegex = new RegExp(cliOptions.test, "i");
    configuration.testRegex = testRegex;
    console.log(chalk_1.default(templateObject_12 || (templateObject_12 = __makeTemplateObject(["{bgWhite.black [Log]} Running tests that match: {yellow ", "}"], ["{bgWhite.black [Log]} Running tests that match: {yellow ", "}"])), testRegex.source));
    var groupRegex = new RegExp(cliOptions.group, "i");
    configuration.groupRegex = groupRegex;
    console.log(chalk_1.default(templateObject_13 || (templateObject_13 = __makeTemplateObject(["{bgWhite.black [Log]} Running groups that match: {yellow ", "}"], ["{bgWhite.black [Log]} Running groups that match: {yellow ", "}"])), groupRegex.source));
    /**
     * Check to see if the binary files should be written to the fileSystem.
     */
    var outputBinary = (_d = (cliOptions.changed.has("outputBinary")
        ? cliOptions.outputBinary
        : configuration.outputBinary)) !== null && _d !== void 0 ? _d : false;
    if (outputBinary) {
        console.log(chalk_1.default(templateObject_14 || (templateObject_14 = __makeTemplateObject(["{bgWhite.black [Log]} Outputing Binary *.wasm files."], ["{bgWhite.black [Log]} Outputing Binary *.wasm files."]))));
    }
    /**
     * Check to see if the tests should be run in the first place.
     */
    var runTests = !cliOptions.norun;
    if (!runTests) {
        console.log(chalk_1.default(templateObject_15 || (templateObject_15 = __makeTemplateObject(["{bgWhite.black [Log]} Not running tests, only outputting files."], ["{bgWhite.black [Log]} Not running tests, only outputting files."]))));
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
        console.error(chalk_1.default(templateObject_16 || (templateObject_16 = __makeTemplateObject(["{red [Error]} Invalid {yellow memorySize} value (", ") [valid range is a positive interger]"], ["{red [Error]} Invalid {yellow memorySize} value (", ") [valid range is a positive interger]"])), memorySize));
        process.exit(1);
    }
    if (!Number.isInteger(memoryMax) || memoryMax < -1) {
        console.error(chalk_1.default(templateObject_17 || (templateObject_17 = __makeTemplateObject(["{red [Error]} Invalid {yellow memoryMax} value (", ") [valid range is a positive interger greater than {yellow memorySize}]"], ["{red [Error]} Invalid {yellow memoryMax} value (", ") [valid range is a positive interger greater than {yellow memorySize}]"])), memoryMax));
        process.exit(1);
    }
    if (memoryMax > 0 && memoryMax < memorySize) {
        console.error(chalk_1.default(templateObject_18 || (templateObject_18 = __makeTemplateObject(["{red [Error]} Invalid module memory configuration, memorySize (", ") is greater than memoryMax (", ")."], ["{red [Error]} Invalid module memory configuration, memorySize (", ") is greater than memoryMax (", ")."])), memorySize, memoryMax));
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
        console.log(chalk_1.default(templateObject_19 || (templateObject_19 = __makeTemplateObject(["{bgWhite.black [Log]} Adding compiler arguments: "], ["{bgWhite.black [Log]} Adding compiler arguments: "]))) +
            compilerArgs.join(" "));
    }
    var addedTestEntryFiles = new Set();
    /** Get all the test entry files. */
    var testEntryFiles = getTestEntryFiles_1.getTestEntryFiles(cliOptions, include, disclude);
    if (testEntryFiles.size === 0) {
        console.error(chalk_1.default(templateObject_20 || (templateObject_20 = __makeTemplateObject(["{red [Error]} No files matching the pattern were found."], ["{red [Error]} No files matching the pattern were found."]))));
        process.exit(1);
    }
    try {
        for (var add_1 = __values(add), add_1_1 = add_1.next(); !add_1_1.done; add_1_1 = add_1.next()) {
            var pattern = add_1_1.value;
            try {
                // push all the added files to the added entry point list
                for (var _g = (e_2 = void 0, __values(glob_1.default.sync(pattern))), _h = _g.next(); !_h.done; _h = _g.next()) {
                    var entry = _h.value;
                    addedTestEntryFiles.add(entry);
                }
            }
            catch (e_2_1) { e_2 = { error: e_2_1 }; }
            finally {
                try {
                    if (_h && !_h.done && (_b = _g.return)) _b.call(_g);
                }
                finally { if (e_2) throw e_2.error; }
            }
        }
    }
    catch (e_1_1) { e_1 = { error: e_1_1 }; }
    finally {
        try {
            if (add_1_1 && !add_1_1.done && (_a = add_1.return)) _a.call(add_1);
        }
        finally { if (e_1) throw e_1.error; }
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
    console.log(chalk_1.default(templateObject_21 || (templateObject_21 = __makeTemplateObject(["{bgWhite.black [Log]} Effective command line args:"], ["{bgWhite.black [Log]} Effective command line args:"]))));
    console.log(chalk_1.default(templateObject_22 || (templateObject_22 = __makeTemplateObject(["  {green [TestFile.ts]} {yellow ", "} ", ""], ["  {green [TestFile.ts]} {yellow ",
        "} ", ""])), Array.from(addedTestEntryFiles).join(" "), flagList.join(" ")));
    // add a line seperator between the next line and this line
    console.log("");
    var finalCompilerArguments = __spread(Array.from(addedTestEntryFiles), flagList);
    function runBinary(error, file, binary) {
        var e_4, _a, e_5, _b, e_6, _c;
        var _d;
        // if there are any compilation errors, stop the test suite
        if (error) {
            console.error(chalk_1.default(templateObject_23 || (templateObject_23 = __makeTemplateObject(["{red [Error]} There was a compilation error when trying to create the wasm binary for file: ", "."], ["{red [Error]} There was a compilation error when trying to create the wasm binary for file: ", "."])), file));
            console.error(error);
            return process.exit(1);
        }
        // if the binary wasn't emitted, stop the test suite
        if (!binary) {
            console.error(chalk_1.default(templateObject_24 || (templateObject_24 = __makeTemplateObject(["{red [Error]} There was no output binary file: ", ". Did you forget to emit the binary with {yellow --binaryFile}?"], ["{red [Error]} There was no output binary file: ", ". Did you forget to emit the binary with {yellow --binaryFile}?"])), file));
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
                    console.error(chalk_1.default(templateObject_25 || (templateObject_25 = __makeTemplateObject(["{red [Error]} Imports configuration function did not return an AssemblyScript module. (Did you forget to return it?)"], ["{red [Error]} Imports configuration function did not return an AssemblyScript module. (Did you forget to return it?)"]))));
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
                            var _g = __read(_f.value, 2), name_1 = _g[0], diffResult = _g[1];
                            if (diffResult.type === 1 /* Added */) {
                                result_1.values.set(name_1, diffResult.left);
                            }
                        }
                    }
                    catch (e_4_1) { e_4 = { error: e_4_1 }; }
                    finally {
                        try {
                            if (_f && !_f.done && (_a = _e.return)) _a.call(_e);
                        }
                        finally { if (e_4) throw e_4.error; }
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
                var result = failed ? chalk_1.default(templateObject_26 || (templateObject_26 = __makeTemplateObject(["{red \u2716 FAIL}"], ["{red \u2716 FAIL}"]))) : chalk_1.default(templateObject_27 || (templateObject_27 = __makeTemplateObject(["{green \u2714 PASS}"], ["{green \u2714 PASS}"])));
                try {
                    for (var errors_1 = __values(errors), errors_1_1 = errors_1.next(); !errors_1_1.done; errors_1_1 = errors_1.next()) {
                        var error_1 = errors_1_1.value;
                        console.log(chalk_1.default(templateObject_28 || (templateObject_28 = __makeTemplateObject(["\n [Error]: {red ", "}: ", "\n [Stack]: {yellow ", "}\n"], ["\n [Error]: {red ", "}: ", "\n [Stack]: {yellow ", "}\n"])), error_1.type, error_1.message, error_1.stackTrace.split("\n").join("\n            ")));
                    }
                }
                catch (e_5_1) { e_5 = { error: e_5_1 }; }
                finally {
                    try {
                        if (errors_1_1 && !errors_1_1.done && (_b = errors_1.return)) _b.call(errors_1);
                    }
                    finally { if (e_5) throw e_5.error; }
                }
                console.log(chalk_1.default(templateObject_29 || (templateObject_29 = __makeTemplateObject(["  [Result]: ", "\n   [Files]: ", " total\n  [Groups]: ", " count, ", " pass\n   [Tests]: ", " pass, ", " fail, ", " total\n    [Time]: ", "ms"], ["  [Result]: ", "\n   [Files]: ", " total\n  [Groups]: ", " count, ", " pass\n   [Tests]: ", " pass, ",
                    " fail, ", " total\n    [Time]: ", "ms"])), result, testEntryFiles.size.toString(), groupCount.toString(), groupSuccessCount.toString(), successCount.toString(), (testCount - successCount).toString(), testCount.toString(), timeDifference_1.timeDifference(end, start).toString()));
                if (worklets.length > 0) {
                    try {
                        for (var worklets_1 = __values(worklets), worklets_1_1 = worklets_1.next(); !worklets_1_1.done; worklets_1_1 = worklets_1.next()) {
                            var worklet = worklets_1_1.value;
                            worklet.terminate();
                        }
                    }
                    catch (e_6_1) { e_6 = { error: e_6_1 }; }
                    finally {
                        try {
                            if (worklets_1_1 && !worklets_1_1.done && (_c = worklets_1.return)) _c.call(worklets_1);
                        }
                        finally { if (e_6) throw e_6.error; }
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
        catch (e_3_1) { e_3 = { error: e_3_1 }; }
        finally {
            try {
                if (_k && !_k.done && (_c = _j.return)) _c.call(_j);
            }
            finally { if (e_3) throw e_3.error; }
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
var templateObject_1, templateObject_2, templateObject_3, templateObject_4, templateObject_5, templateObject_6, templateObject_7, templateObject_8, templateObject_9, templateObject_10, templateObject_11, templateObject_12, templateObject_13, templateObject_14, templateObject_15, templateObject_16, templateObject_17, templateObject_18, templateObject_19, templateObject_20, templateObject_21, templateObject_22, templateObject_23, templateObject_24, templateObject_25, templateObject_26, templateObject_27, templateObject_28, templateObject_29;
//# sourceMappingURL=run.js.map