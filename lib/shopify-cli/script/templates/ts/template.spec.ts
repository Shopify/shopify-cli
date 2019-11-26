import * as %{extension_point_type} from "../src/%{extension_point_type}";
import { Slice, Str, ID, Int, Float } from "../src/shopify_runtime_types";
import { run } from "../src/%{script_name}";

describe("run", () => {
  it("Should verify something", () => {
    expect<i32>(2).toBe(1, "Something is wrong");
  });
});
