import { TestContext } from "../test/TestContext";
import { IReporter } from "./IReporter";
import { TestNode } from "../test/TestNode";
/**
 * This reporter is used to combine a set of reporters into a single reporter object. It uses
 * forEach() to call each reporter's function when each method is called.
 */
export declare class CombinationReporter implements IReporter {
    protected reporters: IReporter[];
    constructor(reporters: IReporter[]);
    onEnter(ctx: TestContext, node: TestNode): void;
    onExit(ctx: TestContext, node: TestNode): void;
    onFinish(ctx: TestContext): void;
}
//# sourceMappingURL=CombinationReporter.d.ts.map