import { TestNodeType } from "../util/TestNodeType";
import { IWarning } from "./IWarning";
import { ReflectedValue } from "../util/ReflectedValue";
export declare class TestNode {
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
//# sourceMappingURL=TestNode.d.ts.map