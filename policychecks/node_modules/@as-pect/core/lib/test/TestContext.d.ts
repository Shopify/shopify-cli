import { IAspectExports } from "../util/IAspectExports";
import { Rtrace } from "../util/rTrace";
import { NameSection } from "../util/wasmTools";
import { ReflectedValue } from "../util/ReflectedValue";
import { TestNode } from "./TestNode";
import { IReporter } from "../reporter/IReporter";
import { IWarning } from "./IWarning";
import { Snapshot, SnapshotDiff } from "@as-pect/snapshots";
declare type WASI = import("wasi").WASI;
declare type InstantiateResult = {
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
export declare class TestContext {
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
export {};
//# sourceMappingURL=TestContext.d.ts.map