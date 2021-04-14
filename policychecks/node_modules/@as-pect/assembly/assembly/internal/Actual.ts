// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "reportActualReflectedValue")
declare function reportActualReflectedValue(id: i32): void;

// @ts-ignore: Decorators *are* valid here!
@external("__aspect", "clearActual")
declare function clearActual(): void;

@global
export class Actual {
  static report<T>(actual: T): void {
    let value = Reflect.toReflectedValue(actual);
    Reflect.attachStackTrace(value);
    reportActualReflectedValue(value);
  }

  static clear(): void {
    clearActual();
  }
}
