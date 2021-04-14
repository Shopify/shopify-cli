import { Actual } from "../Actual";
import { Expected } from "../Expected";
import { assert } from "../assert";

// @ts-ignore expected is valueof<T> or it will be a compiler error
export function toIncludeEqualComparison<T, U>(
  actual: T,
  expected: U,
  negated: i32,
  message: string,
): void {
  // @ts-ignore: typesafe check
  if (!isDefined(actual[0])) {
    ERROR(
      "Cannot call toIncludeEquals on actual value of type T where T does not have an index signature.",
    );
  }

  // Assert that the actual value is not null.
  Actual.report(actual);
  Expected.report("null", 1);
  assert(i32(changetype<usize>(actual) != 0), "");

  // We always expect the value to be included
  Expected.report("Included", negated);
  // assume it isn't included
  let includes = false;

  if (actual instanceof Set) {
    if (actual.has(expected)) {
      includes = true;
    } else {
      // if it isn't already in the set, we need to look over each value and inspect it for strict equality
      // @ts-ignore: type safe .values() method call
      let values = actual.values();
      let length = values.length;
      for (let i = 0; i < length; i++) {
        let key = unchecked(values[i]);
        if (Reflect.equals(key, expected) === Reflect.SUCCESSFUL_MATCH) {
          includes = true;
          break;
        }
      }
    }
  } else {
    // @ts-ignore: typesafe check
    if (!isDefined(actual.length))
      ERROR("Can only call toIncludeEquals on array-like objects or Sets.");
    // @ts-ignore: typesafe access
    let length = <indexof<T>>actual.length;
    // @ts-ignore: typesafe check
    if (isDefined(unchecked(actual[0]))) {
      // @ts-ignore: if T does not have a length property, it will throw a compiler error.
      for (let i = <indexof<T>>0; i < length; i++) {
        if (
          // @ts-ignore: actual[i] type must match expected, or a compiler error will happen
          Reflect.equals(unchecked(actual[i]), expected) ==
          Reflect.SUCCESSFUL_MATCH
        ) {
          includes = true;
          break;
        }
      }
    } else {
      // @ts-ignore: if T does not have a length property, it will throw a compiler error.
      for (let i = <indexof<T>>0; i < length; i++) {
        // @ts-ignore: if this expression does not work, it will throw a compiler error.
        if (Reflect.equals(actual[i], expected) === Reflect.SUCCESSFUL_MATCH) {
          includes = true;
          break;
        }
      }
    }
  }

  Actual.report(includes ? "Included" : "Not Included");
  assert(negated ^ i32(includes), message);
}
