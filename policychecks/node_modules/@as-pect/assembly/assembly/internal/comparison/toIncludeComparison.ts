import { Actual } from "../Actual";
import { Expected } from "../Expected";
import { assert } from "../assert";

export function toIncludeComparison<T, U>(
  actual: T,
  expected: U,
  negated: i32,
  message: string,
): void {
  // @ts-ignore: checking if a property is defined is compile safe
  if (!isDefined(actual[0])) {
    ERROR(
      "Cannot call toIncludeEquals on actual value of type T where T does not have an index signature.",
    );
  }

  // Assert that the actual value is not null.
  Actual.report(actual);
  if (isNullable<T>()) {
    Expected.report("null", 1);
    assert(i32(actual !== null), "");
  }

  // We always expect the value to be included
  Expected.report("Included", negated);
  // assume it isn't included
  let includes: bool = false;

  if (actual instanceof Set) {
    includes = actual.has(expected);
  } else {
    // @ts-ignore: typesafe check
    if (!isDefined(actual.length))
      ERROR("Can only call toInclude on array-like objects or Sets.");
    // @ts-ignore: typesafe access
    let length = <indexof<T>>actual.length;
    // @ts-ignore: typesafe check
    if (isDefined(unchecked(actual[0]))) {
      // @ts-ignore: if T does not have a length property, it will throw a compiler error.
      for (let i = <indexof<T>>0; i < length; i++) {
        // @ts-ignore: if this expression does not work, it will throw a compiler error.
        if (unchecked(actual[i]) === expected) {
          includes = true;
          break;
        }
      }
    } else {
      // @ts-ignore: if T does not have a length property, it will throw a compiler error.
      for (let i = <indexof<T>>0; i < length; i++) {
        // @ts-ignore: if this expression does not work, it will throw a compiler error.
        if (actual[i] === expected) {
          includes = true;
          break;
        }
      }
    }
  }

  Actual.report(includes ? "Included" : "Not Included");
  assert(negated ^ i32(includes), message);
}
