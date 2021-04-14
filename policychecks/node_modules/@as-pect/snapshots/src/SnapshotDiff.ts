import { Snapshot } from "./Snapshot";
import {
  SnapshotDiffResult,
  SnapshotDiffResultType,
} from "./SnapshotDiffResult";
import { diffLines } from "diff";

export class SnapshotDiff {
  results = new Map<string, SnapshotDiffResult>();

  constructor(public left: Snapshot, public right: Snapshot) {
    this.calculateDiff();
  }

  public calculateDiff(): void {
    const left = this.left.values;
    const right = this.right.values;

    // loop over the items on the left side
    for (const [key, value] of left.entries()) {
      // the snapshot exists, NoChange or Different
      if (right.has(key)) {
        const rightValue = right.get(key)!;
        const lines = diffLines(rightValue, value);
        const result = new SnapshotDiffResult();
        result.left = value;
        result.right = rightValue;
        result.type =
          value === rightValue
            ? SnapshotDiffResultType.NoChange
            : SnapshotDiffResultType.Different;
        result.changes = lines;
        this.results.set(key, result);
      } else {
        // it was added
        const result = new SnapshotDiffResult();
        result.left = value;
        result.right = null;
        result.type = SnapshotDiffResultType.Added;
        result.changes = diffLines("", value);
        this.results.set(key, result);
      }
    }

    // loop over the items on the right side
    for (const [key, value] of right.entries()) {
      if (!left.has(key)) {
        // it was removed
        const result = new SnapshotDiffResult();
        result.left = null;
        result.right = value;
        result.changes = diffLines(value, "");
        result.type = SnapshotDiffResultType.Removed;
        this.results.set(key, result);
      }
    }
  }
}
