/**
 * This function creates a test group in the test loader.
 *
 * @param {string} description  - This is the name of the test group.
 * @param {() => void} callback - A function that contains all of the closures for this test group.
 *
 * @example
 *
 * ```ts
 * describe("my test suite", (): void => {
 *   // put your tests here
 * });
 * ```
 */
declare function describe(description: string, callback: () => void): void;

/**
 * This function creates a test inside the given test group. It must be placed inside a describe
 * block.
 *
 * @param {string} description - This is the name of the test, and should describe a behavior.
 * @param {() => void} callback - A function that contains a set of expectations for this test.
 *
 * @example
 *
 * ```ts
 * describe("the meaning of life", (): void => {
 *   it("should be 42", (): void => {
 *     // put your expectations here
 *     expect<i32>(29 + 13).toBe(42);
 *   });
 * });
 * ```
 */
declare function it(description: string, callback: () => void): void;

/**
 * A test that does not run, and is longhand equivalent to using todo function without a
 * callback. This test does not get run and is reported like a todo.
 *
 * @param {string} description - This is the name of the test, and should describe a behavior.
 * @param {() => void} callback - A function that contains a set of expectations for this test.
 */
declare function xit(description: string, callback: () => void): void;

/**
 * A test that does not run, and is longhand equivalent to using todo function without a
 * callback. This test does not get run and is reported like a todo.
 *
 * @param {string} description - This is the name of the test, and should describe a behavior.
 * @param {() => void} callback - A function that contains a set of expectations for this test.
 */
declare function xtest(description: string, callback: () => void): void;

/**
 * This function creates a test inside the given test group. It must be placed inside a describe
 * block.
 *
 * @param {string} description - This is the name of the test, and should describe a behavior.
 * @param {() => void} callback - A function that contains a set of expectations for this test.
 *
 * @example
 * ```ts
 * describe("the meaning of life", (): void => {
 *   test("the value should be 42", (): void => {
 *     // put your expectations here
 *     expect<i32>(29 + 13).toBe(42);
 *   });
 * });
 * ```
 */
declare function test(description: string, callback: () => void): void;

/**
 * This function creates a test that is expected to fail. This is useful to verify if a given
 * behavior is expected to throw.
 *
 * @param {string} description - This is the name of the test, and should describe a behavior.
 * @param {() => void} callback - A function that contains a set of expectations for this test.
 * @param {string?} message - A message that describes why the test should fail.
 *
 * @example
 *
 * ```ts
 * describe("the meaning of life", (): void => {
 *   throws("the value should be 42", (): void => {
 *     // put your expectations here
 *     expect<i32>(29 + 13).not.toBe(42);
 *   });
 * });
 * ```
 */
declare function throws(
  description: string,
  callback: () => void,
  message?: string,
): void;

/**
 * This function creates a test that is expected to fail. This is useful to verify if a given
 * behavior is expected to throw.
 *
 * @param {string} description - This is the name of the test, and should describe a behavior.
 * @param {() => void} callback - A function that contains a set of expectations for this test.
 * @param {string?} message - A message that describes why the test should fail.
 *
 * @example
 *
 * ```ts
 * describe("the meaning of life", (): void => {
 *   itThrows("when the value should be 42", (): void => {
 *     // put your expectations here
 *     expect<i32>(29 + 13).not.toBe(42);
 *   }, "The value is actually 42.");
 * });
 * ```
 */
declare function itThrows(
  description: string,
  callback: () => void,
  message?: string,
): void;

/**
 * This function creates a callback that is called before each individual test is run in this test
 * group.
 *
 * @param {function} callback - The function to be run before each test in the current test group.
 *
 * @example
 *
 * ```ts
 * // create a global
 * var cat: Cat = new Cat();
 *
 * describe("cats", (): void => {
 *   beforeEach((): void => {
 *     cat.meow(1); // meow once per test
 *   });
 * });
 * ```
 */
declare function beforeEach(callback: () => void): void;

/**
 * This function creates a callback that is called before the whole test group is run, and only
 * once.
 *
 * @param {function} callback - The function to be run before each test in the current test group.
 *
 * @example
 *
 * ```ts
 * // create a global
 * var dog: Dog = null;
 * describe("dogs", (): void => {
 *   beforeAll((): void => {
 *     dog = new Dog(); // create a single dog once before the tests start
 *   });
 * });
 * ```
 */
declare function beforeAll(callback: () => void): void;

/**
 * This function creates a callback that is called after each individual test is run in this test
 * group.
 *
 * @param {function} callback - The function to be run after each test in the current test group.
 *
 * @example
 *
 * ```ts
 * // create a global
 * var cat: Cat = new Cat();
 *
 * describe("cats", (): void => {
 *   afterEach((): void => {
 *     cat.sleep(12); // cats sleep a lot
 *   });
 * });
 * ```
 */
declare function afterEach(callback: () => void): void;

/**
 * This function creates a callback that is called after the whole test group is run, and only
 * once.
 *
 * @param {function} callback - The function to be run after each test in the current test group.
 *
 * @example
 *
 * ```ts
 * // create a global
 * var dog: Dog = null;
 * describe("dogs", (): void => {
 *   afterAll((): void => {
 *     memory.free(changetype<usize>(dog)); // free some memory
 *   });
 * });
 * ```
 */
declare function afterAll(callback: () => void): void;

/**
 * Describes a value and returns an expectation to test the value.
 *
 * @type {T} - The expectation's type.
 * @param {T} actual - The value being tested.
 *
 * @example
 *
 * ```ts
 * expect<i32>(42).not.toBe(-1, "42 should not be -1");
 * expect<i32>(19 + 23).toBe(42, "19 + 23 should equal 42");
 * ```
 */
declare function expect<T>(actual: T | null): Expectation<T>;

/**
 * Describes a void function and returns an expectation to test the function.
 *
 * @param {() => void} callback - The callback being tested.
 *
 * @example
 *
 * ```ts
 * expectFn((): void => unreachable()).toThrow("unreachables do not throw");
 * expectFn((): void => {
 *   cat.meow();
 * }).not.toThrow("Uhoh, cats can't meow!");;
 * ```
 */
declare function expectFn(cb: () => void): Expectation<() => void>;

/**
 * Describes a test that needs to be written.
 *
 * @param {string} description - The description of the test that needs to be written.
 */
declare function todo(description: string): void;

/**
 * Logs a single value to the logger, and is stringified. It works for references, values, and
 * strings.
 *
 * @type {T} - The type to be logged.
 * @param {T | null} value - The value to be logged.
 *
 * @example
 *
 * ```ts
 * log<string>("This is a logged value.");
 * log<i32>(42);
 * log<Vec3>(new Vec(1, 2, 3));
 * log<Vec3>(null);
 * ```
 */
declare function log<T>(value: T | null): void;

/**
 * An expectation for a value.
 */
// @ts-ignore
declare class Expectation<T> {
  /**
   * Create a new expectation.
   *
   * @param {T | null} actual - The actual value of the expectation.
   */
  constructor(actual: T | null);

  /**
   * This expectation performs a strict equality on value types and reference types.
   *
   * @param {T | null} expected - The value to be compared.
   * @param {string} message - The optional message that describes the expectation.
   *
   * @example
   *
   * ```ts
   * expect<i32>(42).not.toBe(-1, "42 should not be -1");
   * expect<i32>(19 + 23).toBe(42, "19 + 23 should equal 42");
   * ```
   */
  toBe(expected: T | null, message?: string): void;

  /**
   * This expectation performs a strict equality on value types and performs a memcompare on
   * reference types. If the reference type `T` has reference types as properties, the comparison does
   * not perform property traversal. It will only compare the pointer values in the memory block, and
   * only compare `offsetof<T>()` bytes, regardless of the allocated block size.
   *
   * @param {T | null} expected - The value to be compared.
   * @param {string} message - The optional message that describes the expectation.
   *
   * @example
   *
   * ```ts
   * expect<Vec3>(new Vec3(1, 2, 3)).toStrictEqual(new Vec(1, 2, 3), "Vectors of the same shape should be equal");
   * ```
   */
  toStrictEqual(expected: T | null, message?: string): void;

  /**
   * This expectation performs a strict memory block equality based on the allocated block sizes.
   *
   * @param {T | null} expected - The value to be compared.
   * @param {string} message - The optional message that describes the expectation.
   *
   * @example
   *
   * ```ts
   * expect<Vec3>(new Vec3(1, 2, 3)).toBlockEqual(new Vec(1, 2, 3), "Vectors of the same shape should be equal");
   * ```
   */
  toBlockEqual(expected: T | null, message?: string): void;

  /**
   * If the value is callable, it calls the function, and fails the expectation if it throws, or hits
   * an unreachable().
   *
   * @param {string} message - The optional message that describes the expectation.
   *
   * @example
   *
   * ```ts
   * expectFn((): void => unreachable()).toThrow("unreachable() should throw.");
   * expectFn((): void => {
   *   cat.sleep(100); // cats can sleep quite a lot
   * }).not.toThrow("cats should sleep, not throw");
   * ```
   */
  toThrow(message?: string): void;

  /**
   * This expecation asserts that the value is truthy, like in javascript. If the value is a string,
   * then strings of length 0 are not truthy.
   *
   * @param {string} message - The optional message that describes the expectation.
   *
   * @example
   *
   * ```ts
   * expect<bool>(true).toBeTruthy("true is truthy.");
   * expect<i32>(1).toBeTruthy("numeric values that are not 0 are truthy.");
   * expect<Vec3>(new Vec3(1, 2, 3)).toBeTruthy("reference types that aren't null are truthy.");
   * expect<bool>(false).not.toBeTruthy("false is not truthy.");
   * expect<i32>(0).not.toBeTruthy("0 is not truthy.");
   * expect<Vec3>(null).not.toBeTruthy("null is not truthy.");
   * ```
   */
  toBeTruthy(message?: string): void;

  /**
   * This expectation tests the value to see if it is null. If the value is a value type, it is
   * never null. If the value is a reference type, it performs a strict null comparison.
   *
   * @param {string} message - The optional message that describes the expectation.
   *
   * @example
   *
   * ```ts
   * expect<i32>(0).not.toBeNull("numbers are never null");
   * expect<Vec3>(null).toBeNull("null reference types are null.");
   * ```
   */
  toBeNull(message?: string): void;

  /**
   * This expecation assert that the value is falsy, like in javascript. If the value is a string,
   * then strings of length 0 are falsy.
   *
   * @param {string} message - The optional message that describes the expectation.
   *
   * @example
   *
   * ```ts
   * expect<bool>(false).toBeFalsy("false is falsy.");
   * expect<i32>(0).toBeFalsy("0 is falsy.");
   * expect<Vec3>(null).toBeFalsy("null is falsy.");
   * expect<bool>(true).not.toBeFalsy("true is not falsy.");
   * expect<i32>(1).not.toBeFalsy("numeric values that are not 0 are not falsy.");
   * expect<Vec3>(new Vec3(1, 2, 3)).not.toBeFalsy("reference types that aren't null are not falsy.");
   * ```
   */
  toBeFalsy(message?: string): void;

  /**
   * This expectation asserts that the value is greater than the expected value. Since operators can
   * be overloaded in assemblyscript, it's possible for this to work on reference types.
   *
   * @param {T | null} expected - The expected value that the actual value should be greater than.
   * @param {string} message - The optional message that describes this expectation.
   *
   * @example
   *
   * ```ts
   * expect<i32>(10).toBeGreaterThan(4);
   * expect<i32>(12).not.toBeGreaterThan(42);
   * ```
   */
  toBeGreaterThan(expected: T | null, message?: string): void;

  /**
   * This expectation asserts that the value is less than the expected value. Since operators can
   * be overloaded in assemblyscript, it's possible for this to work on reference types.
   *
   * @param {T | null} value - The expected value that the actual value should be less than.
   * @param {string} message - The optional message that describes this expectation.
   *
   * @example
   *
   * ```ts
   * expect<i32>(10).not.toBeLessThan(4);
   * expect<i32>(12).toBeLessThan(42);
   * ```
   */
  toBeLessThan(expected: T | null, message?: string): void;

  /**
   * This expectation asserts that the value is greater than or equal to the expected value. Since
   * operators can be overloaded in assemblyscript, it's possible for this to work on reference
   * types.
   *
   * @param {T | null} value - The expected value that the actual value should be greater than or
   * equal to.
   * @param {string} message - The optional message that describes this expectation.
   *
   * @example
   *
   * ```ts
   * expect<i32>(42).toBeGreaterThanOrEqual(42);
   * expect<i32>(10).toBeGreaterThanOrEqual(4);
   * expect<i32>(12).not.toBeGreaterThanOrEqual(42);
   * ```
   */
  toBeGreaterThanOrEqual(expected: T | null, message?: string): void;

  /**
   * This expectation asserts that the value is less than or equal to the expected value. Since
   * operators can be overloaded in assemblyscript, it's possible for this to work on reference
   * types.
   *
   * @param {T | null} value - The expected value that the actual value should be less than or equal
   * to.
   * @param {string} message - The optional message that describes this expectation.
   *
   * @example
   *
   * ```ts
   * expect<i32>(42).toBeLessThanOrEqual(42);
   * expect<i32>(10).not.toBeLessThanOrEqual(4);
   * expect<i32>(12).toBeLessThanOrEqual(42);
   * ```
   */
  toBeLessThanOrEqual(expected: T | null, message?: string): void;

  /**
   * This expectation asserts that the value is close to another value. Both numbers must be finite,
   * and T must extend f64 or f32.
   *
   * @param {T extends f64 | f32} value - The expected value to be close to.
   * @param {i32} decimalPlaces - The number of decimal places used to calculate epsilon. Default is
   * 2.
   * @param {string} message - The optional message that describes this expectation.
   *
   * @example
   *
   * ```ts
   * expect<f64>(0.1 + 0.2).toBeCloseTo(0.3);
   * ```
   */
  toBeCloseTo(expected: T, decimalPlaces?: number, message?: string): void;

  /**
   * This function asserts the float type value is NaN.
   *
   * @param {string} message - The optional message the describes this expectation.
   *
   * @example
   *
   * ```ts
   * expect<f64>(NaN).toBeNaN();
   * expect<f32>(42).not.toBeNaN();
   * ```
   */
  toBeNaN(message?: string): void;

  /**
   * This function asserts a float is finite.
   *
   * @param {string} message - The optional message the describes this expectation.
   * @example
   *
   * ```ts
   * expect<f32>(42).toBeFinite();
   * expect<f64>(Infinity).not.toBeFinite();
   * ```
   */
  toBeFinite(message?: string): void;

  /**
   * This method asserts the item has the expected length.
   *
   * @param {i32} expected - The expected length.
   * @param {string} message - The optional message the describes this expectation.
   *
   * ```ts
   * expect<i32[]>([1, 2, 3]).toHaveLength(3);
   * ```
   */
  toHaveLength(expected: i32, message?: string): void;

  /**
   * This method asserts that a given T that extends `Array<U>` has a value/reference included.
   *
   * @param {valueof<T>} expected - The expected item to be included in the Array.
   * @param {string} message - The optional message the describes this expectation.
   *
   * @example
   *
   * ```ts
   * expect<i32[]>([1, 2, 3]).toInclude(3);
   * ```
   */
  // @ts-ignore: expected value should be known at compile time
  toInclude<U extends valueof<T> | indexof<T>>(
    expected: U,
    message?: string,
  ): void;

  /**
   * This method asserts that a given T that extends `Array<U>` has a value/reference included.
   *
   * @param {valueof<T>} expected - The expected item to be included in the Array.
   * @param {string} message - The optional message the describes this expectation.
   *
   * @example
   *
   * ```ts
   * expect<i32[]>([1, 2, 3]).toContain(3);
   * ```
   */
  // @ts-ignore: expected value should be known at compile time
  toContain(expected: valueof<T>, message?: string): void;

  /**
   * This method asserts that a given T that extends `Array<U>` has a value/reference included and
   * compared via memory.compare().
   *
   * @param {i32} expected - The expected item to be included in the Array.
   * @param {string} message - The optional message the describes this expectation.
   *
   * @example
   * ```ts
   * expect<Vec3[]>([new Vec3(1, 2, 3)]).toInclude(new Vec3(1, 2, 3));
   * ```
   */
  // @ts-ignore: expected value should be known at compile time
  toIncludeEqual<U extends indexof<T> | valueof<T>>(
    expected: U,
    message?: string,
  ): void;

  /**
   * This method asserts that a given T that extends `Array<U>` has a value/reference included and
   * compared via memory.compare().
   *
   * @param {i32} expected - The expected item to be included in the Array.
   * @param {string} message - The optional message the describes this expectation.
   *
   * @example
   * ```ts
   * expect<Vec3[]>([new Vec3(1, 2, 3)]).toInclude(new Vec3(1, 2, 3));
   * ```
   */
  // @ts-ignore: expected value should be known at compile time
  toContainEqual<U extends indexof<T> | valueof<T>>(
    expected: U,
    message?: string,
  ): void;

  /**
   * Match a snapshot with a given name for this test.
   *
   * @param {string | null} name - The snapshot name.
   */
  toMatchSnapshot(name?: string | null): void;

  /**
   * This computed property is chainable, and negates the existing expectation. It returns itself.
   *
   * @example
   * ```ts
   * expect<i32>(42).not.toBe(0, "42 is not 0");
   */
  not: Expectation<T>;

  /**
   * The actual value of the expectation.
   */
  actual: T | null;
}

/**
 * This is called to stop the debugger.  e.g. `node --inspect-brk asp`.
 */
declare function debug(): void;

/**
 * This class is static and contains private global values that contain metadata about the Actual
 * value.
 *
 * @example
 * ```ts
 * Actual.report<string>("This is an expected string.");
 * Actual.report<i32[]>([1, 2, 3]);
 * Actual.report<u8>(42);
 * ```
 */
declare class Actual {
  /**
   * This function performs reporting to javascript what the actual value of this expectation is.
   *
   * @param {T} actual - The actual value to be reported.
   */
  public static report<T>(value: T): void;

  /**
   * Clear the actual value and release any private memory stored as a global.
   */
  public static clear(): void;
}

/**
 * This class is static and contains private global values that contain metadata about the Expected
 * value.
 *
 * @example
 * ```ts
 * Expected.report<string>("This is an expected string.");
 * Expected.report<i32[]>([1, 2, 3]);
 * Expected.report<u8>(42, i32(true)); // not 42
 * ```
 */
declare class Expected {
  /**
   * This function performs reporting to javascript what the expected value of this expectation is.
   * It notifies javascript if the expectation is negated.
   *
   * @param {T} value - The actual value to be reported.
   * @param {i32} negated - An indicator if the expectation is negated. Pass `1` to negate the
   * expectation. (default: 0)
   */
  public static report<T>(value: T, negated?: i32): void;

  /**
   * Report an expected truthy value to the host, and if the expectation is negated.
   *
   * @param {i32} negated - A value, 1 or 0 indicating if the expectation is negated.
   */
  static reportTruthy(negated?: i32): void;

  /**
   * Report an expected falsy value to the host, and if the expectation is negated.
   *
   * @param {i32} negated - A value, 1 or 0 indicating if the expectation is negated.
   */
  static reportFalsy(negated?: i32): void;

  /**
   * Report an expected finite value to the host, and if the expectation is negated.
   *
   * @param {i32} negated - A value, 1 or 0 indicating if the expectation is negated.
   */
  static reportFinite(negated?: i32): void;

  /**
   * Report a snapshot of type T with a given name.
   *
   * @param {T} actual - The actual value.
   * @param {string} name - The snapshot name.
   */
  static reportSnapshot<T>(actual: T, name?: string | null): void;

  /**
   * Clear the expected value and release any private memory stored as a global.
   */
  public static clear(): void;
}

/**
 * Reflection namespace for comparing references of a specific type.
 */
declare class Reflect {
  /** A successful matching indicator. */
  public static SUCCESSFUL_MATCH: i32;
  /** An indicator that a matching operation has failed. */
  public static FAILED_MATCH: i32;
  /** A const to define when a matching operation should wait because a circular reference is currently resolving a match. */
  public static DEFER_MATCH: i32;

  /**
   * Create a reflected value for inspection.
   *
   * @param {T} value - The value to be inspected.
   * @param {Map<usize, i32>?} seen - A map of pointers to hostValues for caching purposes.
   */
  public static toReflectedValue<T>(value: T, seen?: Map<usize, i32>): i32;
  /**
   * A method used for comparing two values or references to determine if they match each other.
   *
   * @param {T} left - One of the values being compared.
   * @param {T} right - One of the values being compared.
   * @param {usize[]} stack - Internal use only, used to prevent recursion.
   * @param {usize[]} cache - Internal use only, used to prevent recursion.
   */
  public static equals<T>(
    left: T,
    right: T,
    stack?: usize[],
    cache?: usize[],
  ): i32;

  /**
   * Attach a stack trace to a value.
   *
   * @param {i32} id - The reflected value to attach the current stack trace to.
   */
  public static attachStackTrace(id: i32): void;
}
