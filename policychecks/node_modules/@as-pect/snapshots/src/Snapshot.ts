import { SnapshotDiff } from "./SnapshotDiff";
import { Parser, Grammar } from "nearley";
import grammar from "./parser/grammar";

const tick = /`/g;

export class Snapshot {
  public static parse(input: string): Snapshot {
    const parser = new Parser(Grammar.fromCompiled(grammar));
    parser.feed(input.replace(/\r/g, ""));
    if (parser.results.length !== 1)
      throw new Error("Ambiguous grammar or parsing.");
    const result = new Snapshot();
    result.values = parser.results[0];
    return result;
  }

  public static from(input: Map<string, string>): Snapshot {
    const snapshot = new Snapshot();
    snapshot.values = input;
    return snapshot;
  }

  values = new Map<string, string>();

  public add(key: string, value: string): this {
    let i = 0;
    while (true) {
      const snapshotKey = `${key}[${i}]`;
      if (!this.values.has(snapshotKey)) {
        this.values.set(snapshotKey, value);
        return this;
      }
      i++;
    }
  }

  public diff(other: Snapshot): SnapshotDiff {
    return new SnapshotDiff(this, other);
  }

  public stringify(): string {
    return (
      Array.from(this.values.entries())
        .map(
          ([key, value]) =>
            `exports[\`${key.replace(tick, "\\`")}\`] = \`${value.replace(
              tick,
              "\\`",
            )}\`;`,
        )
        .join("\n\n") + "\n"
    );
  }
}
