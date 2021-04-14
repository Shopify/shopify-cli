import { Snapshot } from "./Snapshot";
import { SnapshotDiffResult } from "./SnapshotDiffResult";
export declare class SnapshotDiff {
    left: Snapshot;
    right: Snapshot;
    results: Map<string, SnapshotDiffResult>;
    constructor(left: Snapshot, right: Snapshot);
    calculateDiff(): void;
}
//# sourceMappingURL=SnapshotDiff.d.ts.map