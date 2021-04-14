import { Change } from "diff";

export const enum SnapshotDiffResultType {
  NoChange,
  Added,
  Removed,
  Different,
}

export class SnapshotDiffResult {
  type: SnapshotDiffResultType = SnapshotDiffResultType.NoChange;
  left: string | null = null;
  right: string | null = null;
  changes: Change[] = [];
}
