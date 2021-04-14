/// <reference types="node" />
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
//# sourceMappingURL=IConfiguration.d.ts.map