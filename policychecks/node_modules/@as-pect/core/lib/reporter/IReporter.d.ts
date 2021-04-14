import { TestNode } from "../test/TestNode";
import { TestContext } from "../test/TestContext";
export interface IReporter {
    onEnter(ctx: TestContext, node: TestNode): void;
    onExit(ctx: TestContext, node: TestNode): void;
    onFinish(ctx: TestContext): void;
}
//# sourceMappingURL=IReporter.d.ts.map