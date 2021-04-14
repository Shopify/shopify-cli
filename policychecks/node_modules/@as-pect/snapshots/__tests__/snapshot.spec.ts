import { Snapshot } from "../src";

const inputA = `
exports[\`A\`] = \`SomeA {
      a: 1,
      b: 2,
      c: 3
    }\`;

exports[\`B\`] = \`SomeB {
      d: 4,
      e: 5,
      f: 6
    }\`;

exports[\`C\`] = \`SomeC {
      g: 7,
      h: 8,
      i: 9
    }\`;
`;
const inputB = `
exports[\`A\`] = \`SomeA {
      a: 1,
      b: 2,
      c: 3
    }\`;

exports[\`C\`] = \`SomeC {
      g: 4,
      h: 5,
      i: 6
    }\`;

exports[\`D\`] = \`SomeB {
      d: 1,
      e: 2,
      f: 3
    }\`;
`;

const map = new Map<string, string>();

describe("Snapshot", () => {
  it("should be instanceof Snapshot", () => {
    expect(new Snapshot()).toBeInstanceOf(Snapshot);
  });

  it("should parse a snapshot file", () => {
    expect(Snapshot.parse(inputA)).toMatchSnapshot();
  });

  it("should stringify a given snapshot", () => {
    expect(Snapshot.from(map).stringify()).toMatchSnapshot();
  });

  it("should diff snapshots", () => {
    expect(
      Snapshot.parse(inputA).diff(Snapshot.parse(inputB)),
    ).toMatchSnapshot();
  });
});
