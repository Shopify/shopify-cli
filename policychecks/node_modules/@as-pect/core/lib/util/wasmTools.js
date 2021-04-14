"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.NameSection = exports.WasmBuffer = void 0;
/**
 * A Buffer for reading wasm sections.
 */
var WasmBuffer = /** @class */ (function () {
    function WasmBuffer(u8array) {
        this.u8array = u8array;
        /** Current offset in the buffer. */
        this.off = 0;
    }
    /** Read 128LEB unsigned integers. */
    WasmBuffer.prototype.readVaruint = function (off) {
        if (off === void 0) { off = this.off; }
        var val = 0;
        var shl = 0;
        var byt;
        var pos = off;
        do {
            byt = this.u8array[pos++];
            val |= (byt & 0x7f) << shl;
            if (!(byt & 0x80))
                break;
            shl += 7;
        } while (true);
        this.off = pos;
        return val;
    };
    /**
     * Read a UTF8 string from the buffer either at the current offset or one passed in.
     * Updates the offset of the buffer.
     */
    WasmBuffer.prototype.readString = function (off) {
        if (off === void 0) { off = this.off; }
        var name_len = this.readVaruint(off);
        this.off += name_len;
        var codes = this.u8array.slice(this.off - name_len, this.off);
        var result = "";
        for (var i = 0; i < codes.length; i++) {
            result += String.fromCharCode(codes[i]);
        }
        return result;
    };
    /** Read a string at an offset without changing the buffere's offset. */
    WasmBuffer.prototype.peekString = function (off) {
        var old_off = this.off;
        var str = this.readString(off);
        this.off = old_off;
        return str;
    };
    return WasmBuffer;
}());
exports.WasmBuffer = WasmBuffer;
/**
 * Utility class for reading the name sections of a wasm binary.
 * See https://github.com/WebAssembly/design/blob/master/BinaryEncoding.md#name-section
 */
var NameSection = /** @class */ (function () {
    function NameSection(contents) {
        /** map of indexs to UTF8 pointers. */
        this.funcNames = new Map();
        var mod = new WebAssembly.Module(contents);
        var section = WebAssembly.Module.customSections(mod, "name")[0];
        this.section = new WasmBuffer(new Uint8Array(section));
        this.parseSection();
    }
    NameSection.prototype.fromIndex = function (i) {
        var ptr = this.funcNames.get(i);
        if (!ptr)
            return "Function " + i;
        return this.section.peekString(ptr);
    };
    /** Parses */
    NameSection.prototype.parseSection = function () {
        var off = this.off;
        var kind = this.readVaruint();
        if (kind != 1) {
            this.off = off;
            return;
        }
        var end = this.readVaruint() + this.off;
        var count = this.readVaruint();
        var numRead = 0;
        while (numRead < count && this.off < end) {
            var index = this.readVaruint();
            this.funcNames.set(index, this.off);
            var len = this.readVaruint();
            this.off += len;
            numRead++;
        }
    };
    Object.defineProperty(NameSection.prototype, "off", {
        /** Current offset */
        get: function () {
            return this.section.off;
        },
        /** Update offset */
        set: function (o) {
            this.section.off = o;
        },
        enumerable: false,
        configurable: true
    });
    /** Reads a 128LEB  unsigned integer and updates the offset. */
    NameSection.prototype.readVaruint = function (off) {
        if (off === void 0) { off = this.off; }
        return this.section.readVaruint(off);
    };
    return NameSection;
}());
exports.NameSection = NameSection;
//# sourceMappingURL=wasmTools.js.map