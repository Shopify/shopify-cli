import { TestContext } from "../test/TestContext";
import { IWritable } from "../util/IWriteable";
import { ReflectedValue } from "../util/ReflectedValue";
import { IReporter } from "./IReporter";
import { TestNode } from "../test/TestNode";
/**
 * This test reporter should be used when logging output and test validation only needs happen on
 * the group level. It is useful for CI builds and also reduces IO output to speed up the testing
 * process.
 */
export declare class SummaryReporter implements IReporter {
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
//# sourceMappingURL=SummaryReporter.d.ts.map