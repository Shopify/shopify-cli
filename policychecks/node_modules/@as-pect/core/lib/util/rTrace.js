"use strict";
var __read = (this && this.__read) || function (o, n) {
    var m = typeof Symbol === "function" && o[Symbol.iterator];
    if (!m) return o;
    var i = m.call(o), r, ar = [], e;
    try {
        while ((n === void 0 || n-- > 0) && !(r = i.next()).done) ar.push(r.value);
    }
    catch (error) { e = { error: error }; }
    finally {
        try {
            if (r && !r.done && (m = i["return"])) m.call(i);
        }
        finally { if (e) throw e.error; }
    }
    return ar;
};
var __values = (this && this.__values) || function(o) {
    var s = typeof Symbol === "function" && Symbol.iterator, m = s && o[s], i = 0;
    if (m) return m.call(o);
    if (o && typeof o.length === "number") return {
        next: function () {
            if (o && i >= o.length) o = void 0;
            return { value: o && o[i++], done: !o };
        }
    };
    throw new TypeError(s ? "Object is not iterable." : "Symbol.iterator is not defined.");
};
// WebAssembly pages are 65536 kb
var PAGE_SIZE_BITS = 16;
var PAGE_SIZE = 1 << PAGE_SIZE_BITS;
var PAGE_MASK = PAGE_SIZE - 1;
// Wasm32 pointer size is 4 bytes
var PTR_SIZE_BITS = 2;
var PTR_SIZE = 1 << PTR_SIZE_BITS;
var PTR_MASK = PTR_SIZE - 1;
var PTR_VIEW = Uint32Array;
var BLOCK_OVERHEAD = PTR_SIZE;
var OBJECT_OVERHEAD = 16;
var TOTAL_OVERHEAD = BLOCK_OVERHEAD + OBJECT_OVERHEAD;
module.exports.BLOCK_OVERHEAD = BLOCK_OVERHEAD;
module.exports.OBJECT_OVERHEAD = OBJECT_OVERHEAD;
module.exports.TOTAL_OVERHEAD = TOTAL_OVERHEAD;
function assert(x) {
    if (!x)
        throw Error("assertion failed");
    return x;
}
Error.stackTraceLimit = 15;
function trimStacktrace(stack, levels) {
    return stack.split(/\r?\n/).slice(1 + levels);
}
var hrtime = typeof performance !== "undefined" && performance.now
    ? performance.now
    : typeof process !== "undefined" && process.hrtime
        ? function () { var t = process.hrtime(); return t[0] * 1e3 + t[1] / 1e6; }
        : Date.now;
var mmTagsToString = [
    "",
    "FREE",
    "LEFTFREE",
    "FREE+LEFTFREE"
];
var gcColorToString = [
    "BLACK/WHITE",
    "WHITE/BLACK",
    "GRAY",
    "INVALID"
];
var Rtrace = /** @class */ (function () {
    function Rtrace(options) {
        this.options = options || {};
        this.onerror = this.options.onerror || function () { };
        this.oninfo = this.options.oninfo || function () { };
        this.oncollect_ = this.options.oncollect || function () { };
        this.memory = null;
        this.shadow = null;
        this.shadowStart = 0x100000000;
        this.blocks = new Map();
        this.allocSites = new Map();
        this.freedBlocks = new Map();
        this.gcProfileStart = 0;
        this.gcProfile = [];
        this.allocCount = 0;
        this.resizeCount = 0;
        this.moveCount = 0;
        this.freeCount = 0;
        this.heapBase = 0x100000000;
    }
    Rtrace.prototype.install = function (imports) {
        if (!imports)
            imports = {};
        imports.rtrace = Object.assign(imports.rtrace || {}, {
            oninit: this.oninit.bind(this),
            onalloc: this.onalloc.bind(this),
            onresize: this.onresize.bind(this),
            onmove: this.onmove.bind(this),
            onvisit: this.onvisit.bind(this),
            onfree: this.onfree.bind(this),
            oninterrupt: this.oninterrupt.bind(this),
            onyield: this.onyield.bind(this),
            oncollect: this.oncollect.bind(this),
            onstore: this.onstore.bind(this),
            onload: this.onload.bind(this)
        });
        return imports;
    };
    /** Synchronizes the shadow memory with the module's memory. */
    Rtrace.prototype.syncShadow = function () {
        if (!this.memory) {
            this.memory = assert(this.options.getMemory());
            this.shadow = new WebAssembly.Memory({
                initial: ((this.memory.buffer.byteLength + PAGE_MASK) & ~PAGE_MASK) >>> PAGE_SIZE_BITS
            });
        }
        else {
            var diff = this.memory.buffer.byteLength - this.shadow.buffer.byteLength;
            if (diff > 0)
                this.shadow.grow(diff >>> 16);
        }
    };
    /** Marks a block's presence in shadow memory. */
    Rtrace.prototype.markShadow = function (info, oldSize) {
        if (oldSize === void 0) { oldSize = 0; }
        assert(this.shadow && this.shadow.byteLength == this.memory.byteLength);
        assert((info.size & PTR_MASK) == 0);
        if (info.ptr < this.shadowStart) {
            this.shadowStart = info.ptr;
        }
        var len = info.size >>> PTR_SIZE_BITS;
        var view = new PTR_VIEW(this.shadow.buffer, info.ptr, len);
        var errored = false;
        var start = oldSize >>> PTR_SIZE_BITS;
        for (var i = 0; i < start; ++i) {
            if (view[i] != info.ptr && !errored) {
                this.onerror(Error("shadow region mismatch: " + view[i] + " != " + info.ptr), info);
                errored = true;
            }
        }
        errored = false;
        for (var i = start; i < len; ++i) {
            if (view[i] != 0 && !errored) {
                this.onerror(Error("shadow region already in use: " + view[i] + " != 0"), info);
                errored = true;
            }
            view[i] = info.ptr;
        }
    };
    /** Unmarks a block's presence in shadow memory. */
    Rtrace.prototype.unmarkShadow = function (info, oldSize) {
        if (oldSize === void 0) { oldSize = info.size; }
        assert(this.shadow && this.shadow.byteLength == this.memory.byteLength);
        var len = oldSize >>> PTR_SIZE_BITS;
        var view = new PTR_VIEW(this.shadow.buffer, info.ptr, len);
        var errored = false;
        var start = 0;
        if (oldSize != info.size) {
            assert(oldSize > info.size);
            start = info.size >>> PTR_SIZE_BITS;
        }
        for (var i = 0; i < len; ++i) {
            if (view[i] != info.ptr && !errored) {
                this.onerror(Error("shadow region mismatch: " + view[i] + " != " + info.ptr), info);
                errored = true;
            }
            if (i >= start)
                view[i] = 0;
        }
    };
    /** Performs an access to shadow memory. */
    Rtrace.prototype.accessShadow = function (ptr, size, isLoad, isRT) {
        this.syncShadow();
        if (ptr < this.shadowStart)
            return;
        var value = new Uint32Array(this.shadow.buffer, ptr & ~PTR_MASK, 1)[0];
        if (value != 0)
            return;
        if (!isRT) {
            var stack = trimStacktrace(new Error().stack, 2);
            this.onerror(new Error("OOB " + (isLoad ? "load" : "store") + (8 * size) + " at address " + ptr + "\n" + stack.join("\n")));
        }
    };
    /** Obtains information about a block. */
    Rtrace.prototype.getBlockInfo = function (ptr) {
        var _a = __read(new Uint32Array(this.memory.buffer, ptr, 5), 5), mmInfo = _a[0], gcInfo = _a[1], gcInfo2 = _a[2], rtId = _a[3], rtSize = _a[4];
        var size = mmInfo & ~3;
        return {
            ptr: ptr,
            size: BLOCK_OVERHEAD + size,
            mmInfo: {
                tags: mmTagsToString[mmInfo & 3],
                size: size // as stored excl. overhead
            },
            gcInfo: {
                color: gcColorToString[gcInfo & 3],
                next: gcInfo & ~3,
                prev: gcInfo2
            },
            rtId: rtId,
            rtSize: rtSize
        };
    };
    Object.defineProperty(Rtrace.prototype, "active", {
        /** Checks if rtrace is active, i.e. at least one event has occurred. */
        get: function () {
            return Boolean(this.allocCount || this.resizeCount || this.moveCount || this.freeCount);
        },
        enumerable: false,
        configurable: true
    });
    /** Checks if there are any leaks and emits them via `oninfo`. Returns the number of live blocks. */
    Rtrace.prototype.check = function () {
        var e_1, _a;
        if (this.oninfo) {
            try {
                for (var _b = __values(this.blocks), _c = _b.next(); !_c.done; _c = _b.next()) {
                    var _d = __read(_c.value, 2), ptr = _d[0], info = _d[1];
                    this.oninfo("LIVE " + ptr + "\n" + info.allocStack.join("\n"));
                }
            }
            catch (e_1_1) { e_1 = { error: e_1_1 }; }
            finally {
                try {
                    if (_c && !_c.done && (_a = _b.return)) _a.call(_b);
                }
                finally { if (e_1) throw e_1.error; }
            }
        }
        return this.blocks.size;
    };
    // Runtime instrumentation
    Rtrace.prototype.oninit = function (heapBase) {
        this.heapBase = heapBase;
        this.gcProfileStart = 0;
        this.gcProfile.length = 0;
        this.oninfo("INIT heapBase=" + heapBase);
    };
    Rtrace.prototype.onalloc = function (ptr) {
        this.syncShadow();
        ++this.allocCount;
        var info = this.getBlockInfo(ptr);
        if (this.blocks.has(ptr)) {
            this.onerror(Error("duplicate alloc: " + ptr), info);
        }
        else {
            this.oninfo("ALLOC " + ptr + ".." + (ptr + info.size));
            this.markShadow(info);
            var allocStack = trimStacktrace(new Error().stack, 1); // strip onalloc
            this.blocks.set(ptr, Object.assign(info, { allocStack: allocStack }));
        }
    };
    Rtrace.prototype.onresize = function (ptr, oldSize) {
        this.syncShadow();
        ++this.resizeCount;
        var info = this.getBlockInfo(ptr);
        if (!this.blocks.has(ptr)) {
            this.onerror(Error("orphaned resize: " + ptr), info);
        }
        else {
            var beforeInfo = this.blocks.get(ptr);
            if (beforeInfo.size != oldSize) {
                this.onerror(Error("size mismatch upon resize: " + ptr + " (" + beforeInfo.size + " != " + oldSize + ")"), info);
            }
            var newSize = info.size;
            this.oninfo("RESIZE " + ptr + ".." + (ptr + newSize) + " (" + oldSize + "->" + newSize + ")");
            this.blocks.set(ptr, Object.assign(info, { allocStack: beforeInfo.allocStack }));
            if (newSize > oldSize) {
                this.markShadow(info, oldSize);
            }
            else if (newSize < oldSize) {
                this.unmarkShadow(info, oldSize);
            }
        }
    };
    Rtrace.prototype.onmove = function (oldPtr, newPtr) {
        this.syncShadow();
        ++this.moveCount;
        var oldInfo = this.getBlockInfo(oldPtr);
        var newInfo = this.getBlockInfo(newPtr);
        if (!this.blocks.has(oldPtr)) {
            this.onerror(Error("orphaned move (old): " + oldPtr), oldInfo);
        }
        else {
            if (!this.blocks.has(newPtr)) {
                this.onerror(Error("orphaned move (new): " + newPtr), newInfo);
            }
            else {
                var beforeInfo = this.blocks.get(oldPtr);
                var oldSize = oldInfo.size;
                var newSize = newInfo.size;
                if (beforeInfo.size != oldSize) {
                    this.onerror(Error("size mismatch upon move: " + oldPtr + " (" + beforeInfo.size + " != " + oldSize + ")"), oldInfo);
                }
                this.oninfo("MOVE " + oldPtr + ".." + (oldPtr + oldSize) + " -> " + newPtr + ".." + (newPtr + newSize));
                // calls new alloc before and old free after
            }
        }
    };
    Rtrace.prototype.onvisit = function (ptr) {
        // Indicates that a block has been freed but it still visited by the GC
        if (ptr > this.heapBase && !this.blocks.has(ptr)) {
            var err = Error("orphaned visit: " + ptr);
            var info = this.freedBlocks.get(ptr);
            if (info) {
                err.stack += "\n^ allocated at:\n" + info.allocStack.join("\n");
                err.stack += "\n^ freed at:\n" + info.freeStack.join("\n");
            }
            this.onerror(err, null);
            return false;
        }
        return true;
    };
    Rtrace.prototype.onfree = function (ptr) {
        this.syncShadow();
        ++this.freeCount;
        var info = this.getBlockInfo(ptr);
        if (!this.blocks.has(ptr)) {
            this.onerror(Error("orphaned free: " + ptr), info);
        }
        else {
            var oldInfo = this.blocks.get(ptr);
            if (info.size != oldInfo.size) {
                this.onerror(Error("size mismatch upon free: " + ptr + " (" + oldInfo.size + " != " + info.size + ")"), info);
            }
            this.oninfo("FREE " + ptr + ".." + (ptr + info.size));
            this.unmarkShadow(info);
            var allocInfo = this.blocks.get(ptr);
            this.blocks.delete(ptr);
            var allocStack = allocInfo.allocStack;
            var freeStack = trimStacktrace(new Error().stack, 1); // strip onfree
            // (not much) TODO: Maintaining these is essentially a memory leak
            this.freedBlocks.set(ptr, { allocStack: allocStack, freeStack: freeStack });
        }
    };
    Rtrace.prototype.oncollect = function (total) {
        this.oninfo("COLLECT at " + total);
        this.plot(total);
        this.oncollect_();
    };
    // GC profiling
    Rtrace.prototype.plot = function (total, pause) {
        if (pause === void 0) { pause = 0; }
        if (!this.gcProfileStart)
            this.gcProfileStart = Date.now();
        this.gcProfile.push([Date.now() - this.gcProfileStart, total, pause]);
    };
    Rtrace.prototype.oninterrupt = function (total) {
        this.interruptStart = hrtime();
        this.plot(total);
    };
    Rtrace.prototype.onyield = function (total) {
        var pause = hrtime() - this.interruptStart;
        if (pause >= 1)
            console.log("interrupted for " + pause.toFixed(1) + "ms");
        this.plot(total, pause);
    };
    // Memory instrumentation
    Rtrace.prototype.onstore = function (ptr, offset, bytes, isRT) {
        this.accessShadow(ptr + offset, bytes, false, isRT);
        return ptr;
    };
    Rtrace.prototype.onload = function (ptr, offset, bytes, isRT) {
        this.accessShadow(ptr + offset, bytes, true, isRT);
        return ptr;
    };
    return Rtrace;
}());
module.exports.Rtrace = Rtrace;
//# sourceMappingURL=rTrace.js.map