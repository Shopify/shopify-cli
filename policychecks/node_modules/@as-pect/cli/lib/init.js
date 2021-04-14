"use strict";
var __makeTemplateObject = (this && this.__makeTemplateObject) || function (cooked, raw) {
    if (Object.defineProperty) { Object.defineProperty(cooked, "raw", { value: raw }); } else { cooked.raw = raw; }
    return cooked;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.init = void 0;
var chalk_1 = __importDefault(require("chalk"));
var fs_1 = require("fs");
var path_1 = require("path");
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
    console.log(chalk_1.default(templateObject_1 || (templateObject_1 = __makeTemplateObject(["{bgWhite.black [Log]} Initializing test suite files."], ["{bgWhite.black [Log]} Initializing test suite files."]))));
    console.log("");
    // create the assembly folder if it doesn't exist
    if (!fs_1.existsSync(assemblyFolder)) {
        console.log(chalk_1.default(templateObject_2 || (templateObject_2 = __makeTemplateObject(["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/}"], ["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/}"]))));
        fs_1.mkdirSync(assemblyFolder);
    }
    // Create the test folder if it doesn't exist
    if (!fs_1.existsSync(testFolder)) {
        console.log(chalk_1.default(templateObject_3 || (templateObject_3 = __makeTemplateObject(["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/__tests__/}"], ["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/__tests__/}"]))));
        fs_1.mkdirSync(testFolder);
        // create the example file only if the __tests__ folder does not exist
        var exampleFile = path_1.join(testFolder, "example.spec.ts");
        var exampleFileSource = path_1.join(__dirname, "../init/example.spec.ts");
        if (!fs_1.existsSync(exampleFile)) {
            console.log(chalk_1.default(templateObject_4 || (templateObject_4 = __makeTemplateObject(["{bgWhite.black [Log]} Creating file: {yellow ./assembly/__tests__/example.spec.ts}"], ["{bgWhite.black [Log]} Creating file: {yellow ./assembly/__tests__/example.spec.ts}"]))));
            fs_1.createReadStream(exampleFileSource, "utf-8").pipe(fs_1.createWriteStream(exampleFile, "utf-8"));
        }
    }
    // create the types file if it doesn't exist for typescript tooling users
    if (!fs_1.existsSync(typesFile)) {
        console.log(chalk_1.default(templateObject_5 || (templateObject_5 = __makeTemplateObject(["{bgWhite.black [Log]} Creating file: {yellow ./assembly/__tests__/as-pect.d.ts}"], ["{bgWhite.black [Log]} Creating file: {yellow ./assembly/__tests__/as-pect.d.ts}"]))));
        fs_1.createReadStream(typesFileSource, "utf-8").pipe(fs_1.createWriteStream(typesFile, "utf-8"));
    }
    // create the default configuration file
    var configFile = path_1.join(process.cwd(), "as-pect.config.js");
    var configFileSource = path_1.join(__dirname, "../init/as-pect.config.js");
    if (!fs_1.existsSync(configFile)) {
        console.log(chalk_1.default(templateObject_6 || (templateObject_6 = __makeTemplateObject(["{bgWhite.black [Log]} Creating file: {yellow ./as-pect.config.js}"], ["{bgWhite.black [Log]} Creating file: {yellow ./as-pect.config.js}"]))));
        fs_1.createReadStream(configFileSource, "utf-8").pipe(fs_1.createWriteStream(configFile, "utf-8"));
    }
}
exports.init = init;
var templateObject_1, templateObject_2, templateObject_3, templateObject_4, templateObject_5, templateObject_6;
//# sourceMappingURL=init.js.map