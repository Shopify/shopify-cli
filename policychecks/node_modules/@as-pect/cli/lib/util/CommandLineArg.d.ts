/**
 * @ignore
 *
 * This is the set of command line ArgumentTypes.
 */
export declare type ArgType = "b" | "bs" | "s" | "S" | "I" | "i" | "F" | "f";
/**
 * @ignore
 *
 * These are the possible command line argument values.
 */
export declare type ArgValue = string | number | boolean | string[] | number | {
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
export declare class CommandLineArg implements ICommandLineArg {
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
export declare type ArgMap = Map<string, CommandLineArg>;
/**
 * @ignore
 * Take a CommandLineArgs object and turn it into an ArgMap.
 *
 * @param args
 */
export declare function makeArgMap(args?: CommandLineArgs): ArgMap;
/**
 * This is the set of stored command line arguments for the asp command line.
 */
export declare const defaultCliArgs: ArgMap;
/**
 * This method parses command line options like the `asp` command does. It takes an optional
 * second parameter to modify the command line arguments used.
 *
 * @param {string[]} commands - The command line arguments.
 * @param {ArgMap} cliArgs - The set of parsable arguments.
 */
export declare function parse(commands: string[], cliArgs?: ArgMap): Options;
//# sourceMappingURL=CommandLineArg.d.ts.map