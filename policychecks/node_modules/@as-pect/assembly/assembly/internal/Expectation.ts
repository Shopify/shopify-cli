import { toIncludeComparison } from "./comparison/toIncludeComparison";
import { toIncludeEqualComparison } from "./comparison/toIncludeEqualComparison";
import { Actual } from "./Actual";
import { Expected } from "./Expected";
import { assert } from "./assert";

// @ts-ignore: Decorators *are* valid here
@external("__aspect", "tryCall")
declare function tryCall(func: () => void): bool;

// @ts-ignore: Decorators *are* valid here
@global
export class Expectation<T> {
  /**
   * This i32 is set to 1 if the expectation is negated. Using the _not (xor) condition assertion
   * makes assertions very easy to write and understand.
   */
  _not: i32 = 0;

  actual: T;

  constructor(actual: T) {
    this.actual = actual;
  }

  public get not(): Expectation<T> {
    this._not = 1;
    return this;
  }

  public toBe(expected: T, message: string = ""): void {
    let actual = this.actual;
    let equals = i32(actual == expected);
    let negated = this._not;

    Actual.report(actual);

    if (isReference(actual) && !isFunction(actual)) {
      if (
        !negated &&
        changetype<usize>(actual) !== 0 &&
        changetype<usize>(expected) !== 0 &&
        Reflect.equals(actual, expected) == Reflect.SUCCESSFUL_MATCH
      ) {
        Expected.report("Serializes to same value.", 0);
      } else {
        Expected.report(expected, negated);
      }
    } else {
      Expected.report(expected, negated);
    }

    // The assertion is either the items equal, or the expectation is negated
    assert(equals ^ negated, message);
    Actual.clear();
    Expected.clear();
  }

  public toStrictEqual(expected: T, message: string = ""): void {
    let result = Reflect.FAILED_MATCH;
    result = Reflect.equals(this.actual, expected);

    let equals = i32(result == Reflect.SUCCESSFUL_MATCH);
    Actual.report(this.actual);
    Expected.report(expected);

    assert(equals ^ this._not, message);

    Actual.clear();
    Expected.clear();
  }

  public toBlockEqual(expected: T, message: string = ""): void {
    WARNING(
      "toBlockEqual has been deprecated and results in a toStrictEqual call.",
    );
    this.toStrictEqual(expected, message);
  }

  public toBeTruthy(message: string = ""): void {
    let actual = this.actual;
    Actual.report(actual);
    let negated = this._not;
    Expected.reportTruthy(negated);

    if (isReference(actual)) {
      if (actual instanceof String) {
        let truthy = i32(
          changetype<usize>(actual) != 0 &&
            changetype<string>(actual).length > 0,
        );
        assert(truthy ^ negated, message);
      } else {
        let truthy = i32(changetype<usize>(actual) != 0);
        assert(truthy ^ negated, message);
      }
    } else {
      if (isFloat(actual)) {
        let truthy = i32(!isNaN(actual) && actual != 0.0);
        assert(truthy ^ negated, message);
      } else if (isInteger(actual)) {
        let truthy = i32(actual != 0);
        assert(truthy ^ negated, message);
      }
    }

    Actual.clear();
    Expected.clear();
  }

  public toBeFalsy(message: string = ""): void {
    let actual = this.actual;
    Actual.report(actual);
    let negated = this._not;
    Expected.reportFalsy(negated);

    if (isReference(actual)) {
      // strings require an extra length check
      if (actual instanceof String) {
        let falsy = i32(
          changetype<usize>(actual) == 0 ||
            changetype<string>(actual).length == 0,
        );
        assert(falsy ^ negated, message);
      } else {
        let falsy = i32(changetype<usize>(actual) == 0);
        assert(falsy ^ negated, message);
      }
    } else {
      if (isFloat(actual)) {
        // @ts-ignore: actual is a float value
        let falsy = i32(isNaN(actual) || actual == 0.0);
        assert(falsy ^ negated, message);
      } else if (isInteger(actual)) {
        let falsy = i32(actual == 0);
        assert(falsy ^ negated, message);
      }
    }

    Actual.clear();
    Expected.clear();
  }

  public toThrow(message: string = ""): void {
    let actual = this.actual;
    let negated = this._not;

    if (!isFunction(this.actual))
      ERROR(
        "Expectation#toThrow assertion called on actual T where T is not a function reference",
      );
    if (idof<T>() != idof<() => void>())
      ERROR(
        "Expectation#toThrow assertion called on actual T where T is not a function reference with signature () => void",
      );

    // @ts-ignore: safe tryCall
    let throws = i32(!tryCall(actual));
    Actual.report(throws ? "Throws" : "Not Throws");
    Expected.report("Throws", negated);
    assert(negated ^ throws, message);
    Actual.clear();
    Expected.clear();
  }

  public toBeGreaterThan(expected: T, message: string = ""): void {
    let actual = this.actual;
    let negated = this._not;
    Actual.report(actual);
    Expected.report(expected, negated);

    if (!isDefined(actual > expected))
      ERROR(
        "Invalid call to toBeGreaterThan. Generic type T must have an operator implemented for the greaterThan (>) operation.",
      );

    if (isReference(actual)) {
      // Perform reference type null checks
      assert(
        i32(changetype<usize>(expected) != 0),
        "Value comparison fails, expected value is null.",
      );
      assert(
        i32(changetype<usize>(actual) != 0),
        "Value comparison fails, actual value is null.",
      );
    }

    // Compare float types
    if (isFloat(actual)) {
      assert(
        i32(!isNaN(expected)),
        "Value comparison fails, expected value is NaN.",
      );
      assert(
        i32(!isNaN(actual)),
        "Value comparison fails, actual value is NaN.",
      );
    }

    // do actual greater than comparison
    assert(negated ^ i32(actual > expected), message);
    Actual.clear();
    Expected.clear();
  }

  public toBeGreaterThanOrEqual(expected: T, message: string = ""): void {
    let actual = this.actual;
    let negated = this._not;

    Actual.report(actual);
    Expected.report(expected, negated);

    if (!isDefined(actual >= expected))
      ERROR(
        "Invalid call to toBeGreaterThanOrEqual. Generic type T must have an operator implemented for the greaterThanOrEqual (>=) operation.",
      );

    // null checks
    if (isReference(actual)) {
      assert(
        i32(changetype<usize>(expected) != 0),
        "Value comparison fails, expected value is null.",
      );
      assert(
        i32(changetype<usize>(actual) != 0),
        "Value comparison fails, actual value is null.",
      );
    }

    // Compare float types
    if (isFloat(actual)) {
      assert(
        i32(!isNaN(expected)),
        "Value comparison fails, expected value is NaN.",
      );
      assert(
        i32(!isNaN(actual)),
        "Value comparison fails, actual value is NaN.",
      );
    }

    // do actual greater than comparison
    assert(negated ^ i32(actual >= expected), message);
    Actual.clear();
    Expected.clear();
  }

  public toBeLessThan(expected: T, message: string = ""): void {
    let actual = this.actual;
    let negated = this._not;
    Actual.report(actual);
    Expected.report(expected, negated);

    if (!isDefined(actual < expected))
      ERROR(
        "Invalid call to toBeLessThan. Generic type T must have an operator implemented for the lessThan (<) operation.",
      );

    // null checks
    if (isReference(actual)) {
      assert(
        i32(changetype<usize>(expected) != 0),
        "Value comparison fails, expected value is null.",
      );
      assert(
        i32(changetype<usize>(actual) != 0),
        "Value comparison fails, actual value is null.",
      );
    } else if (isFloat(actual)) {
      assert(
        i32(!isNaN(expected)),
        "Value comparison fails, expected value is NaN.",
      );
      assert(
        i32(!isNaN(actual)),
        "Value comparison fails, actual value is NaN.",
      );
    }

    // do actual less than comparison
    assert(negated ^ i32(actual < expected), message);
    Actual.clear();
    Expected.clear();
  }

  public toBeLessThanOrEqual(expected: T, message: string = ""): void {
    let actual = this.actual;
    let negated = this._not;
    Actual.report(actual);
    Expected.report(expected, negated);

    if (!isDefined(actual > expected))
      ERROR(
        "Invalid call to toBeLessThanOrEqual. Generic type T must have an operator implemented for the lessThanOrEqual (<=) operation.",
      );

    // null checks
    if (isReference(actual)) {
      assert(
        i32(changetype<usize>(expected) != 0),
        "Value comparison fails, expected value is null.",
      );
      assert(
        i32(changetype<usize>(actual) != 0),
        "Value comparison fails, actual value is null.",
      );
    }

    if (isFloat(actual)) {
      assert(
        i32(!isNaN(expected)),
        "Value comparison fails, expected value is NaN.",
      );
      assert(
        i32(!isNaN(actual)),
        "Value comparison fails, actual value is NaN.",
      );
    }

    // do actual less than comparison
    assert(negated ^ i32(actual <= expected), message);
    Actual.clear();
    Expected.clear();
  }

  public toBeNull(message: string = ""): void {
    let negated = this._not;
    let actual = this.actual;

    if (actual instanceof usize) {
      Actual.report(actual);
      Expected.report(<usize>0, negated);
      // @ts-ignore: actual is instanceof number type
      assert(negated ^ i32(actual == 0), message);
      Actual.clear();
      Expected.clear();
    } else if (isReference(actual)) {
      Actual.report(actual);

      Expected.report(changetype<T>(0), negated);
      assert(negated ^ i32(changetype<usize>(actual) == 0), message);
      Actual.clear();
      Expected.clear();
    } else {
      ERROR(
        "toBeNull assertion must be called with a reference type T or usize.",
      );
    }
  }

  public toBeCloseTo(
    expected: T,
    decimalPlaces: i32 = 2,
    message: string = "",
  ): void {
    let actual = this.actual;
    let negated = this._not;

    // must be called on a float T
    if (!isFloat(actual))
      ERROR("toBeCloseTo must be called with a Float value type T.");
    Actual.report(actual);
    Expected.report(expected, negated);

    // both actual and expected values must be finite
    assert(
      i32(isFinite(actual)),
      "toBeCloseTo assertion fails because a actual value is not finite",
    );
    assert(
      i32(isFinite(expected)),
      "toBeCloseTo assertion fails because expected value is not finite.",
    );

    // calculated: `|expected - actual| < 1 / numberOfDigits`.
    // @ts-ignore tooling errors because T does not extend a numeric value type. This compiles just fine.
    let isClose = i32(abs(expected - actual) < Math.pow(0.1, decimalPlaces));
    assert(negated ^ isClose, message);
    Actual.clear();
    Expected.clear();
  }

  public toBeNaN(message: string = ""): void {
    let actual = this.actual;
    let negated = this._not;

    // must be called on a float T
    if (!isFloat(actual))
      ERROR("toBeNaN must be called with a Float value type T.");
    Actual.report(actual);

    // @ts-ignore: The compiler should pass bit count (64/32 bit float to the report function)
    Expected.report<T>(NaN, negated);

    let isNaNValue = i32(isNaN(actual));
    assert(isNaNValue ^ negated, message);
    Actual.clear();
    Expected.clear();
  }

  public toBeFinite(message: string = ""): void {
    let actual = this.actual;
    let negated = this._not;

    // must be called on a float T
    if (!isFloat(actual))
      ERROR("toBeNaN must be called with a Float value type T.");
    Actual.report(actual);
    Expected.reportFinite(negated);

    let isFiniteValue = i32(isFinite(actual));
    assert(isFiniteValue ^ negated, message);
    Actual.clear();
    Expected.clear();
  }

  public toHaveLength(expected: i32, message: string = ""): void {
    let actual = this.actual;
    let negated = this._not;
    let length = 0;
    if (actual instanceof ArrayBuffer) {
      length = actual.byteLength;
    } else {
      // @ts-ignore: This results in a compile time check for a length property with a better error message
      if (!isDefined(actual.length))
        ERROR(
          "toHaveLength cannot be called on type T where T.length is not defined.",
        );
      // @ts-ignore: This results in a compile time check for a length property with a better error message
      length = <i32>actual.length;
    }

    Actual.report(length);
    Expected.report(expected, negated);

    let lengthsEqual = i32(length == expected);
    assert(lengthsEqual ^ negated, message);
    Actual.clear();
    Expected.clear();
  }

  public toInclude<U>(expected: U, message: string = ""): void {
    toIncludeComparison<T, U>(this.actual, expected, this._not, message);
    Actual.clear();
    Expected.clear();
  }

  // @ts-ignore: valueof<T> requires that T extends something with an @operator("[]")
  public toContain(expected: valueof<T>, message: string = ""): void {
    this.toInclude(expected, message);
  }

  public toIncludeEqual<U>(expected: U, message: string = ""): void {
    toIncludeEqualComparison<T, U>(this.actual, expected, this._not, message);
    Actual.clear();
    Expected.clear();
  }

  public toContainEqual<U>(expected: U, message: string = ""): void {
    this.toIncludeEqual(expected, message);
  }

  public toMatchSnapshot(name: string | null = null): void {
    assert(i32(!this._not), "Snapshots cannot be negated.");
    Expected.reportSnapshot(this.actual, name);
  }
}

// @ts-ignore: decorators *are* valid here
@global
export function expect<T>(actual: T): Expectation<T> {
  return new Expectation(actual);
}

// @ts-ignore: decorators *are* valid here
@global
export function expectFn(cb: () => void): Expectation<() => void> {
  WARNING("expectFn() has been deprecated. Use expect() instead.");
  return new Expectation(cb);
}
