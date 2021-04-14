import { TestContext } from "../test/TestContext";
import { IWritable } from "../util/IWriteable";
import { ReflectedValue } from "../util/ReflectedValue";
import { TestNode } from "../test/TestNode";
import { IReporter } from "./IReporter";
import { StringifyReflectedValueProps } from "../util/stringifyReflectedValue";
/**
 * This is the default test reporter class for the `asp` command line application. It will pipe
 * all relevant details about each tests to the `stdout` WriteStream.
 */
export declare class VerboseReporter implements IReporter {
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
//# sourceMappingURL=VerboseReporter.d.ts.map