import { noOp } from "./noOp";

// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "beforeEach")
@global
export declare function beforeEach(callback: () => void): void;

// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "beforeAll")
@global
export declare function beforeAll(callback: () => void): void;

// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "afterEach")
@global
export declare function afterEach(callback: () => void): void;

// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "afterAll")
@global
export declare function afterAll(callback: () => void): void;

// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "reportTodo")
@global
export declare function todo(description: string): void;

// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "debug")
@global
export declare function debug(): void;

// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "reportTodo")
@global
export declare function xit(description: string, callback: () => void): void;

// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "reportTodo")
@global
export declare function xtest(description: string, callback: () => void): void;

// @ts-ignore: decorators *are* valid here
@external("__aspect", "reportTestTypeNode")
@global
export declare function it(description: string, runner: () => void): void;

// @ts-ignore: decorators *are* valid here
@external("__aspect", "reportTestTypeNode")
@global
export declare function test(description: string, runner: () => void): void;

// @ts-ignore: decorators *are* valid here
@external("__aspect", "reportNegatedTestNode")
@global
export declare function itThrows(
  description: string,
  runner: () => void,
  // @ts-ignore: this is a valid syntax
  message: string | null = null,
): void;

// @ts-ignore: decorators *are* valid here
@external("__aspect", "reportNegatedTestNode")
@global
export declare function throws(
  description: string,
  runner: () => void,
  // @ts-ignore: this is a valid syntax
  message: string | null = null,
): void;

// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "reportGroupTypeNode")
@global
export declare function describe(
  // @ts-ignore: this is a valid syntax
  description: string = "",
  // @ts-ignore: this is a valid syntax
  runner: () => void = noOp,
): void;
