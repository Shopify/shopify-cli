import { Str } from "./runtime-types";

describe("Str", () => {
    it(".fromString builds a matching Str", () => {
        let foo: Str = Str.from("foo");
        expect<Str>(foo).toBe(Str.from("foo"));
        expect<Str>(foo).toStrictEqual(Str.from("foo"));
        expect<Str>(foo).not.toBe(Str.from("bar"));
        expect<Str>(foo).not.toStrictEqual(Str.from("bar"));
        expect<Str>(foo).toHaveLength(3);
    });

    it(".length returns Rust's equivalent of .len() for utf-8 strings", () => {
        expect<Str>(Str.from("👌")).toHaveLength(4);
        expect<Str>(Str.from("アサヒコ")).toHaveLength(12);
        expect<Str>(Str.from("नमस्ते")).toHaveLength(18);
        expect<Str>(Str.from("Здравствуйте")).toHaveLength(24);
    })
});
