import { Change } from "diff";
export declare const enum SnapshotDiffResultType {
    NoChange = 0,
    Added = 1,
    Removed = 2,
    Different = 3
}
export declare class SnapshotDiffResult {
    type: SnapshotDiffResultType;
    left: string | null;
    right: string | null;
    changes: Change[];
}
//# sourceMappingURL=SnapshotDiffResult.d.ts.map