/// <reference types="assemblyscript/dist/assemblyscript" />
import { Parser } from "./assemblyscript";
declare const _default: {
    new (): {
        afterParse(_parser: Parser): void;
        readonly program: import("assemblyscript/src/program").Program;
        readonly baseDir: string;
        readonly stdout: import("assemblyscript/cli/asc").OutputStream;
        readonly stderr: import("assemblyscript/cli/asc").OutputStream;
        readonly log: {
            (...data: any[]): void;
            (message?: any, ...optionalParams: any[]): void;
        };
        writeFile(filename: string, contents: string | Uint8Array, baseDir: string): boolean;
        readFile(filename: string, baseDir: string): string | null;
        listFiles(dirname: string, baseDir: string): string[] | null;
        afterInitialize?(program: import("assemblyscript/src/program").Program): void;
        afterCompile?(module: import("assemblyscript/src/module").Module): void;
    };
};
/**
 * Just an empty transformer.
 */
export = _default;
//# sourceMappingURL=emptyTransformer.d.ts.map