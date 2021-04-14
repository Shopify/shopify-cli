// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "reportExpectedReflectedValue")
declare function reportExpectedReflectedValue(id: i32, negated: i32): void;

// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "reportExpectedSnapshot")
declare function reportExpectedSnapshot(id: i32, name: string | null): void;

// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "reportExpectedTruthy")
declare function reportExpectedTruthy(negated: i32): void;

// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "reportExpectedFalsy")
declare function reportExpectedFalsy(negated: i32): void;

// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "reportExpectedFinite")
declare function reportExpectedFinite(negated: i32): void;

// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "clearExpected")
declare function clearExpected(): void;

@global
export class Expected {
  static report<T>(expected: T, negated: i32 = 0): void {
    let value = Reflect.toReflectedValue(expected);
    Reflect.attachStackTrace(value);
    reportExpectedReflectedValue(value, negated);
  }

  static reportTruthy(negated: i32 = 0): void {
    reportExpectedTruthy(negated);
  }

  static reportFalsy(negated: i32 = 0): void {
    reportExpectedFalsy(negated);
  }

  static reportFinite(negated: i32 = 0): void {
    reportExpectedFinite(negated);
  }

  static reportSnapshot<T>(actual: T, name: string | null = null): void {
    reportExpectedSnapshot(
      Reflect.toReflectedValue(actual, new Map<usize, i32>()),
      name,
    );
  }

  static clear(): void {
    clearExpected();
  }
}
