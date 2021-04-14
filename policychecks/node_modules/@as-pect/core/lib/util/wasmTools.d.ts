/**
 * A Buffer for reading wasm sections.
 */
export declare class WasmBuffer {
    u8array: Uint8Array;
    /** Current offset in the buffer. */
    off: number;
    constructor(u8array: Uint8Array);
    /** Read 128LEB unsigned integers. */
    readVaruint(off?: number): number;
    /**
     * Read a UTF8 string from the buffer either at the current offset or one passed in.
     * Updates the offset of the buffer.
     */
    readString(off?: number): string;
    /** Read a string at an offset without changing the buffere's offset. */
    peekString(off: number): string;
}
/**
 * Utility class for reading the name sections of a wasm binary.
 * See https://github.com/WebAssembly/design/blob/master/BinaryEncoding.md#name-section
 */
export declare class NameSection {
    section: WasmBuffer;
    /** map of indexs to UTF8 pointers. */
    private funcNames;
    constructor(contents: Uint8Array);
    fromIndex(i: number): string;
    /** Parses */
    private parseSection;
    /** Current offset */
    get off(): number;
    /** Update offset */
    set off(o: number);
    /** Reads a 128LEB  unsigned integer and updates the offset. */
    readVaruint(off?: number): number;
}
//# sourceMappingURL=wasmTools.d.ts.map