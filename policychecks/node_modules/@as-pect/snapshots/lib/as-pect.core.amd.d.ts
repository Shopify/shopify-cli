declare module "SnapshotDiffResult" {
    import { Change } from "diff";
    export const enum SnapshotDiffResultType {
        NoChange = 0,
        Added = 1,
        Removed = 2,
        Different = 3
    }
    export class SnapshotDiffResult {
        type: SnapshotDiffResultType;
        left: string | null;
        right: string | null;
        changes: Change[];
    }
}
declare module "SnapshotDiff" {
    import { Snapshot } from "Snapshot";
    import { SnapshotDiffResult } from "SnapshotDiffResult";
    export class SnapshotDiff {
        left: Snapshot;
        right: Snapshot;
        results: Map<string, SnapshotDiffResult>;
        constructor(left: Snapshot, right: Snapshot);
        calculateDiff(): void;
    }
}
declare module "parser/grammar" {
    interface NearleyToken {
        value: any;
        [key: string]: any;
    }
    interface NearleyLexer {
        reset: (chunk: string, info: any) => void;
        next: () => NearleyToken | undefined;
        save: () => any;
        formatError: (token: never) => string;
        has: (tokenType: string) => boolean;
    }
    interface NearleyRule {
        name: string;
        symbols: NearleySymbol[];
        postprocess?: (d: any[], loc?: number, reject?: {}) => any;
    }
    type NearleySymbol = string | {
        literal: any;
    } | {
        test: (token: any) => boolean;
    };
    interface Grammar {
        Lexer: NearleyLexer | undefined;
        ParserRules: NearleyRule[];
        ParserStart: string;
    }
    const grammar: Grammar;
    export default grammar;
}
declare module "Snapshot" {
    import { SnapshotDiff } from "SnapshotDiff";
    export class Snapshot {
        static parse(input: string): Snapshot;
        static from(input: Map<string, string>): Snapshot;
        values: Map<string, string>;
        add(key: string, value: string): this;
        diff(other: Snapshot): SnapshotDiff;
        stringify(): string;
    }
}
declare module "index" {
    export * from "Snapshot";
    export * from "SnapshotDiff";
    export * from "SnapshotDiffResult";
}
//# sourceMappingURL=as-pect.core.amd.d.ts.map