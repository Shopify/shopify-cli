/// <reference types="node" />
declare module "help" {
    /**
     * @ignore
     *
     * This method prints the help text.
     */
    export function help(): void;
}
declare module "util/strings" {
    /**
     * @ignore
     * Capitalize a word.
     *
     * @param {string} word - The word to be capitalized.
     */
    export function capitalize(word: string): string;
    /**
     * @ignore
     * CamelCase a single string. Usually used with `dash-cased` words.
     *
     * @param {string} str - The string to be camelCased.
     * @param {string} from - The string seperator.
     */
    export function toCamelCase(str: string, from?: string): string;
}
declare module "util/CommandLineArg" {
    /**
     * @ignore
     *
     * This is the set of command line ArgumentTypes.
     */
    export type ArgType = "b" | "bs" | "s" | "S" | "I" | "i" | "F" | "f";
    /**
     * @ignore
     *
     * These are the possible command line argument values.
     */
    export type ArgValue = string | number | boolean | string[] | number | {
        [key: string]: ArgValue;
    } | Set<string>;
    /**
     * @ignore
     *
     * This interface represents a CommandLineArgument alias.
     */
    export interface Alias {
        name: string;
        long?: true;
    }
    /**
     * @ignore
     *
     * This is the Command Line Argument interface.
     */
    export interface ICommandLineArg {
        description: string | string[];
        type: ArgType;
        alias?: Alias | Alias[];
        value: ArgValue;
        options?: [string, string][];
        parent?: string;
    }
    /**
     * This is the set of CLI options provided by the parser when the arguments are parsed.
     */
    export interface Options {
        [key: string]: ArgValue;
        init: boolean;
        config: string;
        version: boolean;
        help: boolean;
        types: boolean;
        file: string;
        group: string;
        test: string;
        outputBinary: boolean;
        memorySize: number;
        memoryMax: number;
        norun: boolean;
        reporter: string;
        portable: boolean;
        compiler: string;
        csv: string | boolean;
        json: string | boolean;
        verbose: string | boolean;
        summary: string | boolean;
        /** Suppress ASCII art from being printed */
        nologo: boolean;
        /** Tracks changes made by the cli options */
        changed: Set<string>;
        /** The number of experimental workers used for compiling. */
        workers: number;
        /** Indicates of snapshots should be updated. */
        update: boolean;
    }
    /**
     * @ignore
     *
     * This class represents a definition for a command line argument.
     */
    export class CommandLineArg implements ICommandLineArg {
        name: string;
        description: string | string[];
        type: ArgType;
        value: ArgValue;
        alias?: Alias | Alias[] | undefined;
        options?: [string, string][] | undefined;
        parent?: string;
        constructor(name: string, command: ICommandLineArg);
        parse(data: string): ArgValue;
    }
    /**
     * @ignore
     *
     * This interface defines an object that will contain the command line arguments.
     */
    export interface CommandLineArgs {
        [key: string]: ICommandLineArg;
    }
    /**
     * @ignore
     *
     * This is the command line argument map.
     */
    export type ArgMap = Map<string, CommandLineArg>;
    /**
     * @ignore
     * Take a CommandLineArgs object and turn it into an ArgMap.
     *
     * @param args
     */
    export function makeArgMap(args?: CommandLineArgs): ArgMap;
    /**
     * This is the set of stored command line arguments for the asp command line.
     */
    export const defaultCliArgs: ArgMap;
    /**
     * This method parses command line options like the `asp` command does. It takes an optional
     * second parameter to modify the command line arguments used.
     *
     * @param {string[]} commands - The command line arguments.
     * @param {ArgMap} cliArgs - The set of parsable arguments.
     */
    export function parse(commands: string[], cliArgs?: ArgMap): Options;
}
declare module "index" {
    /**
     * This is the command line package version.
     */
    export const version: any;
    export { parse, defaultCliArgs, Options } from "util/CommandLineArg";
    /**
     * This is the cli entry point and expects an array of arguments from the command line.
     *
     * @param {string[]} args - The arguments from the command line
     */
    export function asp(args: string[]): void;
}
declare module "init" {
    /**
     * @ignore
     *
     * This method initializes a new test project. It is opinionated and reflects the needs of 99% of
     * AssemblyScript developers following the standard way of creating a new AssemblyScript project.
     */
    export function init(): void;
}
declare module "portable" {
    /**
     * @ignore
     *
     * This method creates a portable types file to the current testing directory located at
     * `./assembly/__tests__/` for the current project.
     */
    export function portable(): void;
}
declare module "util/IConfiguration" {
    import { IReporter } from "@as-pect/core";
    import { WASIOptions } from "wasi";
    /**
     * This is the shape of the compiler flags.
     */
    export interface ICompilerFlags {
        [flag: string]: string[];
    }
    /**
     * This is an interface describing the shape of an exported configuration for the
     * `as-pect.config.js` file. An empty object should be a valid `as-pect` configuration.
     */
    export interface IConfiguration {
        [key: string]: any;
        /**
         * A set of globs that denote files that must be used for testing.
         */
        include?: string[];
        /**
         * A set of globs that denote files that must be added to every compilation.
         */
        add?: string[];
        /**
         * The compiler flags needed for this test suite. Do not forget that a binary file must be output.
         */
        flags?: ICompilerFlags;
        /**
         * A set of regular expressions that are tested against the file names. If they match, the
         * files will be discluded.
         */
        disclude?: RegExp[];
        /**
         * The web assembly imports required for testing your module.
         */
        imports?: any;
        /**
         * A custom reporter that extends the `TestReporter` class, and is responsible for generating log
         * output.
         */
        reporter?: IReporter;
        /**
         * A regular expression that instructs the TestContext to only run tests that match this regex.
         */
        testRegex?: RegExp;
        /**
         * A regular expression that instructs the TestContext to only run groups that match this regex.
         */
        groupRegex?: RegExp;
        /**
         * Specifies if a wasm binary should be output. Default is false.
         */
        outputBinary?: boolean;
        /**
         * Specifies if rtrace counting should be skipped. Use with stub allocator.
         */
        nortrace?: boolean;
        /**
         * WASM Memory size in pages. Default is 10.
         */
        memorySize?: number;
        /**
         * WASM Memory max size in pages 64kb. Should be positive. Default is disabled or -1.
         */
        memoryMax?: number;
        /**
         * WASI options, if any are provided, wasi will be enabled.
         */
        wasi?: WASIOptions;
    }
}
declare module "util/collectReporter" {
    import { IReporter } from "@as-pect/core";
    import { Options } from "util/CommandLineArg";
    /**
     * @ignore
     * This method inspects the command line arguments and returns the corresponding TestReporter.
     *
     * @param {Options} cliOptions - The command line arguments.
     */
    export function collectReporter(cliOptions: Options): IReporter;
}
declare module "util/getTestEntryFiles" {
    import { Options } from "util/CommandLineArg";
    /**
     * @ignore
     * This method returns a `Set<string>` of entry files for the compiler to compile.
     *
     * @param {Options} cliOptions - The command line arguments.
     * @param {string[]} include - An array of globs provided by the configuration.
     * @param {RegExp[]} disclude - An array of RegExp provided by the configuration.
     */
    export function getTestEntryFiles(cliOptions: Options, include: string[], disclude: RegExp[]): Set<string>;
}
declare module "util/writeFile" {
    /**
     * @ignore
     * This method promisifies the fs.writeFile function call, and is compatible with node 10.
     *
     * @param {string} file - The file location to write to.
     * @param {Uint8Array} contents - The file contents to write to the disk.
     */
    export function writeFile(file: string, contents: Uint8Array | string): Promise<void>;
}
declare module "worklets/ICommand" {
    /**
     * @ignore
     *
     * This interface defines a message type for the compiler worklet.
     */
    export interface ICommand {
        type: string;
        props: any;
    }
}
declare module "util/removeFile" {
    /**
     * @ignore
     * This method promisifies the fs.writeFile function call, and is compatible with node 10.
     *
     * @param {string} file - The file location to write to.
     */
    export function removeFile(file: string): Promise<void>;
}
declare module "run" {
    import { Options } from "util/CommandLineArg";
    /**
     * @ignore
     * This method actually runs the test suites in sequential order synchronously.
     *
     * @param {Options} cliOptions - The command line arguments.
     * @param {string[]} compilerArgs - The `asc` compiler arguments.
     */
    export function run(cliOptions: Options, compilerArgs: string[]): void;
}
declare module "types" {
    /**
     * @ignore
     *
     * This method creates a types file to the current testing directory located at
     * `./assembly/__tests__/` for the current project.
     */
    export function types(): void;
}
declare module "util/asciiArt" {
    /**
     * @ignore
     *
     * This method prints the ascii art.
     * @param {string} version - The cli version
     */
    export function printAsciiArt(version: string): void;
}
declare module "worklets/compiler" { }
//# sourceMappingURL=as-pect.cli.amd.d.ts.map