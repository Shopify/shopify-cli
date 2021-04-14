"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.asp = exports.defaultCliArgs = exports.parse = exports.version = void 0;
var CommandLineArg_1 = require("./util/CommandLineArg");
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
var CommandLineArg_2 = require("./util/CommandLineArg");
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
//# sourceMappingURL=index.js.map