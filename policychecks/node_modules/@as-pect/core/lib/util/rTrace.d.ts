export const BLOCK_OVERHEAD: number;
export const OBJECT_OVERHEAD: 16;
export const TOTAL_OVERHEAD: number;
export class Rtrace {
    constructor(options: any);
    options: any;
    onerror: any;
    oninfo: any;
    oncollect_: any;
    memory: any;
    shadow: WebAssembly.Memory | null;
    shadowStart: number;
    blocks: Map<any, any>;
    allocSites: Map<any, any>;
    freedBlocks: Map<any, any>;
    gcProfileStart: number;
    gcProfile: any[];
    allocCount: number;
    resizeCount: number;
    moveCount: number;
    freeCount: number;
    heapBase: number;
    install(imports: any): any;
    /** Synchronizes the shadow memory with the module's memory. */
    syncShadow(): void;
    /** Marks a block's presence in shadow memory. */
    markShadow(info: any, oldSize?: number): void;
    /** Unmarks a block's presence in shadow memory. */
    unmarkShadow(info: any, oldSize?: any): void;
    /** Performs an access to shadow memory. */
    accessShadow(ptr: any, size: any, isLoad: any, isRT: any): void;
    /** Obtains information about a block. */
    getBlockInfo(ptr: any): {
        ptr: any;
        size: number;
        mmInfo: {
            tags: string;
            size: number;
        };
        gcInfo: {
            color: string;
            next: number;
            prev: number;
        };
        rtId: number;
        rtSize: number;
    };
    /** Checks if rtrace is active, i.e. at least one event has occurred. */
    get active(): boolean;
    /** Checks if there are any leaks and emits them via `oninfo`. Returns the number of live blocks. */
    check(): number;
    oninit(heapBase: any): void;
    onalloc(ptr: any): void;
    onresize(ptr: any, oldSize: any): void;
    onmove(oldPtr: any, newPtr: any): void;
    onvisit(ptr: any): boolean;
    onfree(ptr: any): void;
    oncollect(total: any): void;
    plot(total: any, pause?: number): void;
    oninterrupt(total: any): void;
    interruptStart: number | undefined;
    onyield(total: any): void;
    onstore(ptr: any, offset: any, bytes: any, isRT: any): any;
    onload(ptr: any, offset: any, bytes: any, isRT: any): any;
}
//# sourceMappingURL=rTrace.d.ts.map