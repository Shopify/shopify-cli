declare module "util/IAspectExports" {
    /**
     * This is the shape of the exported functions provided by the `as-pect` test suite.
     */
    export interface IAspectExports {
        [key: string]: unknown;
        /**
         * This method calls a function pointer that matches the `() => void` type.
         *
         * @param {number} pointer - The function pointer.
         */
        __call(pointer: number): void;
        /** This method disables rtrace calls for the current test context. */
        __disableRTrace(): void;
        /**
         * This method returns the `usize[]` of the current module.
         */
        __getUsizeArrayId(): number;
        /** The exported web assembly memory. For compatibility with docs, this is explicit. */
        readonly memory: {
            readonly buffer: ArrayBuffer;
        };
        /** Explicit start function. */
        _start(): void;
        /** Reads (copies) the value of a string from the module's memory. */
        __getString(ref: number): string;
        /** Allocates a new array in the module's memory and returns a reference (pointer) to it. */
        __allocArray(id: number, values: number[]): number;
        /** Reads (copies) the values of an array from the module's memory. */
        __getArray(ref: number): number[];
        /** Forces a cycle collection. Only relevant if objects potentially forming reference cycles are used. */
        __collect(): void;
        /** The WebAssembly function Table. */
        readonly table?: WebAssembly.Table;
    }
}
declare module "util/wasmTools" {
    /**
     * A Buffer for reading wasm sections.
     */
    export class WasmBuffer {
        u8array: Uint8Array;
        /** Current offset in the buffer. */
        off: number;
        constructor(u8array: Uint8Array);
        /** Read 128LEB unsigned integers. */
        readVaruint(off?: number): number;
        /**
         * Read a UTF8 string from the buffer either at the current offset or one passed in.
         * Updates the offset of the buffer.
         */
        readString(off?: number): string;
        /** Read a string at an offset without changing the buffere's offset. */
        peekString(off: number): string;
    }
    /**
     * Utility class for reading the name sections of a wasm binary.
     * See https://github.com/WebAssembly/design/blob/master/BinaryEncoding.md#name-section
     */
    export class NameSection {
        section: WasmBuffer;
        /** map of indexs to UTF8 pointers. */
        private funcNames;
        constructor(contents: Uint8Array);
        fromIndex(i: number): string;
        /** Parses */
        private parseSection;
        /** Current offset */
        get off(): number;
        /** Update offset */
        set off(o: number);
        /** Reads a 128LEB  unsigned integer and updates the offset. */
        readVaruint(off?: number): number;
    }
}
declare module "util/stringifyReflectedValue" {
    import { ReflectedValue } from "util/ReflectedValue";
    export type StringifyReflectedValueProps = {
        keywordFormatter: (prop: string) => string;
        stringFormatter: (prop: string) => string;
        classNameFormatter: (prop: string) => string;
        numberFormatter: (prop: string) => string;
        indent: number;
        tab: number;
        maxPropertyCount: number;
        maxLineLength: number;
        maxExpandLevel: number;
    };
    export function stringifyReflectedValue(reflectedValue: ReflectedValue, props: Partial<StringifyReflectedValueProps>): string;
}
declare module "util/ReflectedValue" {
    import { ReflectedValueType } from "../../assembly/assembly/internal/ReflectedValueType";
    import { StringifyReflectedValueProps } from "util/stringifyReflectedValue";
    /**
     * A JavaScript object that represents a reflected value from the as-pect testing
     * module.
     */
    export class ReflectedValue {
        /** An indicator if the reflected object was managed by the runtime. */
        isManaged: boolean;
        /** An indicator if the reflected object was null. */
        isNull: boolean;
        /** A set of keys for Maps or Classes in the reflected object. */
        keys: ReflectedValue[] | null;
        /** Used to indicate if an expected assertion value was negated. */
        negated: boolean;
        /** An indicator wether the reflected object was in a nullable context. */
        nullable: boolean;
        /** The size of the heap allocation for a given class. */
        offset: number;
        /** The pointer to the value in the module. */
        pointer: number;
        /** An indicator if a number was signed. */
        signed: boolean;
        /** The size of an array, or the byte size of a number. */
        size: number;
        /** A stack trace for the given value. */
        stack: string;
        /** The reflected value type. */
        type: ReflectedValueType;
        /** The runtime class id for the reflected reflected value. */
        typeId: number;
        /** The name of the class for a given reflected reflected value. */
        typeName: string | null;
        /** A string or number representing the reflected value. */
        value: number | string;
        /** A set of values that are contained in a given reflected Set, Map, or Class object. */
        values: ReflectedValue[] | null;
        /**
         * Stringify the ReflectedValue with custom formatting.
         *
         * @param {Partial<StringifyReflectedValueProps>} props - The stringify configuration
         */
        stringify(props?: Partial<StringifyReflectedValueProps>): string;
    }
}
declare module "util/TestNodeType" {
    export const enum TestNodeType {
        /** A Test. */
        Test = 0,
        /** A group. */
        Group = 1
    }
}
declare module "test/IWarning" {
    /**
     * This interface describes a warning object.
     */
    export interface IWarning {
        /** This is the type of the warning. */
        type: string;
        /** This is the generated warning message. */
        message: string;
        /** This is the stack trace. */
        stackTrace: string;
    }
}
declare module "util/timeDifference" {
    /**
     * @ignore
     * This method calculates the start and end time difference, rounding off to the nearest thousandth
     * of a millisecond.
     *
     * @param {number} end - The end time.
     * @param {number} start - The start time.
     * @returns {number} - The difference of the two times rounded to the nearest three decimal places.
     */
    export const timeDifference: (end: number, start: number) => number;
}
declare module "test/TestNode" {
    import { TestNodeType } from "util/TestNodeType";
    import { IWarning } from "test/IWarning";
    import { ReflectedValue } from "util/ReflectedValue";
    export class TestNode {
        /** The TestNode type. */
        type: TestNodeType;
        /** The name of the TestNode */
        name: string;
        /** The callback pointer. */
        callback: number;
        /** If the test is expected to fail. */
        negated: boolean;
        /** The namespace of this TestNode */
        namespace: string;
        /** The callback pointers that need to be called before each test. */
        beforeEach: number[];
        /** The callback pointers that need to be called once before traversing through this node's children. */
        beforeAll: number[];
        /** The callback pointers that need to be called after each test. */
        afterEach: number[];
        /** The callback pointers that need to be called once after traversing through this node's children. */
        afterAll: number[];
        /** Parent TestNode */
        parent: TestNode | null;
        /** Children TestNodes */
        children: TestNode[];
        /** An indicator if the test suite passed. */
        pass: boolean;
        /** A set of warnings. */
        warnings: IWarning[];
        /** A set of errors. */
        errors: IWarning[];
        /** A set of logged values. */
        logs: ReflectedValue[];
        /** A stack trace for the error. */
        stackTrace: string | null;
        /** The actual reported value. */
        actual: ReflectedValue | null;
        /** The expected reported value. */
        expected: ReflectedValue | null;
        /** Message provided by the abort() function. */
        message: string | null;
        /** A set of todo messages provided by the testnode. */
        todos: string[];
        /** Start time. */
        start: number;
        /** End time. */
        end: number;
        /** The number of active heap allocations when the node started. */
        rtraceStart: number;
        /** The number of active heap allocations when the node ended. */
        rtraceEnd: number;
        /** If the TestNode ran. */
        ran: boolean;
        /** The node allocations. */
        allocations: number;
        /** The node deallocations */
        frees: number;
        /** The node reallocations. */
        moves: number;
        /** The delta number of heap allocations. */
        get rtraceDelta(): number;
        /** The difference between the start and end TestNode runtime. */
        get deltaT(): number;
        /**
         * Recursively visit this node's children conditionally. Return false to the callback
         * if you don't want to visit that particular node's children.
         */
        visit(callback: (node: TestNode) => boolean | void): void;
        /** Get this group's todos, recursively. */
        get groupTodos(): string[];
        /** Get this group's tests, recursively. */
        get groupTests(): TestNode[];
        /** Get all the groups beneath this node. */
        get childGroups(): TestNode[];
    }
}
declare module "reporter/IReporter" {
    import { TestNode } from "test/TestNode";
    import { TestContext } from "test/TestContext";
    export interface IReporter {
        onEnter(ctx: TestContext, node: TestNode): void;
        onExit(ctx: TestContext, node: TestNode): void;
        onFinish(ctx: TestContext): void;
    }
}
declare module "test/TestContext" {
    import { IAspectExports } from "util/IAspectExports";
    import { Rtrace } from "../util/rTrace";
    import { NameSection } from "util/wasmTools";
    import { ReflectedValue } from "util/ReflectedValue";
    import { TestNode } from "test/TestNode";
    import { IReporter } from "reporter/IReporter";
    import { IWarning } from "test/IWarning";
    import { Snapshot, SnapshotDiff } from "@as-pect/snapshots";
    type WASI = import("wasi").WASI;
    type InstantiateResult = {
        exports: IAspectExports;
        instance: WebAssembly.Instance;
    };
    /**
     * This is a collection of all the parameters required for intantiating a TestCollector.
     */
    export interface ITestContextParameters {
        /** A regular expression that filters what tests can be run. Must be set before calling `testContext.run(wasm);` */
        testRegex?: RegExp;
        /** A regular expression that filters what test groups can be run. Must be set before calling `testContext.run(wasm);` */
        groupRegex?: RegExp;
        /** The test file name. */
        fileName?: string;
        /** The web assembly binary. */
        binary?: Uint8Array;
        /** The reporter. */
        reporter: IReporter;
        /** The expected snapshot output. */
        snapshots?: Snapshot;
        /** WASI, if provided. */
        wasi?: WASI | null;
    }
    /** This class is responsible for collecting and running all the tests in a test binary. */
    export class TestContext {
        /** The web assembly module if it was set. */
        protected wasm: IAspectExports | null;
        /** The name section for function name evaluation. */
        protected nameSection: NameSection | null;
        /** The top level node for this test suite. */
        rootNode: TestNode;
        /** The current working node that is collecting logs and callback pointers. */
        protected targetNode: TestNode;
        /** The name of the AssemblyScript test file. */
        fileName: string;
        /** An indicator to see if the TestSuite passed. */
        pass: boolean;
        /** The test context's reporter. */
        protected reporter: IReporter;
        /** The place where stack traces are stored when a function pointer errors.  */
        protected stack: string;
        /** The place where the abort() messages are stored. */
        protected message: string;
        /** The collected actual value. */
        protected actual: ReflectedValue | null;
        /** The collected expected value. */
        protected expected: ReflectedValue | null;
        /** Filter the tests by regex. */
        protected testRegex: RegExp;
        /** Filter the groups by regex. */
        protected groupRegex: RegExp;
        /** The test count. */
        testCount: number;
        /** The number of tests that ran. */
        testRunCount: number;
        /** The number of passing tests count. */
        testPassCount: number;
        /** The group count. */
        groupCount: number;
        /** The number of groups that ran. */
        groupRunCount: number;
        /** The number of passing groups count. */
        groupPassCount: number;
        /** The number of todos. */
        todoCount: number;
        /** A collection of all the generated namespaces for shapshot purposes. */
        protected namespaces: Set<string>;
        /** The wasi instance associated with this module */
        private wasi;
        /** The WebAssembly.Instance object. */
        private instance;
        /** The module instance. */
        /**
         * A collection of reflected values used to help cache and aid in the creation
         * of nested reflected values.
         */
        private reflectedValueCache;
        /** A collection of errors. */
        errors: IWarning[];
        /** A collection of warnings. */
        warnings: IWarning[];
        /** A collection of collected snapshots. */
        snapshots: Snapshot;
        /** The expected snapshots. */
        expectedSnapshots: Snapshot;
        rtrace: Rtrace & {
            blocks: Map<number, number>;
        };
        /** The resulting snapshot diff. */
        snapshotDiff: SnapshotDiff | null;
        constructor(props: ITestContextParameters);
        /**
         * Track an rtrace error. This method should be bound and passed to the RTrace options.
         *
         * @param err - The error.
         * @param block - BlockInfo
         */
        private onRtraceError;
        private onRtraceInfo;
        /**
         * Call this method to start the `__main()` method provided by the `as-pect` exports to start the
         * process of test collection and evaluation.
         */
        run(wasm: InstantiateResult): void;
        /** Visit a node and evaluate it's children. */
        protected visit(node: TestNode): void;
        /** Report a TestNode */
        private reportTestNode;
        /** Obtain the stack trace, actual, expected, and message values, and attach them to a given node. */
        private collectStatistics;
        /** Add a test or group result to the statistics. */
        private addResult;
        /** Run a series of callbacks into web assembly. */
        private runFunctions;
        /** Run every before each callback in the proper order. */
        private runBeforeEach;
        /** Run every before each callback in the proper order. */
        private runAfterEach;
        /**
         * This method creates a WebAssembly imports object with all the TestContext functions
         * bound to the TestContext.
         *
         * @param {any[]} imports - Every import item specified.
         */
        createImports(...imports: any[]): any;
        /**
         * This function sets up a test group.
         *
         * @param {number} description - The test suite description string pointer.
         * @param {number} runner - The pointer to a test suite callback
         */
        private reportGroupTypeNode;
        /**
         * This function sets up a test node.
         *
         * @param description - The test description string pointer
         * @param runner - The pointer to a test callback
         */
        private reportTestTypeNode;
        /**
         * This function expects a throws from a test node.
         *
         * @param description - The test description string pointer
         * @param runner - The pointer to a test callback
         * @param message - The pointer to an additional assertion message in string
         */
        private reportNegatedTestNode;
        /**
         * This is called to stop the debugger.  e.g. `node --inspect-brk asp`.
         */
        private debug;
        /**
         * This is a web assembly utility function that wraps a function call in a try catch block to
         * report success or failure.
         *
         * @param {number} pointer - The function pointer to call. It must accept no parameters and return
         * void.
         * @returns {1 | 0} - If the callback was run successfully without error, it returns 1, else it
         * returns 0.
         */
        protected tryCall(pointer: number): 1 | 0;
        /**
         * This web assembly linked function sets the group's "beforeEach" callback pointer to
         * the current groupStackItem.
         *
         * @param {number} callbackPointer - The callback that should run before each test.
         */
        private reportBeforeEach;
        /**
         * This web assembly linked function adds the group's "beforeAll" callback pointer to
         * the current groupStackItem.
         *
         * @param {number} callbackPointer - The callback that should run before each test in the
         * current context.
         */
        private reportBeforeAll;
        /**
         * This web assembly linked function sets the group's "afterEach" callback pointer.
         *
         * @param {number} callbackPointer - The callback that should run before each test group.
         */
        private reportAfterEach;
        /**
         * This web assembly linked function adds the group's "afterAll" callback pointer to
         * the current groupStackItem.
         *
         * @param {number} callbackPointer - The callback that should run before each test in the
         * current context.
         */
        private reportAfterAll;
        /**
         * This function reports a single "todo" item in a test suite.
         *
         * @param {number} todoPointer - The todo description string pointer.
         * @param {number} _callbackPointer - The test callback function pointer.
         */
        private reportTodo;
        /**
         * This function overrides the provided AssemblyScript `env.abort()` function to catch abort
         * reasons.
         *
         * @param {number} reasonPointer - This points to the message value that causes the expectation to
         * fail.
         * @param {number} fileNamePointer - The file name that reported the error. (Ignored)
         * @param {number} line - The line that reported the error. (Ignored)
         * @param {number} col - The column that reported the error. (Ignored)
         */
        private abort;
        /**
         * Gets an error stack trace.
         */
        protected getErrorStackTrace(ex: Error): string;
        /**
         * Gets a log stack trace.
         */
        protected getLogStackTrace(): string;
        /** A map of strings that can be cached because they are static. */
        private cachedStrings;
        /**
         * This method is called when a memory block is deallocated from the heap.
         *
         * @param {number} block - This is a unique identifier for the affected block.
         */
        onfree(block: number): void;
        /**
         * This method is called when a memory block is allocated on the heap.
         *
         * @param {number} block - This is a unique identifier for the affected block.
         */
        onalloc(block: number): void;
        /**
         * Gets a string from the wasm module, unless the module string is null. Otherwise it returns
         * a default value.
         */
        protected getString(pointer: number, defaultValue: string): string;
        /**
         * An override implementation of the AssemblyScript trace function.
         *
         * @param {number} strPointer - The trace string.
         * @param {number} count - The number of arguments to be traced.
         * @param {number[]} args - The traced arguments.
         */
        private trace;
        /**
         * Retrieve the function name of a given web assembly function.
         *
         * @param {number} index - The function index
         */
        private funcName;
        private createReflectedValue;
        /**
         * Create a reflected number value.
         *
         * @param {1 | 0} signed - Indicate if the value is signed.
         * @param {number} size - The size of the value in bytes.
         * @param {ReflectedValueType} reflectedTypeValue - The ReflectedValueType
         * @param {number} typeName - The name of the type.
         * @param {number} value - The value itself
         */
        private createReflectedNumber;
        /**
         * Create reflection of a long number (not supported directly from javascript)
         */
        private createReflectedLong;
        /**
         * Log a reflected value.
         *
         * @param {number} id - The ReflectedValue id
         */
        private logReflectedValue;
        /**
         * Report an actual reflected value.
         *
         * @param {number} id - The ReflectedValue id
         */
        private reportActualReflectedValue;
        /**
         * Report an expected reflected value.
         *
         * @param {number} id - The ReflectedValue id
         */
        private reportExpectedReflectedValue;
        /**
         * Push a reflected value to a given reflected value.
         *
         * @param {number} reflectedValueID - The target reflected value parent.
         * @param {number} childID - The child value by it's id to be pushed.
         */
        private pushReflectedObjectValue;
        /**
         * Push a reflected value key to a given reflected value.
         *
         * @param {number} reflectedValueID - The target reflected value parent.
         * @param {number} keyId - The target reflected value key to be pushed.
         */
        private pushReflectedObjectKey;
        /**
         * Clear the expected value.
         */
        private clearExpected;
        /**
         * Clear the actual value.
         */
        private clearActual;
        /**
         * Report an expected truthy value, and if it's negated.
         *
         * @param {1 | 0} negated - An indicator if the expectation is negated.
         */
        private reportExpectedTruthy;
        /**
         * Report an expected truthy value, and if it's negated.
         *
         * @param {1 | 0} negated - An indicator if the expectation is negated.
         */
        private reportExpectedFalsy;
        /**
         * Report an expected finite value, and if it's negated.
         *
         * @param {1 | 0} negated - An indicator if the expectation is negated.
         */
        private reportExpectedFinite;
        /**
         * Attaches a stack trace to the given reflectedValue by it's id.
         *
         * @param {number} reflectedValueID - The given reflected value by it's id.
         */
        private attachStackTraceToReflectedValue;
        /** Push an error to the errors array. */
        protected pushError(error: IWarning): void;
        /** Push an warning to the warnings array. */
        protected pushWarning(warning: IWarning): void;
        /**
         * Report an expected snapshot.
         *
         * @param {number} reflectedValueID - The id of the reflected actual value.
         * @param {number} namePointer - The name of the snapshot.
         */
        protected reportExpectedSnapshot(reflectedValueID: number, namePointer: number): void;
    }
}
declare module "reporter/CombinationReporter" {
    import { TestContext } from "test/TestContext";
    import { IReporter } from "reporter/IReporter";
    import { TestNode } from "test/TestNode";
    /**
     * This reporter is used to combine a set of reporters into a single reporter object. It uses
     * forEach() to call each reporter's function when each method is called.
     */
    export class CombinationReporter implements IReporter {
        protected reporters: IReporter[];
        constructor(reporters: IReporter[]);
        onEnter(ctx: TestContext, node: TestNode): void;
        onExit(ctx: TestContext, node: TestNode): void;
        onFinish(ctx: TestContext): void;
    }
}
declare module "reporter/EmptyReporter" {
    import { IReporter } from "reporter/IReporter";
    import { TestContext } from "test/TestContext";
    import { TestNode } from "test/TestNode";
    /**
     * This class can be used as a stub reporter to interface with the `TestContext` in the browser.
     * It will not report any information about the tests.
     */
    export class EmptyReporter implements IReporter {
        constructor(_options?: any);
        onEnter(_context: TestContext, _node: TestNode): void;
        onExit(_context: TestContext, _node: TestNode): void;
        onFinish(_context: TestContext): void;
    }
}
declare module "util/IWriteable" {
    /**
     * This interface is a utitily used to describe the shape of something that has a `write()` method.
     */
    export interface IWritable {
        /** This method is used for writing string contents to something that is writable. */
        write(chunk: string): void;
    }
}
declare module "reporter/SummaryReporter" {
    import { TestContext } from "test/TestContext";
    import { IWritable } from "util/IWriteable";
    import { ReflectedValue } from "util/ReflectedValue";
    import { IReporter } from "reporter/IReporter";
    import { TestNode } from "test/TestNode";
    /**
     * This test reporter should be used when logging output and test validation only needs happen on
     * the group level. It is useful for CI builds and also reduces IO output to speed up the testing
     * process.
     */
    export class SummaryReporter implements IReporter {
        private enableLogging;
        constructor(options?: any);
        onEnter(_ctx: TestContext, _node: TestNode): void;
        onExit(_ctx: TestContext, _node: TestNode): void;
        onStart(_ctx: TestContext): void;
        onGroupStart(_node: TestNode): void;
        onGroupFinish(_node: TestNode): void;
        onTestStart(_group: TestNode, _test: TestNode): void;
        onTestFinish(_group: TestNode, _test: TestNode): void;
        onTodo(): void;
        stdout: IWritable | null;
        stderr: IWritable | null;
        /**
         * This method reports a test context is finished running.
         *
         * @param {TestContext} suite - The finished test suite.
         */
        onFinish(suite: TestContext): void;
        /**
         * A custom logger function for the default reporter that writes the log values using `console.log()`
         *
         * @param {ReflectedValue} logValue - A value to be logged to the console
         */
        onLog(logValue: ReflectedValue): void;
    }
}
declare module "reporter/VerboseReporter" {
    import { TestContext } from "test/TestContext";
    import { IWritable } from "util/IWriteable";
    import { ReflectedValue } from "util/ReflectedValue";
    import { TestNode } from "test/TestNode";
    import { IReporter } from "reporter/IReporter";
    import { StringifyReflectedValueProps } from "util/stringifyReflectedValue";
    /**
     * This is the default test reporter class for the `asp` command line application. It will pipe
     * all relevant details about each tests to the `stdout` WriteStream.
     */
    export class VerboseReporter implements IReporter {
        stdout: IWritable | null;
        stderr: IWritable | null;
        /** A set of default stringify properties that can be overridden. */
        protected stringifyProperties: Partial<StringifyReflectedValueProps>;
        constructor(_options?: any);
        onEnter(_ctx: TestContext, node: TestNode): void;
        onExit(_ctx: TestContext, node: TestNode): void;
        /**
         * This method reports a TestGroup is starting.
         *
         * @param {TestNode} group - The started test group.
         */
        onGroupStart(group: TestNode): void;
        /**
         * This method reports a completed TestGroup.
         *
         * @param {TestGroup} group - The finished TestGroup.
         */
        onGroupFinish(group: TestNode): void;
        /** This method is a stub for onTestStart(). */
        onTestStart(_group: TestNode, _test: TestNode): void;
        /**
         * This method reports a completed test.
         *
         * @param {TestNode} _group - The TestGroup that the TestResult belongs to.
         * @param {TestNode} test - The finished TestResult
         */
        onTestFinish(_group: TestNode, test: TestNode): void;
        /**
         * This method reports that a TestContext has finished.
         *
         * @param {TestContext} suite - The finished test context.
         */
        onFinish(suite: TestContext): void;
        /**
         * This method reports a todo to stdout.
         *
         * @param {TestGroup} _group - The test group the todo belongs to.
         * @param {string} todo - The todo.
         */
        onTodo(_group: TestNode, todo: string): void;
        /**
         * A custom logger function for the default reporter that writes the log values using `console.log()`
         *
         * @param {ReflectedValue} logValue - A value to be logged to the console
         */
        onLog(logValue: ReflectedValue): void;
    }
}
declare module "index" {
    export * from "reporter/CombinationReporter";
    export * from "reporter/EmptyReporter";
    export * from "reporter/IReporter";
    export * from "reporter/SummaryReporter";
    export * from "reporter/VerboseReporter";
    export * from "test/IWarning";
    export * from "test/TestContext";
    export * from "test/TestNode";
    export * from "util/IAspectExports";
    export * from "util/ReflectedValue";
    export * from "util/TestNodeType";
}
declare module "transform/assemblyscript" {
    export var Transform: any;
    const _exports: any;
    export = _exports;
}
declare module "transform/createGenericTypeParameter" {
    import { Range, TypeNode } from "./assemblyscript";
    /**
     * This method makes a generic named parameter.
     *
     * @param {string} name - The name of the type.
     * @param {Range} range - The range given for the type parameter.
     */
    export function createGenericTypeParameter(name: string, range: Range): TypeNode;
}
declare module "transform/hash" {
    /**
     * A simple djb2hash that returns a hash of a given string. See http://www.cse.yorku.ca/~oz/hash.html
     * for implementation details.
     *
     * @param {string} str - The string to be hashed
     * @returns {number} The hash of the string
     */
    export function djb2Hash(str: string): number;
}
declare module "transform/createAddReflectedValueKeyValuePairsMember" {
    import { ClassDeclaration, MethodDeclaration } from "./assemblyscript";
    /**
     * Create a prototype method called __aspectAddReflectedValueKeyValuePairs on a given
     * ClassDeclaration dynamically.
     *
     * @param {ClassDeclaration} classDeclaration - The target classDeclaration
     */
    export function createAddReflectedValueKeyValuePairsMember(classDeclaration: ClassDeclaration): MethodDeclaration;
}
declare module "transform/createStrictEqualsMember" {
    import { ClassDeclaration, MethodDeclaration } from "./assemblyscript";
    /**
     * This method creates a single FunctionDeclaration that allows Reflect.equals
     * to validate normal class member values.
     *
     * @param {ClassDeclaration} classDeclaration - The class that requires a new function.
     */
    export function createStrictEqualsMember(classDeclaration: ClassDeclaration): MethodDeclaration;
}
declare module "transform/emptyTransformer" {
    import { Parser } from "./assemblyscript";
    const _default: {
        new (): {
            afterParse(_parser: Parser): void;
            readonly program: import("transform/assemblyscript").Program;
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
            afterInitialize?(program: import("transform/assemblyscript").Program): void;
            afterCompile?(module: import("transform/assemblyscript").Module): void;
        };
    };
    /**
     * Just an empty transformer.
     */
    export = _default;
}
declare module "transform/index" {
    import { Parser } from "./assemblyscript";
    const _default_1: {
        new (): {
            /**
             * This method results in a pure AST transform that inserts a strictEquals member
             * into each ClassDeclaration.
             *
             * @param {Parser} parser - The AssemblyScript parser.
             */
            afterParse(parser: Parser): void;
            readonly program: import("transform/assemblyscript").Program;
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
            afterInitialize?(program: import("transform/assemblyscript").Program): void;
            afterCompile?(module: import("transform/assemblyscript").Module): void;
        };
    };
    export = _default_1;
}
declare module "util/rTrace" {
    export const BLOCK_OVERHEAD: number;
    export const OBJECT_OVERHEAD: 16;
    export const TOTAL_OVERHEAD: number;
    export class Rtrace {
        constructor(options: any);
        options: any;
        onerror: any;
        oninfo: any;
        oncollect_: any;
        memory: any;
        shadow: WebAssembly.Memory | null;
        shadowStart: number;
        blocks: Map<any, any>;
        allocSites: Map<any, any>;
        freedBlocks: Map<any, any>;
        gcProfileStart: number;
        gcProfile: any[];
        allocCount: number;
        resizeCount: number;
        moveCount: number;
        freeCount: number;
        heapBase: number;
        install(imports: any): any;
        /** Synchronizes the shadow memory with the module's memory. */
        syncShadow(): void;
        /** Marks a block's presence in shadow memory. */
        markShadow(info: any, oldSize?: number): void;
        /** Unmarks a block's presence in shadow memory. */
        unmarkShadow(info: any, oldSize?: any): void;
        /** Performs an access to shadow memory. */
        accessShadow(ptr: any, size: any, isLoad: any, isRT: any): void;
        /** Obtains information about a block. */
        getBlockInfo(ptr: any): {
            ptr: any;
            size: number;
            mmInfo: {
                tags: string;
                size: number;
            };
            gcInfo: {
                color: string;
                next: number;
                prev: number;
            };
            rtId: number;
            rtSize: number;
        };
        /** Checks if rtrace is active, i.e. at least one event has occurred. */
        get active(): boolean;
        /** Checks if there are any leaks and emits them via `oninfo`. Returns the number of live blocks. */
        check(): number;
        oninit(heapBase: any): void;
        onalloc(ptr: any): void;
        onresize(ptr: any, oldSize: any): void;
        onmove(oldPtr: any, newPtr: any): void;
        onvisit(ptr: any): boolean;
        onfree(ptr: any): void;
        oncollect(total: any): void;
        plot(total: any, pause?: number): void;
        oninterrupt(total: any): void;
        interruptStart: number | undefined;
        onyield(total: any): void;
        onstore(ptr: any, offset: any, bytes: any, isRT: any): any;
        onload(ptr: any, offset: any, bytes: any, isRT: any): any;
    }
}
//# sourceMappingURL=as-pect.core.amd.d.ts.map