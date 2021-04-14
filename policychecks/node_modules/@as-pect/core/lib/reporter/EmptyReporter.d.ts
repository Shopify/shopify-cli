import { IReporter } from "./IReporter";
import { TestContext } from "../test/TestContext";
import { TestNode } from "../test/TestNode";
/**
 * This class can be used as a stub reporter to interface with the `TestContext` in the browser.
 * It will not report any information about the tests.
 */
export declare class EmptyReporter implements IReporter {
    constructor(_options?: any);
    onEnter(_context: TestContext, _node: TestNode): void;
    onExit(_context: TestContext, _node: TestNode): void;
    onFinish(_context: TestContext): void;
}
//# sourceMappingURL=EmptyReporter.d.ts.map