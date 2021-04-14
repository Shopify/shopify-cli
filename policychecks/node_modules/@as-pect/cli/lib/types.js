"use strict";
var __makeTemplateObject = (this && this.__makeTemplateObject) || function (cooked, raw) {
    if (Object.defineProperty) { Object.defineProperty(cooked, "raw", { value: raw }); } else { cooked.raw = raw; }
    return cooked;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.types = void 0;
var chalk_1 = __importDefault(require("chalk"));
var fs_1 = require("fs");
var path_1 = require("path");
/**
 * @ignore
 *
 * This method creates a types file to the current testing directory located at
 * `./assembly/__tests__/` for the current project.
 */
function types() {
    var assemblyFolder = path_1.join(process.cwd(), "assembly");
    var testFolder = path_1.join(assemblyFolder, "__tests__");
    var typesFileSource = require.resolve("@as-pect/cli/init/init-types.d.ts");
    var typesFile = path_1.join(testFolder, "as-pect.d.ts");
    console.log("");
    console.log(chalk_1.default(templateObject_1 || (templateObject_1 = __makeTemplateObject(["{bgWhite.black [Log]} Initializing types."], ["{bgWhite.black [Log]} Initializing types."]))));
    console.log("");
    // Create the assembly folder if it doesn't exist
    if (!fs_1.existsSync(assemblyFolder)) {
        console.log(chalk_1.default(templateObject_2 || (templateObject_2 = __makeTemplateObject(["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/}"], ["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/}"]))));
        fs_1.mkdirSync(assemblyFolder);
    }
    // Create the test folder if it doesn't exist
    if (!fs_1.existsSync(testFolder)) {
        console.log(chalk_1.default(templateObject_3 || (templateObject_3 = __makeTemplateObject(["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/__tests__/}"], ["{bgWhite.black [Log]} Creating folder: {yellow ./assembly/__tests__/}"]))));
        fs_1.mkdirSync(testFolder);
    }
    // Always create the types file
    console.log(chalk_1.default(templateObject_4 || (templateObject_4 = __makeTemplateObject(["{bgWhite.black [Log]} Creating file: {yellow ./assembly/__tests__/as-pect.d.ts}"], ["{bgWhite.black [Log]} Creating file: {yellow ./assembly/__tests__/as-pect.d.ts}"]))));
    fs_1.createReadStream(typesFileSource, "utf-8").pipe(fs_1.createWriteStream(typesFile, "utf-8"));
}
exports.types = types;
var templateObject_1, templateObject_2, templateObject_3, templateObject_4;
//# sourceMappingURL=types.js.map