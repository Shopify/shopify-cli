import { SnapshotDiff } from "./SnapshotDiff";
export declare class Snapshot {
    static parse(input: string): Snapshot;
    static from(input: Map<string, string>): Snapshot;
    values: Map<string, string>;
    add(key: string, value: string): this;
    diff(other: Snapshot): SnapshotDiff;
    stringify(): string;
}
//# sourceMappingURL=Snapshot.d.ts.map