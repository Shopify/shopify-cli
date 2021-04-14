"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
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
var __spread = (this && this.__spread) || function () {
    for (var ar = [], i = 0; i < arguments.length; i++) ar = ar.concat(__read(arguments[i]));
    return ar;
};
var __makeTemplateObject = (this && this.__makeTemplateObject) || function (cooked, raw) {
    if (Object.defineProperty) { Object.defineProperty(cooked, "raw", { value: raw }); } else { cooked.raw = raw; }
    return cooked;
};
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (Object.prototype.hasOwnProperty.call(b, p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
define("util/IAspectExports", ["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
});
define("util/wasmTools", ["require", "exports"], function (require, exports) {
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
});
define("util/stringifyReflectedValue", ["require", "exports", "chalk"], function (require, exports, chalk_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.stringifyReflectedValue = void 0;
    chalk_1 = __importDefault(chalk_1);
    var StringifyContext = /** @class */ (function () {
        function StringifyContext() {
            this.level = 0;
            this.impliedTypeInfo = false;
            this.seen = new WeakSet();
            this.keywordFormatter = chalk_1.default.yellow;
            this.stringFormatter = chalk_1.default.cyan;
            this.classNameFormatter = chalk_1.default.green;
            this.numberFormatter = chalk_1.default.white;
            this.indent = 0;
            this.maxPropertyCount = 50;
            this.maxLineLength = 80;
            this.maxExpandLevel = 3;
            this.tab = 4;
        }
        return StringifyContext;
    }());
    function stringifyReflectedValue(reflectedValue, props) {
        var context = new StringifyContext();
        /* istanbul ignore next */
        if (props.keywordFormatter)
            context.keywordFormatter = props.keywordFormatter;
        /* istanbul ignore next */
        if (props.stringFormatter)
            context.stringFormatter = props.stringFormatter;
        /* istanbul ignore next */
        if (props.classNameFormatter)
            context.classNameFormatter = props.classNameFormatter;
        /* istanbul ignore next */
        if (props.numberFormatter)
            context.numberFormatter = props.numberFormatter;
        /* istanbul ignore next */
        if (props.maxExpandLevel)
            context.maxExpandLevel = props.maxExpandLevel;
        /* istanbul ignore next */
        if (typeof props.indent === "number")
            context.indent = props.indent;
        /* istanbul ignore next */
        if (typeof props.tab === "number")
            context.tab = props.tab;
        /* istanbul ignore next */
        if (typeof props.maxPropertyCount === "number")
            context.maxPropertyCount = props.maxPropertyCount;
        /* istanbul ignore next */
        if (typeof props.maxLineLength === "number")
            context.maxLineLength = props.maxLineLength;
        return formatters[formatterIndexFor(reflectedValue.type, 0 /* Expanded */)](reflectedValue, context);
    }
    exports.stringifyReflectedValue = stringifyReflectedValue;
    var formatters = [];
    /* istanbul ignore next */
    var emptyFormatter = function () { return ""; };
    for (var i = 0; i < 14 * 4; i++)
        formatters.push(emptyFormatter);
    var formatterIndexFor = function (valueType, type) { return valueType * 4 + type; };
    var falsyFormatter = function (reflectedValue) {
        return (reflectedValue.negated ? "Not " : "") + "Falsy";
    };
    formatters[formatterIndexFor(14 /* Falsy */, 0 /* Expanded */)] = falsyFormatter;
    var truthyFormatter = function (reflectedValue) {
        return (reflectedValue.negated ? "Not " : "") + "Truthy";
    };
    formatters[formatterIndexFor(13 /* Truthy */, 0 /* Expanded */)] = truthyFormatter;
    var finiteFormatter = function (reflectedValue) {
        return (reflectedValue.negated ? "Not " : "") + "Finite";
    };
    formatters[formatterIndexFor(12 /* Finite */, 0 /* Expanded */)] = finiteFormatter;
    function displayBooleanNoSpacing(reflectedValue, ctx) {
        return ctx.keywordFormatter(reflectedValue.value === 1 ? "true" : "false");
    }
    function displayBooleanWithSpacing(reflectedValue, ctx) {
        return (" ".repeat(ctx.indent + ctx.tab * ctx.level) +
            ctx.keywordFormatter(reflectedValue.value === 1 ? "true" : "false"));
    }
    // Booleans
    formatters[formatterIndexFor(9 /* Boolean */, 0 /* Expanded */)] = displayBooleanWithSpacing;
    formatters[formatterIndexFor(9 /* Boolean */, 1 /* Inline */)] = displayBooleanNoSpacing;
    formatters[formatterIndexFor(9 /* Boolean */, 2 /* Key */)] = displayBooleanWithSpacing;
    formatters[formatterIndexFor(9 /* Boolean */, 3 /* Value */)] = displayBooleanNoSpacing;
    function displayClassNoSpacing(reflectedValue, ctx) {
        return ctx.classNameFormatter("[" + reflectedValue.typeName + "]");
    }
    function displayNumberWithSpacing(reflectedValue, ctx) {
        var numericString = reflectedValue.value.toString();
        if (reflectedValue.type === 8 /* Float */ &&
            !/\.[0-9]/.test(numericString)) {
            numericString += ".0";
        }
        if (ctx.impliedTypeInfo ||
            reflectedValue.typeName === "i32" ||
            reflectedValue.typeName === "f64") {
            return (" ".repeat(ctx.indent + ctx.level * ctx.tab) +
                ctx.numberFormatter(numericString));
        }
        return (" ".repeat(ctx.indent + ctx.level * ctx.tab) +
            (ctx.numberFormatter(numericString) + " " + ctx.keywordFormatter("as") + " " + ctx.classNameFormatter(reflectedValue.typeName)));
    }
    function displayNumberNoSpacing(reflectedValue, ctx) {
        var numericString = reflectedValue.value.toString();
        if (reflectedValue.type === 8 /* Float */ &&
            !/\.[0-9]/.test(numericString)) {
            numericString += ".0";
        }
        if (ctx.impliedTypeInfo ||
            reflectedValue.typeName === "i32" ||
            reflectedValue.typeName === "f64") {
            return ctx.numberFormatter(numericString);
        }
        return ctx.numberFormatter(numericString) + " " + ctx.classNameFormatter("as " + reflectedValue.typeName);
    }
    // Floats
    formatters[formatterIndexFor(8 /* Float */, 0 /* Expanded */)] = displayNumberWithSpacing;
    formatters[formatterIndexFor(8 /* Float */, 1 /* Inline */)] = displayNumberNoSpacing;
    formatters[formatterIndexFor(8 /* Float */, 2 /* Key */)] = displayNumberWithSpacing;
    formatters[formatterIndexFor(8 /* Float */, 3 /* Value */)] = displayNumberNoSpacing;
    // Integers
    formatters[formatterIndexFor(7 /* Integer */, 0 /* Expanded */)] = displayNumberWithSpacing;
    formatters[formatterIndexFor(7 /* Integer */, 1 /* Inline */)] = displayNumberNoSpacing;
    formatters[formatterIndexFor(7 /* Integer */, 2 /* Key */)] = displayNumberWithSpacing;
    formatters[formatterIndexFor(7 /* Integer */, 3 /* Value */)] = displayNumberNoSpacing;
    function displayStringNoSpacing(reflectedValue, ctx) {
        return ctx.stringFormatter("\"" + reflectedValue.value.toString().replace(/"/g, '\\"') + "\"");
    }
    function displayStringWithSpacing(hostValue, ctx) {
        return (" ".repeat(ctx.indent + ctx.level * ctx.tab) +
            ctx.stringFormatter("\"" + hostValue.value.toString().replace(/"/g, '\\"') + "\""));
    }
    function displayNoQuoteStringWithSpacing(hostValue, ctx) {
        return (" ".repeat(ctx.indent + ctx.level * ctx.tab) +
            ctx.stringFormatter("" + hostValue.value.toString().replace(/"/g, '\\"')));
    }
    // Strings
    formatters[formatterIndexFor(2 /* String */, 0 /* Expanded */)] = displayStringWithSpacing;
    formatters[formatterIndexFor(2 /* String */, 1 /* Inline */)] = displayStringNoSpacing;
    formatters[formatterIndexFor(2 /* String */, 2 /* Key */)] = displayNoQuoteStringWithSpacing;
    formatters[formatterIndexFor(2 /* String */, 3 /* Value */)] = displayStringNoSpacing;
    function displayFunctionExpanded(hostValue, ctx) {
        return (" ".repeat(ctx.indent + ctx.level * ctx.tab) +
            ctx.classNameFormatter("[Function " + hostValue.pointer + ": " + hostValue.value.toString() + "]"));
    }
    var displayFuncNoNameNoPointer = function (_, ctx) {
        return ctx.classNameFormatter("[Function]");
    };
    // Functions
    formatters[formatterIndexFor(6 /* Function */, 0 /* Expanded */)] = displayFunctionExpanded;
    formatters[formatterIndexFor(6 /* Function */, 1 /* Inline */)] = displayFuncNoNameNoPointer;
    formatters[formatterIndexFor(6 /* Function */, 2 /* Key */)] = displayFunctionExpanded;
    formatters[formatterIndexFor(6 /* Function */, 3 /* Value */)] = displayFunctionExpanded;
    function displayClassExpanded(hostValue, ctx) {
        var spacing = " ".repeat(ctx.level * ctx.tab + ctx.indent);
        if (ctx.seen.has(hostValue))
            return spacing + ctx.classNameFormatter("[Circular Reference]");
        var previousImpliedTypeInfo = ctx.impliedTypeInfo;
        ctx.impliedTypeInfo = false;
        if (hostValue.isNull) {
            if (previousImpliedTypeInfo) {
                return spacing + "null";
            }
            else {
                return "" + spacing + ctx.classNameFormatter("<" + hostValue.typeName + ">") + "null";
            }
        }
        ctx.seen.add(hostValue);
        var body = "\n";
        ctx.level += 1;
        var length = hostValue.keys.length;
        var displayCount = Math.min(length, ctx.maxPropertyCount);
        for (var i = 0; i < displayCount; i++) {
            var key = hostValue.keys[i];
            var keyString = formatters[formatterIndexFor(key.type, 2 /* Key */)](key, ctx);
            var value = hostValue.values[i];
            var valueString = ctx.level < ctx.maxExpandLevel
                ? // render expanded value, but trim the whitespace on the left side
                    formatters[formatterIndexFor(value.type, 0 /* Expanded */)](value, ctx).trimLeft()
                : // render value
                    formatters[formatterIndexFor(value.type, 1 /* Inline */)](value, ctx).trimLeft();
            if (i === displayCount - 1) {
                // remove last trailing comma
                body += keyString + ": " + valueString + "\n";
            }
            else {
                body += keyString + ": " + valueString + ",\n";
            }
        }
        if (length > ctx.maxPropertyCount)
            body += spacing + "... +" + (length - ctx.maxPropertyCount) + " properties";
        ctx.level -= 1;
        ctx.impliedTypeInfo = previousImpliedTypeInfo;
        ctx.seen.delete(hostValue);
        if (previousImpliedTypeInfo) {
            return spacing + "{" + body + spacing + "}";
        }
        else {
            return "" + spacing + ctx.classNameFormatter(hostValue.typeName) + " {" + body + spacing + "}";
        }
    }
    function displayClassWithSpacing(hostValue, ctx) {
        return "" + " ".repeat(ctx.level * ctx.tab + ctx.indent) + ctx.classNameFormatter("[" + hostValue.typeName + "]");
    }
    // Classes
    formatters[formatterIndexFor(1 /* Class */, 0 /* Expanded */)] = displayClassExpanded;
    formatters[formatterIndexFor(1 /* Class */, 1 /* Inline */)] = displayClassNoSpacing;
    formatters[formatterIndexFor(1 /* Class */, 2 /* Key */)] = displayClassWithSpacing;
    formatters[formatterIndexFor(1 /* Class */, 3 /* Value */)] = displayClassExpanded;
    function displayArrayExpanded(hostValue, ctx) {
        var spacing = " ".repeat(ctx.level * ctx.tab + ctx.indent);
        if (ctx.seen.has(hostValue))
            return spacing + ctx.classNameFormatter("[Circular Reference]");
        ctx.seen.add(hostValue);
        var previousImpliedTypeInfo = ctx.impliedTypeInfo;
        ctx.impliedTypeInfo = true;
        if (ctx.level < ctx.maxExpandLevel &&
            hostValue.type === 10 /* Array */) {
            // expanded only for arrays
            var body = "\n";
            ctx.level += 1;
            var length_1 = Math.min(hostValue.values.length, ctx.maxPropertyCount);
            for (var i = 0; i < length_1 && i < ctx.maxPropertyCount; i++) {
                var value = hostValue.values[i];
                // render expanded value, but trim the whitespace on the left side
                var valueString = formatters[formatterIndexFor(value.type, 0 /* Expanded */)](value, ctx);
                if (i === length_1 - 1) {
                    // remove trailing comma
                    body += valueString + "\n";
                }
                else {
                    body += valueString + ",\n";
                }
            }
            if (length_1 >= ctx.maxPropertyCount)
                body += spacing + "... +" + (length_1 - ctx.maxPropertyCount) + " values";
            ctx.level -= 1;
            ctx.impliedTypeInfo = previousImpliedTypeInfo;
            ctx.seen.delete(hostValue);
            if (previousImpliedTypeInfo)
                return spacing + "[" + body + spacing + "]";
            return "" + spacing + ctx.classNameFormatter("" + hostValue.typeName) + " [" + body + spacing + "]";
        }
        else {
            // inline
            var body = spacing;
            if (!previousImpliedTypeInfo)
                body += ctx.classNameFormatter(hostValue.typeName) + " ";
            body += "[";
            var i = 0;
            var length_2 = hostValue.values.length;
            var count = Math.min(length_2, ctx.maxPropertyCount);
            for (; i < count; i++) {
                var value = hostValue.values[i];
                var resultStart = i === 0 ? " " : ", ";
                var result = resultStart +
                    formatters[formatterIndexFor(value.type, 1 /* Inline */)](value, ctx).trimLeft();
                if (body.length + result.length > ctx.maxLineLength) {
                    break;
                }
                body += result;
            }
            if (length_2 - i > 0)
                body += "... +" + (length_2 - i) + " items";
            body += " ]";
            ctx.impliedTypeInfo = previousImpliedTypeInfo;
            ctx.seen.delete(hostValue);
            // render value
            return body;
        }
    }
    // Array
    formatters[formatterIndexFor(10 /* Array */, 0 /* Expanded */)] = displayArrayExpanded;
    formatters[formatterIndexFor(10 /* Array */, 1 /* Inline */)] = displayArrayExpanded;
    formatters[formatterIndexFor(10 /* Array */, 2 /* Key */)] = displayClassWithSpacing;
    formatters[formatterIndexFor(10 /* Array */, 3 /* Value */)] = displayArrayExpanded;
    // ArrayBuffer
    formatters[formatterIndexFor(3 /* ArrayBuffer */, 0 /* Expanded */)] = displayArrayExpanded;
    formatters[formatterIndexFor(3 /* ArrayBuffer */, 1 /* Inline */)] = displayArrayExpanded;
    formatters[formatterIndexFor(3 /* ArrayBuffer */, 2 /* Key */)] = displayClassWithSpacing;
    formatters[formatterIndexFor(3 /* ArrayBuffer */, 3 /* Value */)] = displayArrayExpanded;
    // TypedArray
    formatters[formatterIndexFor(11 /* TypedArray */, 0 /* Expanded */)] = displayArrayExpanded;
    formatters[formatterIndexFor(11 /* TypedArray */, 1 /* Inline */)] = displayArrayExpanded;
    formatters[formatterIndexFor(11 /* TypedArray */, 2 /* Key */)] = displayClassWithSpacing;
    formatters[formatterIndexFor(11 /* TypedArray */, 3 /* Value */)] = displayArrayExpanded;
    // Map
    formatters[formatterIndexFor(4 /* Map */, 0 /* Expanded */)] = displayClassExpanded;
    formatters[formatterIndexFor(4 /* Map */, 1 /* Inline */)] = displayClassNoSpacing;
    formatters[formatterIndexFor(4 /* Map */, 2 /* Key */)] = displayClassWithSpacing;
    formatters[formatterIndexFor(4 /* Map */, 3 /* Value */)] = displayClassExpanded;
});
define("util/ReflectedValue", ["require", "exports", "util/stringifyReflectedValue"], function (require, exports, stringifyReflectedValue_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.ReflectedValue = void 0;
    /**
     * A JavaScript object that represents a reflected value from the as-pect testing
     * module.
     */
    var ReflectedValue = /** @class */ (function () {
        function ReflectedValue() {
            /** An indicator if the reflected object was managed by the runtime. */
            this.isManaged = false;
            /** An indicator if the reflected object was null. */
            this.isNull = false;
            /** A set of keys for Maps or Classes in the reflected object. */
            this.keys = null;
            /** Used to indicate if an expected assertion value was negated. */
            this.negated = false;
            /** An indicator wether the reflected object was in a nullable context. */
            this.nullable = false;
            /** The size of the heap allocation for a given class. */
            this.offset = 0;
            /** The pointer to the value in the module. */
            this.pointer = 0;
            /** An indicator if a number was signed. */
            this.signed = false;
            /** The size of an array, or the byte size of a number. */
            this.size = 0;
            /** A stack trace for the given value. */
            this.stack = "";
            /** The reflected value type. */
            this.type = 0 /* None */;
            /** The runtime class id for the reflected reflected value. */
            this.typeId = 0;
            /** The name of the class for a given reflected reflected value. */
            this.typeName = null;
            /** A string or number representing the reflected value. */
            this.value = 0;
            /** A set of values that are contained in a given reflected Set, Map, or Class object. */
            this.values = null;
        }
        /**
         * Stringify the ReflectedValue with custom formatting.
         *
         * @param {Partial<StringifyReflectedValueProps>} props - The stringify configuration
         */
        ReflectedValue.prototype.stringify = function (props) {
            if (props === void 0) { props = {}; }
            return stringifyReflectedValue_1.stringifyReflectedValue(this, props);
        };
        return ReflectedValue;
    }());
    exports.ReflectedValue = ReflectedValue;
});
define("util/TestNodeType", ["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
});
define("test/IWarning", ["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
});
define("util/timeDifference", ["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.timeDifference = void 0;
    /**
     * @ignore
     * This method calculates the start and end time difference, rounding off to the nearest thousandth
     * of a millisecond.
     *
     * @param {number} end - The end time.
     * @param {number} start - The start time.
     * @returns {number} - The difference of the two times rounded to the nearest three decimal places.
     */
    var timeDifference = function (end, start) {
        return Math.round((end - start) * 1000) / 1000;
    };
    exports.timeDifference = timeDifference;
});
define("test/TestNode", ["require", "exports", "util/timeDifference"], function (require, exports, timeDifference_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.TestNode = void 0;
    var TestNode = /** @class */ (function () {
        function TestNode() {
            /** The TestNode type. */
            this.type = 0 /* Test */;
            /** The name of the TestNode */
            this.name = "";
            /** The callback pointer. */
            this.callback = -1;
            /** If the test is expected to fail. */
            this.negated = false;
            /** The namespace of this TestNode */
            this.namespace = "";
            /** The callback pointers that need to be called before each test. */
            this.beforeEach = [];
            /** The callback pointers that need to be called once before traversing through this node's children. */
            this.beforeAll = [];
            /** The callback pointers that need to be called after each test. */
            this.afterEach = [];
            /** The callback pointers that need to be called once after traversing through this node's children. */
            this.afterAll = [];
            /** Parent TestNode */
            this.parent = null;
            /** Children TestNodes */
            this.children = [];
            /** An indicator if the test suite passed. */
            this.pass = false;
            /** A set of warnings. */
            this.warnings = [];
            /** A set of errors. */
            this.errors = [];
            /** A set of logged values. */
            this.logs = [];
            /** A stack trace for the error. */
            this.stackTrace = null;
            /** The actual reported value. */
            this.actual = null;
            /** The expected reported value. */
            this.expected = null;
            /** Message provided by the abort() function. */
            this.message = null;
            /** A set of todo messages provided by the testnode. */
            this.todos = [];
            /** Start time. */
            this.start = 0;
            /** End time. */
            this.end = 0;
            /** The number of active heap allocations when the node started. */
            this.rtraceStart = 0;
            /** The number of active heap allocations when the node ended. */
            this.rtraceEnd = 0;
            /** If the TestNode ran. */
            this.ran = false;
            /** The node allocations. */
            this.allocations = 0;
            /** The node deallocations */
            this.frees = 0;
            /** The node reallocations. */
            this.moves = 0;
        }
        Object.defineProperty(TestNode.prototype, "rtraceDelta", {
            /** The delta number of heap allocations. */
            get: function () {
                return this.allocations - this.frees;
            },
            enumerable: false,
            configurable: true
        });
        Object.defineProperty(TestNode.prototype, "deltaT", {
            /** The difference between the start and end TestNode runtime. */
            get: function () {
                return timeDifference_1.timeDifference(this.end, this.start);
            },
            enumerable: false,
            configurable: true
        });
        /**
         * Recursively visit this node's children conditionally. Return false to the callback
         * if you don't want to visit that particular node's children.
         */
        TestNode.prototype.visit = function (callback) {
            var children = this.children;
            for (var i = 0; i < children.length; i++) {
                var child = children[i];
                if (callback(child) !== false)
                    child.visit(callback);
            }
        };
        Object.defineProperty(TestNode.prototype, "groupTodos", {
            /** Get this group's todos, recursively. */
            get: function () {
                return [].concat.apply(this.todos, this.groupTests.map(function (e) { return e.todos; }));
            },
            enumerable: false,
            configurable: true
        });
        Object.defineProperty(TestNode.prototype, "groupTests", {
            /** Get this group's tests, recursively. */
            get: function () {
                var result = [];
                this.visit(function (node) {
                    if (node.type === 0 /* Test */) {
                        result.push(node);
                    }
                    else {
                        return false;
                    }
                });
                return result;
            },
            enumerable: false,
            configurable: true
        });
        Object.defineProperty(TestNode.prototype, "childGroups", {
            /** Get all the groups beneath this node. */
            get: function () {
                var result = [];
                this.visit(function (node) {
                    if (node.type === 1 /* Group */)
                        result.push(node);
                });
                return result;
            },
            enumerable: false,
            configurable: true
        });
        return TestNode;
    }());
    exports.TestNode = TestNode;
});
define("reporter/IReporter", ["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
});
define("test/TestContext", ["require", "exports", "../util/rTrace", "long", "util/wasmTools", "util/ReflectedValue", "test/TestNode", "perf_hooks", "@as-pect/snapshots"], function (require, exports, rTrace_1, long_1, wasmTools_1, ReflectedValue_1, TestNode_1, perf_hooks_1, snapshots_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.TestContext = void 0;
    long_1 = __importDefault(long_1);
    var id = function (a) { return a; };
    var stringifyOptions = {
        classNameFormatter: id,
        indent: 0,
        keywordFormatter: id,
        maxExpandLevel: Infinity,
        maxLineLength: Infinity,
        maxPropertyCount: Infinity,
        numberFormatter: id,
        stringFormatter: id,
        tab: 2,
    };
    /**
     * This function is a filter for stack trace lines.
     *
     * @param {string} input - The stack trace line.
     */
    var wasmFilter = function (input) { return /wasm/i.test(input); };
    /** This class is responsible for collecting and running all the tests in a test binary. */
    var TestContext = /** @class */ (function () {
        function TestContext(props) {
            var _this = this;
            /** The web assembly module if it was set. */
            this.wasm = null;
            /** The name section for function name evaluation. */
            this.nameSection = null;
            /** The top level node for this test suite. */
            this.rootNode = new TestNode_1.TestNode();
            /** The current working node that is collecting logs and callback pointers. */
            this.targetNode = this.rootNode;
            /** The name of the AssemblyScript test file. */
            this.fileName = "";
            /** An indicator to see if the TestSuite passed. */
            this.pass = false;
            /** The place where stack traces are stored when a function pointer errors.  */
            this.stack = "";
            /** The place where the abort() messages are stored. */
            this.message = "";
            /** The collected actual value. */
            this.actual = null;
            /** The collected expected value. */
            this.expected = null;
            /** Filter the tests by regex. */
            this.testRegex = new RegExp("");
            /** Filter the groups by regex. */
            this.groupRegex = new RegExp("");
            /** The test count. */
            this.testCount = 0;
            /** The number of tests that ran. */
            this.testRunCount = 0;
            /** The number of passing tests count. */
            this.testPassCount = 0;
            /** The group count. */
            this.groupCount = 0;
            /** The number of groups that ran. */
            this.groupRunCount = 0;
            /** The number of passing groups count. */
            this.groupPassCount = 0;
            /** The number of todos. */
            this.todoCount = 0;
            /** A collection of all the generated namespaces for shapshot purposes. */
            this.namespaces = new Set();
            /** The wasi instance associated with this module */
            this.wasi = null;
            /** The WebAssembly.Instance object. */
            this.instance = null;
            /** The module instance. */
            // private instance: WebAssembly.Instance | null = null;
            /**
             * A collection of reflected values used to help cache and aid in the creation
             * of nested reflected values.
             */
            this.reflectedValueCache = [];
            /** A collection of errors. */
            this.errors = [];
            /** A collection of warnings. */
            this.warnings = [];
            /** A collection of collected snapshots. */
            this.snapshots = new snapshots_1.Snapshot();
            /** The resulting snapshot diff. */
            this.snapshotDiff = null;
            /** A map of strings that can be cached because they are static. */
            this.cachedStrings = new Map();
            "";
            this.rtrace = new rTrace_1.Rtrace({
                /* istanbul ignore next */
                getMemory: function () {
                    /* istanbul ignore next */
                    return _this.wasm.memory;
                },
                /* istanbul ignore next */
                onerror: function (err, info) {
                    /* istanbul ignore next */
                    return _this.onRtraceError(err, info);
                },
                /* istanbul ignore next */
                oninfo: function (msg) {
                    /* istanbul ignore next */
                    return _this.onRtraceInfo(msg);
                }
            });
            /* istanbul ignore next */
            if (props.fileName)
                this.fileName = props.fileName;
            /* istanbul ignore next */
            if (props.testRegex)
                this.testRegex = props.testRegex;
            /* istanbul ignore next */
            if (props.groupRegex)
                this.groupRegex = props.groupRegex;
            if (props.binary)
                this.nameSection = new wasmTools_1.NameSection(props.binary);
            if (props.wasi)
                this.wasi = props.wasi;
            this.expectedSnapshots = props.snapshots ? props.snapshots : new snapshots_1.Snapshot();
            this.reporter = props.reporter;
            /* istanbul ignore next */
            if (typeof props.reporter.onEnter !== "function") {
                /* istanbul ignore next */
                this.pushError({
                    message: "Invalid reporter callback: onEnter is not a function",
                    stackTrace: "",
                    type: "TestContext Initialization",
                });
            }
            /* istanbul ignore next */
            if (typeof props.reporter.onExit !== "function") {
                /* istanbul ignore next */
                this.pushError({
                    message: "Invalid reporter callback: onExit is not a function",
                    stackTrace: "",
                    type: "TestContext Initialization",
                });
            }
            /* istanbul ignore next */
            if (typeof props.reporter.onFinish !== "function") {
                /* istanbul ignore next */
                this.pushError({
                    message: "Invalid reporter callback: onFinish is not a function",
                    stackTrace: "",
                    type: "TestContext Initialization",
                });
            }
            /** The root node is a group. */
            this.rootNode.type = 1 /* Group */;
        }
        /**
         * Track an rtrace error. This method should be bound and passed to the RTrace options.
         *
         * @param err - The error.
         * @param block - BlockInfo
         */
        // @ts-ignore
        TestContext.prototype.onRtraceError = function (err, block) {
            var _a;
            /* istanbul ignore next */
            this.pushError({
                message: "Block: " + block.ptr + " => " + err.message,
                stackTrace: 
                /* istanbul ignore next */
                ((_a = err.stack) === null || _a === void 0 ? void 0 : _a.split("\n").filter(wasmFilter).join("\n")) ||
                    "No stack trace provided.",
                type: "rtrace",
            });
        };
        TestContext.prototype.onRtraceInfo = function (_message) {
            // this.pushWarning({
            //   message,
            //   stackTrace: this.getLogStackTrace(),
            //   type: "rtrace",
            // });
        };
        /**
         * Call this method to start the `__main()` method provided by the `as-pect` exports to start the
         * process of test collection and evaluation.
         */
        TestContext.prototype.run = function (wasm) {
            /* istanbul ignore next */
            this.wasm = wasm.exports || wasm;
            this.instance = wasm.instance;
            // start by visiting the root node
            this.visit(this.rootNode);
            // calculate snapshot diff
            var snapshotDiff = this.snapshots.diff(this.expectedSnapshots);
            // determine if this test suite passed
            var snapshotsPass = Array.from(snapshotDiff.results.values()).reduce(function (result, value) {
                if (result) {
                    return (
                    // @ts-ignore
                    value.type === 1 /* Added */ ||
                        // @ts-ignore
                        value.type === 0 /* NoChange */);
                }
                return false;
            }, true);
            // store the diff results
            this.snapshotDiff = snapshotDiff;
            // determine if this test suite passed or failed
            this.pass = Boolean(snapshotsPass) && this.rootNode.pass;
            // finish the report
            this.reporter.onFinish(this);
        };
        /** Visit a node and evaluate it's children. */
        TestContext.prototype.visit = function (node) {
            // validate this node will run
            if (node !== this.rootNode) {
                var regexTester = node.type === 1 /* Group */ ? this.groupRegex : this.testRegex;
                if (!regexTester.test(node.name))
                    return;
            }
            // this node is being tested for sure
            node.ran = true;
            if (node.type === 1 /* Group */) {
                this.groupRunCount += 1;
            }
            else {
                this.testRunCount += 1;
            }
            // set the start timer for this node
            node.start = perf_hooks_1.performance.now();
            // set the rtraceStart value
            node.rtraceStart = this.rtrace.blocks.size;
            // set the target node for collection
            this.targetNode = node;
            // in the case of a throws() test
            if (node.negated) {
                var success = this.tryCall(node.callback) === 0; // we want the value to be 0
                this.reporter.onEnter(this, node);
                if (success) {
                    node.message = null;
                    node.stackTrace = null;
                    node.pass = true;
                    node.actual = null;
                    node.expected = null;
                }
                node.end = perf_hooks_1.performance.now();
                this.addResult(node, success);
                this.reporter.onExit(this, node);
                return;
            }
            // perform test collection and evaluate the node, each node must set pass to `true` if it passes
            if (node === this.rootNode) {
                try {
                    if (this.wasi) {
                        this.wasi.start(this.instance);
                    }
                    else {
                        // collect all the top level function pointers, tests, groups, and logs
                        this.wasm._start();
                    }
                }
                catch (ex) {
                    this.reporter.onEnter(this, node);
                    /**
                     * If this catch occurs, the entire test suite is completed.
                     * This is a sanity check.
                     */
                    node.end = perf_hooks_1.performance.now();
                    this.addResult(node, false);
                    this.reporter.onExit(this, node);
                    return;
                }
            }
            else {
                // gather all the tests and groups, validate program state at this level
                var success = this.tryCall(node.callback) === 1;
                this.reporter.onEnter(this, node);
                if (!success) {
                    // collection or test failure, stop traversal of this node
                    this.collectStatistics(node);
                    this.addResult(node, false);
                    this.reporter.onExit(this, node);
                    return;
                }
            }
            // Errors can occur at any level before you visit them, even if nothing was thrown
            if (node.errors.length > 0) {
                this.collectStatistics(node);
                this.addResult(node, false);
                this.reporter.onExit(this, node);
                return;
            }
            // We now have the responsibility to run each beforeAll callback before traversing children
            if (!this.runFunctions(node.beforeAll)) {
                this.collectStatistics(node);
                this.addResult(node, false);
                this.reporter.onExit(this, node);
                return;
            }
            // now that the tests have been collected and the beforeAll has run, visit each child
            var children = node.children;
            for (var i = 0; i < children.length; i++) {
                var child = children[i];
                // in the context of running a test, run the beforeEach functions
                if (child.type === 0 /* Test */) {
                    if (!this.runBeforeEach(node)) {
                        this.collectStatistics(node);
                        this.addResult(node, false);
                        this.reporter.onExit(this, node);
                        return;
                    }
                }
                // now we can visit the child
                this.visit(child);
                // in the context of running a test, run the afterEach functions
                if (child.type === 0 /* Test */) {
                    if (!this.runAfterEach(node)) {
                        this.collectStatistics(node);
                        this.addResult(node, false);
                        this.reporter.onExit(this, node);
                        return;
                    }
                }
            }
            // We now have the responsibility to run each afterAll callback after traversing children
            if (!this.runFunctions(node.afterAll)) {
                this.collectStatistics(node);
                this.addResult(node, false);
                this.reporter.onExit(this, node);
                return;
            }
            // if any children failed, this node failed too, but assume it passes
            node.pass = node.children.reduce(function (pass, node) { return pass && node.pass; }, true);
            node.end = perf_hooks_1.performance.now();
            this.addResult(node, true);
            this.reporter.onExit(this, node);
        };
        /** Report a TestNode */
        TestContext.prototype.reportTestNode = function (type, descriptionPointer, callbackPointer, negated, messagePointer) {
            var parent = this.targetNode;
            var node = new TestNode_1.TestNode();
            node.type = type;
            node.name = this.getString(descriptionPointer, node.name);
            node.callback = callbackPointer;
            node.negated = negated === 1;
            node.message = node.negated
                ? this.getString(messagePointer, "No Message Provided.")
                : node.message;
            // namespacing for snapshots later
            var namespacePrefix = parent.namespace + "!~" + node.name;
            var i = 0;
            while (true) {
                var namespace = namespacePrefix + "[" + i + "]";
                if (this.namespaces.has(namespace)) {
                    i++;
                    continue;
                }
                node.namespace = namespace;
                this.namespaces.add(namespace);
                break;
            }
            // fix the node hierarchy
            node.parent = parent;
            parent.children.push(node);
        };
        /** Obtain the stack trace, actual, expected, and message values, and attach them to a given node. */
        TestContext.prototype.collectStatistics = function (node) {
            node.stackTrace = this.stack;
            node.actual = this.actual;
            node.expected = this.expected;
            node.message = this.message;
            node.end = perf_hooks_1.performance.now();
            node.rtraceEnd = this.rtrace.blocks.size;
        };
        /** Add a test or group result to the statistics. */
        TestContext.prototype.addResult = function (node, pass) {
            if (node.type === 1 /* Group */) {
                this.groupCount += 1;
                if (pass)
                    this.groupPassCount += 1;
            }
            else {
                this.testCount += 1;
                if (pass)
                    this.testPassCount += 1;
            }
            this.todoCount += node.todos.length;
        };
        /** Run a series of callbacks into web assembly. */
        TestContext.prototype.runFunctions = function (funcs) {
            for (var i = 0; i < funcs.length; i++) {
                if (this.tryCall(funcs[i]) === 0)
                    return false;
            }
            return true;
        };
        /** Run every before each callback in the proper order. */
        TestContext.prototype.runBeforeEach = function (node) {
            return node.parent
                ? //run parents first and bail early if the parents failed
                    this.runBeforeEach(node.parent) && this.runFunctions(node.beforeEach)
                : this.runFunctions(node.beforeEach);
        };
        /** Run every before each callback in the proper order. */
        TestContext.prototype.runAfterEach = function (node) {
            return node.parent
                ? //run parents first and bail early if the parents failed
                    this.runAfterEach(node.parent) && this.runFunctions(node.afterEach)
                : this.runFunctions(node.afterEach);
        };
        /**
         * This method creates a WebAssembly imports object with all the TestContext functions
         * bound to the TestContext.
         *
         * @param {any[]} imports - Every import item specified.
         */
        TestContext.prototype.createImports = function () {
            var e_1, _a, e_2, _b;
            var _this = this;
            var imports = [];
            for (var _i = 0; _i < arguments.length; _i++) {
                imports[_i] = arguments[_i];
            }
            var finalImports = {};
            try {
                for (var imports_1 = __values(imports), imports_1_1 = imports_1.next(); !imports_1_1.done; imports_1_1 = imports_1.next()) {
                    var moduleImport = imports_1_1.value;
                    try {
                        for (var _c = (e_2 = void 0, __values(Object.entries(moduleImport))), _d = _c.next(); !_d.done; _d = _c.next()) {
                            var _e = __read(_d.value, 2), key = _e[0], value = _e[1];
                            /* istanbul ignore next */
                            if (key === "__aspect")
                                continue;
                            /* istanbul ignore next */
                            finalImports[key] = Object.assign(finalImports[key] || {}, value);
                        }
                    }
                    catch (e_2_1) { e_2 = { error: e_2_1 }; }
                    finally {
                        try {
                            if (_d && !_d.done && (_b = _c.return)) _b.call(_c);
                        }
                        finally { if (e_2) throw e_2.error; }
                    }
                }
            }
            catch (e_1_1) { e_1 = { error: e_1_1 }; }
            finally {
                try {
                    if (imports_1_1 && !imports_1_1.done && (_a = imports_1.return)) _a.call(imports_1);
                }
                finally { if (e_1) throw e_1.error; }
            }
            finalImports.__aspect = {
                attachStackTraceToReflectedValue: this.attachStackTraceToReflectedValue.bind(this),
                afterAll: this.reportAfterAll.bind(this),
                afterEach: this.reportAfterEach.bind(this),
                beforeAll: this.reportBeforeAll.bind(this),
                beforeEach: this.reportBeforeEach.bind(this),
                clearActual: this.clearActual.bind(this),
                clearExpected: this.clearExpected.bind(this),
                createReflectedValue: this.createReflectedValue.bind(this),
                createReflectedNumber: this.createReflectedNumber.bind(this),
                createReflectedLong: this.createReflectedLong.bind(this),
                debug: this.debug.bind(this),
                logReflectedValue: this.logReflectedValue.bind(this),
                pushReflectedObjectKey: this.pushReflectedObjectKey.bind(this),
                pushReflectedObjectValue: this.pushReflectedObjectValue.bind(this),
                reportActualReflectedValue: this.reportActualReflectedValue.bind(this),
                reportExpectedFalsy: this.reportExpectedFalsy.bind(this),
                reportExpectedFinite: this.reportExpectedFinite.bind(this),
                reportExpectedReflectedValue: this.reportExpectedReflectedValue.bind(this),
                reportNegatedTestNode: this.reportNegatedTestNode.bind(this),
                reportTodo: this.reportTodo.bind(this),
                reportTestTypeNode: this.reportTestTypeNode.bind(this),
                reportGroupTypeNode: this.reportGroupTypeNode.bind(this),
                reportExpectedSnapshot: this.reportExpectedSnapshot.bind(this),
                reportExpectedTruthy: this.reportExpectedTruthy.bind(this),
                tryCall: this.tryCall.bind(this),
            };
            this.rtrace.install(finalImports);
            finalImports.rtrace.onalloc = this.onalloc.bind(this);
            finalImports.rtrace.onfree = this.onfree.bind(this);
            /** add an env object */
            finalImports.env = finalImports.env || {};
            /** Override the abort function */
            var previousAbort = finalImports.env.abort || (function () { });
            finalImports.env.abort = function () {
                var args = [];
                for (var _i = 0; _i < arguments.length; _i++) {
                    args[_i] = arguments[_i];
                }
                previousAbort.apply(void 0, __spread(args));
                // @ts-ignore
                _this.abort.apply(_this, __spread(args));
            };
            /** Override trace completely. */
            finalImports.env.trace = this.trace.bind(this);
            // add wasi support if requested
            if (this.wasi) {
                finalImports.wasi_snapshot_preview1 = this.wasi.wasiImport;
            }
            return finalImports;
        };
        /**
         * This function sets up a test group.
         *
         * @param {number} description - The test suite description string pointer.
         * @param {number} runner - The pointer to a test suite callback
         */
        TestContext.prototype.reportGroupTypeNode = function (description, runner) {
            this.reportTestNode(1 /* Group */, description, runner, 0, 0);
        };
        /**
         * This function sets up a test node.
         *
         * @param description - The test description string pointer
         * @param runner - The pointer to a test callback
         */
        TestContext.prototype.reportTestTypeNode = function (description, runner) {
            this.reportTestNode(0 /* Test */, description, runner, 0, 0);
        };
        /**
         * This function expects a throws from a test node.
         *
         * @param description - The test description string pointer
         * @param runner - The pointer to a test callback
         * @param message - The pointer to an additional assertion message in string
         */
        TestContext.prototype.reportNegatedTestNode = function (description, runner, message) {
            this.reportTestNode(0 /* Test */, description, runner, 1, message);
        };
        /**
         * This is called to stop the debugger.  e.g. `node --inspect-brk asp`.
         */
        /* istanbul ignore next */
        TestContext.prototype.debug = function () {
            /* istanbul ignore next */
            debugger;
        };
        /**
         * This is a web assembly utility function that wraps a function call in a try catch block to
         * report success or failure.
         *
         * @param {number} pointer - The function pointer to call. It must accept no parameters and return
         * void.
         * @returns {1 | 0} - If the callback was run successfully without error, it returns 1, else it
         * returns 0.
         */
        TestContext.prototype.tryCall = function (pointer) {
            /** This is a safety net conditional, no reason to test it. */
            /* istanbul ignore next */
            if (pointer < 0)
                return 1;
            try {
                this.wasm.__call(pointer);
            }
            catch (ex) {
                this.stack = this.getErrorStackTrace(ex);
                return 0;
            }
            return 1;
        };
        /**
         * This web assembly linked function sets the group's "beforeEach" callback pointer to
         * the current groupStackItem.
         *
         * @param {number} callbackPointer - The callback that should run before each test.
         */
        TestContext.prototype.reportBeforeEach = function (callbackPointer) {
            this.targetNode.beforeEach.push(callbackPointer);
        };
        /**
         * This web assembly linked function adds the group's "beforeAll" callback pointer to
         * the current groupStackItem.
         *
         * @param {number} callbackPointer - The callback that should run before each test in the
         * current context.
         */
        TestContext.prototype.reportBeforeAll = function (callbackPointer) {
            this.targetNode.beforeAll.push(callbackPointer);
        };
        /**
         * This web assembly linked function sets the group's "afterEach" callback pointer.
         *
         * @param {number} callbackPointer - The callback that should run before each test group.
         */
        TestContext.prototype.reportAfterEach = function (callbackPointer) {
            this.targetNode.afterEach.push(callbackPointer);
        };
        /**
         * This web assembly linked function adds the group's "afterAll" callback pointer to
         * the current groupStackItem.
         *
         * @param {number} callbackPointer - The callback that should run before each test in the
         * current context.
         */
        TestContext.prototype.reportAfterAll = function (callbackPointer) {
            this.targetNode.afterAll.push(callbackPointer);
        };
        /**
         * This function reports a single "todo" item in a test suite.
         *
         * @param {number} todoPointer - The todo description string pointer.
         * @param {number} _callbackPointer - The test callback function pointer.
         */
        TestContext.prototype.reportTodo = function (todoPointer, _callbackPointer) {
            this.targetNode.todos.push(this.getString(todoPointer, "No todo() value provided."));
        };
        /**
         * This function overrides the provided AssemblyScript `env.abort()` function to catch abort
         * reasons.
         *
         * @param {number} reasonPointer - This points to the message value that causes the expectation to
         * fail.
         * @param {number} fileNamePointer - The file name that reported the error. (Ignored)
         * @param {number} line - The line that reported the error. (Ignored)
         * @param {number} col - The column that reported the error. (Ignored)
         */
        TestContext.prototype.abort = function (reasonPointer, fileNamePointer, line, col) {
            this.message = this.getString(reasonPointer, "Error in " + this.getString(fileNamePointer, "[No Filename Provided]") + ":" + line + ":" + col + " ");
        };
        /**
         * Gets an error stack trace.
         */
        TestContext.prototype.getErrorStackTrace = function (ex) {
            var stackItems = ex.stack.toString().split("\n");
            return __spread([stackItems[0]], stackItems.slice(1).filter(wasmFilter)).join("\n");
        };
        /**
         * Gets a log stack trace.
         */
        TestContext.prototype.getLogStackTrace = function () {
            return new Error("Get stack trace.")
                .stack.toString()
                .split("\n")
                .slice(1)
                .filter(wasmFilter)
                .join("\n");
        };
        /**
         * This method is called when a memory block is deallocated from the heap.
         *
         * @param {number} block - This is a unique identifier for the affected block.
         */
        TestContext.prototype.onfree = function (block) {
            this.targetNode.frees += 1;
            // remove any cached strings at this pointer
            this.cachedStrings.delete(block + rTrace_1.TOTAL_OVERHEAD);
            this.rtrace.onfree(block);
        };
        /**
         * This method is called when a memory block is allocated on the heap.
         *
         * @param {number} block - This is a unique identifier for the affected block.
         */
        TestContext.prototype.onalloc = function (block) {
            this.targetNode.allocations += 1;
            this.rtrace.onalloc(block);
        };
        /**
         * Gets a string from the wasm module, unless the module string is null. Otherwise it returns
         * a default value.
         */
        TestContext.prototype.getString = function (pointer, defaultValue) {
            pointer >>>= 0;
            if (pointer === 0)
                return defaultValue;
            if (this.cachedStrings.has(pointer)) {
                return this.cachedStrings.get(pointer);
            }
            var result = this.wasm.__getString(pointer);
            this.cachedStrings.set(pointer, result);
            return result;
        };
        /**
         * An override implementation of the AssemblyScript trace function.
         *
         * @param {number} strPointer - The trace string.
         * @param {number} count - The number of arguments to be traced.
         * @param {number[]} args - The traced arguments.
         */
        TestContext.prototype.trace = function (strPointer, count) {
            var args = [];
            for (var _i = 2; _i < arguments.length; _i++) {
                args[_i - 2] = arguments[_i];
            }
            var reflectedValue = new ReflectedValue_1.ReflectedValue();
            reflectedValue.pointer = strPointer;
            reflectedValue.stack = this.getLogStackTrace();
            reflectedValue.typeName = "trace";
            reflectedValue.type = 2 /* String */;
            reflectedValue.value = "trace: " + this.getString(strPointer, "") + " " + args.slice(0, count).join(", ");
            // push the log value to the logs
            this.targetNode.logs.push(reflectedValue);
        };
        /**
         * Retrieve the function name of a given web assembly function.
         *
         * @param {number} index - The function index
         */
        TestContext.prototype.funcName = function (index) {
            var nameSection = this.nameSection;
            /* istanbul ignore next */
            if (nameSection) {
                var result = this.wasm.table.get(index);
                return nameSection.fromIndex(parseInt(result.name));
            }
            /* istanbul ignore next */
            return "";
        };
        TestContext.prototype.createReflectedValue = function (isNull, hasKeys, nullable, offset, // offsetof<T>("propName")
        pointer, // changetype<usize>(this) | 0
        signed, // isSigned<T>()
        size, // sizeof<T>()
        reflectedTypeValue, typeId, // idof<T>()
        typeName, // nameof<T>()
        value, // usize
        hasValues, // bool
        isManaged) {
            var reflectedValue = new ReflectedValue_1.ReflectedValue();
            reflectedValue.isNull = isNull === 1;
            reflectedValue.keys = hasKeys ? [] : null;
            reflectedValue.nullable = nullable === 1;
            reflectedValue.offset = offset;
            reflectedValue.pointer = pointer;
            reflectedValue.signed = signed === 1;
            reflectedValue.size = size;
            reflectedValue.type = reflectedTypeValue;
            reflectedValue.typeId = typeId;
            reflectedValue.typeName = this.getString(typeName, "");
            reflectedValue.values = hasValues ? [] : null;
            reflectedValue.isManaged = isManaged === 1;
            if (reflectedTypeValue === 2 /* String */) {
                reflectedValue.value = this.getString(value, "");
            }
            else if (reflectedTypeValue === 6 /* Function */) {
                reflectedValue.value = this.funcName(value);
            }
            else {
                reflectedValue.value = value;
            }
            return this.reflectedValueCache.push(reflectedValue) - 1;
        };
        /**
         * Create a reflected number value.
         *
         * @param {1 | 0} signed - Indicate if the value is signed.
         * @param {number} size - The size of the value in bytes.
         * @param {ReflectedValueType} reflectedTypeValue - The ReflectedValueType
         * @param {number} typeName - The name of the type.
         * @param {number} value - The value itself
         */
        TestContext.prototype.createReflectedNumber = function (signed, // isSigned<T>()
        size, // sizeof<T>()
        reflectedTypeValue, typeName, // nameof<T>()
        value) {
            var reflectedValue = new ReflectedValue_1.ReflectedValue();
            reflectedValue.signed = signed === 1;
            reflectedValue.size = size;
            reflectedValue.type = reflectedTypeValue;
            reflectedValue.typeName = this.getString(typeName, "");
            reflectedValue.value = value;
            return this.reflectedValueCache.push(reflectedValue) - 1;
        };
        /**
         * Create reflection of a long number (not supported directly from javascript)
         */
        TestContext.prototype.createReflectedLong = function (signed, // isSigned<T>()
        size, // sizeof<T>()
        reflectedTypeValue, typeName, // nameof<T>()
        lowValue, // i32
        highValue) {
            var reflectedValue = new ReflectedValue_1.ReflectedValue();
            reflectedValue.signed = signed === 1;
            reflectedValue.size = size;
            reflectedValue.type = reflectedTypeValue;
            reflectedValue.typeName = this.getString(typeName, "");
            reflectedValue.value = long_1.default.fromBits(lowValue >>> 0, highValue >>> 0, signed === 0).toString();
            return this.reflectedValueCache.push(reflectedValue) - 1;
        };
        /**
         * Log a reflected value.
         *
         * @param {number} id - The ReflectedValue id
         */
        TestContext.prototype.logReflectedValue = function (id) {
            /* istanbul ignore next */
            if (id >= this.reflectedValueCache.length || id < 0) {
                /* istanbul ignore next */
                this.pushError({
                    message: "Cannot log ReflectedValue of id " + id + ". Index out of bounds.",
                    stackTrace: this.getLogStackTrace(),
                    type: "ReflectedValue",
                });
                /* istanbul ignore next */
                return;
            }
            this.targetNode.logs.push(this.reflectedValueCache[id]);
        };
        /**
         * Report an actual reflected value.
         *
         * @param {number} id - The ReflectedValue id
         */
        TestContext.prototype.reportActualReflectedValue = function (id) {
            // ignored lines are santiy checks for error reporting
            /* istanbul ignore next */
            if (id >= this.reflectedValueCache.length || id < 0) {
                /* istanbul ignore next */
                this.pushError({
                    message: "Cannot report actual ReflectedValue of id " + id + ". Index out of bounds.",
                    stackTrace: this.getLogStackTrace(),
                    type: "ReflectedValue",
                });
                /* istanbul ignore next */
                return;
            }
            this.actual = this.reflectedValueCache[id];
        };
        /**
         * Report an expected reflected value.
         *
         * @param {number} id - The ReflectedValue id
         */
        TestContext.prototype.reportExpectedReflectedValue = function (id, negated) {
            // ignored lines are error reporting for sanity checks
            /* istanbul ignore next */
            if (id >= this.reflectedValueCache.length || id < 0) {
                /* istanbul ignore next */
                this.pushError({
                    message: "Cannot report expected ReflectedValue of id " + id + ". Index out of bounds.",
                    stackTrace: this.getLogStackTrace(),
                    type: "ReflectedValue",
                });
                /* istanbul ignore next */
                return;
            }
            this.expected = this.reflectedValueCache[id];
            this.expected.negated = negated === 1;
        };
        /**
         * Push a reflected value to a given reflected value.
         *
         * @param {number} reflectedValueID - The target reflected value parent.
         * @param {number} childID - The child value by it's id to be pushed.
         */
        TestContext.prototype.pushReflectedObjectValue = function (reflectedValueID, childID) {
            // each ignored line for test coverage is error reporting for sanity checks
            /* istanbul ignore next */
            if (reflectedValueID >= this.reflectedValueCache.length ||
                reflectedValueID < 0) {
                /* istanbul ignore next */
                this.pushError({
                    message: "Cannot push ReflectedValue of id " + childID + " to ReflectedValue " + reflectedValueID + ". ReflectedValue id out of bounds.",
                    stackTrace: this.getLogStackTrace(),
                    type: "ReflectedValue",
                });
                /* istanbul ignore next */
                return;
            }
            /* istanbul ignore next */
            if (childID >= this.reflectedValueCache.length || childID < 0) {
                /* istanbul ignore next */
                this.pushError({
                    message: "Cannot push ReflectedValue of id " + childID + " to ReflectedValue " + reflectedValueID + ". ReflectedValue id out of bounds.",
                    stackTrace: this.getLogStackTrace(),
                    type: "ReflectedValue",
                });
                /* istanbul ignore next */
                return;
            }
            var reflectedParentValue = this.reflectedValueCache[reflectedValueID];
            var childValue = this.reflectedValueCache[childID];
            /* istanbul ignore next */
            if (!reflectedParentValue.values) {
                /* istanbul ignore next */
                this.pushError({
                    message: "Cannot push ReflectedValue of id " + childID + " to ReflectedValue " + reflectedValueID + ". ReflectedValue was not initialized with a values array.",
                    stackTrace: this.getLogStackTrace(),
                    type: "ReflectedValue",
                });
                /* istanbul ignore next */
                return;
            }
            reflectedParentValue.values.push(childValue);
        };
        /**
         * Push a reflected value key to a given reflected value.
         *
         * @param {number} reflectedValueID - The target reflected value parent.
         * @param {number} keyId - The target reflected value key to be pushed.
         */
        TestContext.prototype.pushReflectedObjectKey = function (reflectedValueID, keyId) {
            // every ignored line for test coverage in this function are sanity checks
            /* istanbul ignore next */
            if (reflectedValueID >= this.reflectedValueCache.length ||
                reflectedValueID < 0) {
                /* istanbul ignore next */
                this.pushError({
                    message: "Cannot push ReflectedValue of id " + keyId + " to ReflectedValue " + reflectedValueID + ". ReflectedValue id out of bounds.",
                    stackTrace: this.getLogStackTrace(),
                    type: "ReflectedValue",
                });
                /* istanbul ignore next */
                return;
            }
            /* istanbul ignore next */
            if (keyId >= this.reflectedValueCache.length || keyId < 0) {
                /* istanbul ignore next */
                this.pushError({
                    message: "Cannot push ReflectedValue of id " + keyId + " to ReflectedValue " + reflectedValueID + ". ReflectedValue key id out of bounds.",
                    stackTrace: this.getLogStackTrace(),
                    type: "ReflectedValue",
                });
                /* istanbul ignore next */
                return;
            }
            var reflectedValue = this.reflectedValueCache[reflectedValueID];
            var key = this.reflectedValueCache[keyId];
            // this is a failsafe if a keys[] does not exist on the ReflectedValue
            /* istanbul ignore next */
            if (!reflectedValue.keys) {
                /* istanbul ignore next */
                this.pushError({
                    message: "Cannot push ReflectedValue of id " + keyId + " to ReflectedValue " + reflectedValueID + ". ReflectedValue was not initialized with a keys array.",
                    stackTrace: this.getLogStackTrace(),
                    type: "ReflectedValue",
                });
                /* istanbul ignore next */
                return;
            }
            reflectedValue.keys.push(key);
        };
        /**
         * Clear the expected value.
         */
        TestContext.prototype.clearExpected = function () {
            this.expected = null;
        };
        /**
         * Clear the actual value.
         */
        TestContext.prototype.clearActual = function () {
            this.actual = null;
        };
        /**
         * Report an expected truthy value, and if it's negated.
         *
         * @param {1 | 0} negated - An indicator if the expectation is negated.
         */
        TestContext.prototype.reportExpectedTruthy = function (negated) {
            var expected = (this.expected = new ReflectedValue_1.ReflectedValue());
            expected.negated = negated === 1;
            expected.type = 13 /* Truthy */;
        };
        /**
         * Report an expected truthy value, and if it's negated.
         *
         * @param {1 | 0} negated - An indicator if the expectation is negated.
         */
        TestContext.prototype.reportExpectedFalsy = function (negated) {
            var expected = (this.expected = new ReflectedValue_1.ReflectedValue());
            expected.negated = negated === 1;
            expected.type = 14 /* Falsy */;
        };
        /**
         * Report an expected finite value, and if it's negated.
         *
         * @param {1 | 0} negated - An indicator if the expectation is negated.
         */
        TestContext.prototype.reportExpectedFinite = function (negated) {
            var expected = (this.expected = new ReflectedValue_1.ReflectedValue());
            expected.negated = negated === 1;
            expected.type = 12 /* Finite */;
        };
        /**
         * Attaches a stack trace to the given reflectedValue by it's id.
         *
         * @param {number} reflectedValueID - The given reflected value by it's id.
         */
        TestContext.prototype.attachStackTraceToReflectedValue = function (reflectedValueID) {
            /* istanbul ignore next */
            if (reflectedValueID >= this.reflectedValueCache.length ||
                reflectedValueID < 0) {
                /* istanbul ignore next */
                this.pushError({
                    message: "Cannot push a stack trace to ReflectedValue " + reflectedValueID + ". ReflectedValue id out of bounds.",
                    stackTrace: this.getLogStackTrace(),
                    type: "ReflectedValue",
                });
                /* istanbul ignore next */
                return;
            }
            this.reflectedValueCache[reflectedValueID].stack = this.getLogStackTrace();
        };
        /** Push an error to the errors array. */
        TestContext.prototype.pushError = function (error) {
            this.targetNode.errors.push(error);
            this.errors.push(error);
        };
        /** Push an warning to the warnings array. */
        /* istanbul ignore next */
        TestContext.prototype.pushWarning = function (warning) {
            /* istanbul ignore next */
            this.targetNode.warnings.push(warning);
            /* istanbul ignore next */
            this.warnings.push(warning);
        };
        /**
         * Report an expected snapshot.
         *
         * @param {number} reflectedValueID - The id of the reflected actual value.
         * @param {number} namePointer - The name of the snapshot.
         */
        TestContext.prototype.reportExpectedSnapshot = function (reflectedValueID, namePointer) {
            var name = this.targetNode.name + "!~" + this.getString(namePointer, "");
            /* istanbul ignore next */
            if (reflectedValueID >= this.reflectedValueCache.length ||
                reflectedValueID < 0) {
                /* istanbul ignore next */
                this.pushError({
                    message: "Cannot add snapshot " + name + " with reflected value " + reflectedValueID + ". ReflectedValue id out of bounds.",
                    stackTrace: this.getLogStackTrace(),
                    type: "ReflectedValue",
                });
                /* istanbul ignore next */
                return;
            }
            this.snapshots.add(name, this.reflectedValueCache[reflectedValueID].stringify(stringifyOptions));
        };
        return TestContext;
    }());
    exports.TestContext = TestContext;
});
define("reporter/CombinationReporter", ["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.CombinationReporter = void 0;
    /**
     * This reporter is used to combine a set of reporters into a single reporter object. It uses
     * forEach() to call each reporter's function when each method is called.
     */
    var CombinationReporter = /** @class */ (function () {
        function CombinationReporter(reporters) {
            this.reporters = reporters;
        }
        CombinationReporter.prototype.onEnter = function (ctx, node) {
            this.reporters.forEach(function (e) { return e.onEnter(ctx, node); });
        };
        CombinationReporter.prototype.onExit = function (ctx, node) {
            this.reporters.forEach(function (e) { return e.onExit(ctx, node); });
        };
        CombinationReporter.prototype.onFinish = function (ctx) {
            this.reporters.forEach(function (e) { return e.onFinish(ctx); });
        };
        return CombinationReporter;
    }());
    exports.CombinationReporter = CombinationReporter;
});
define("reporter/EmptyReporter", ["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.EmptyReporter = void 0;
    /**
     * This class can be used as a stub reporter to interface with the `TestContext` in the browser.
     * It will not report any information about the tests.
     */
    var EmptyReporter = /** @class */ (function () {
        function EmptyReporter(_options) {
        }
        EmptyReporter.prototype.onEnter = function (_context, _node) { };
        EmptyReporter.prototype.onExit = function (_context, _node) { };
        EmptyReporter.prototype.onFinish = function (_context) { };
        return EmptyReporter;
    }());
    exports.EmptyReporter = EmptyReporter;
});
define("util/IWriteable", ["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
});
define("reporter/SummaryReporter", ["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.SummaryReporter = void 0;
    /**
     * This test reporter should be used when logging output and test validation only needs happen on
     * the group level. It is useful for CI builds and also reduces IO output to speed up the testing
     * process.
     */
    var SummaryReporter = /** @class */ (function () {
        function SummaryReporter(options) {
            this.enableLogging = true;
            this.stdout = null;
            this.stderr = null;
            /* istanbul ignore next */
            if (options) {
                // can be "false" from cli
                /* istanbul ignore next */
                if (!options.enableLogging ||
                    /* istanbul ignore next */ options.enableLogging === "false")
                    /* istanbul ignore next */
                    this.enableLogging = false;
            }
        }
        SummaryReporter.prototype.onEnter = function (_ctx, _node) { };
        SummaryReporter.prototype.onExit = function (_ctx, _node) { };
        /* istanbul ignore next */
        SummaryReporter.prototype.onStart = function (_ctx) { };
        /* istanbul ignore next */
        SummaryReporter.prototype.onGroupStart = function (_node) { };
        /* istanbul ignore next */
        SummaryReporter.prototype.onGroupFinish = function (_node) { };
        /* istanbul ignore next */
        SummaryReporter.prototype.onTestStart = function (_group, _test) { };
        /* istanbul ignore next */
        SummaryReporter.prototype.onTestFinish = function (_group, _test) { };
        /* istanbul ignore next */
        SummaryReporter.prototype.onTodo = function () { };
        /**
         * This method reports a test context is finished running.
         *
         * @param {TestContext} suite - The finished test suite.
         */
        SummaryReporter.prototype.onFinish = function (suite) {
            var e_3, _a, e_4, _b, e_5, _c, e_6, _d, e_7, _e, e_8, _f, e_9, _g, e_10, _h, e_11, _j, e_12, _k, e_13, _l, e_14, _m, e_15, _o;
            var chalk = require("chalk");
            var testGroups = suite.rootNode.childGroups;
            // TODO: Figure out a better way to flatten this array.
            var todos = [].concat.apply([], testGroups.map(function (e) { return e.groupTodos; })).length;
            var total = suite.testCount;
            var passCount = suite.testPassCount;
            var deltaT = suite.rootNode.deltaT;
            /** Report if all the groups passed. */
            if (suite.pass) {
                this.stdout.write(chalk(templateObject_1 || (templateObject_1 = __makeTemplateObject(["{green.bold \u2714 ", "} Pass: ", " / ", " Todo: ", " Time: ", "ms\n"], ["{green.bold \u2714 ",
                    "} Pass: ", " / ", " Todo: ", " Time: ", "ms\\n"])), suite.fileName, passCount.toString(), total.toString(), todos.toString(), deltaT.toString()));
                /** If logging is enabled, log all the values. */
                /* istanbul ignore next */
                if (this.enableLogging) {
                    try {
                        for (var testGroups_1 = __values(testGroups), testGroups_1_1 = testGroups_1.next(); !testGroups_1_1.done; testGroups_1_1 = testGroups_1.next()) {
                            var group = testGroups_1_1.value;
                            try {
                                for (var _p = (e_4 = void 0, __values(group.logs)), _q = _p.next(); !_q.done; _q = _p.next()) {
                                    var log = _q.value;
                                    this.onLog(log);
                                }
                            }
                            catch (e_4_1) { e_4 = { error: e_4_1 }; }
                            finally {
                                try {
                                    if (_q && !_q.done && (_b = _p.return)) _b.call(_p);
                                }
                                finally { if (e_4) throw e_4.error; }
                            }
                            try {
                                for (var _r = (e_5 = void 0, __values(group.groupTests)), _s = _r.next(); !_s.done; _s = _r.next()) {
                                    var test_1 = _s.value;
                                    try {
                                        for (var _t = (e_6 = void 0, __values(test_1.logs)), _u = _t.next(); !_u.done; _u = _t.next()) {
                                            var log = _u.value;
                                            this.onLog(log);
                                        }
                                    }
                                    catch (e_6_1) { e_6 = { error: e_6_1 }; }
                                    finally {
                                        try {
                                            if (_u && !_u.done && (_d = _t.return)) _d.call(_t);
                                        }
                                        finally { if (e_6) throw e_6.error; }
                                    }
                                }
                            }
                            catch (e_5_1) { e_5 = { error: e_5_1 }; }
                            finally {
                                try {
                                    if (_s && !_s.done && (_c = _r.return)) _c.call(_r);
                                }
                                finally { if (e_5) throw e_5.error; }
                            }
                        }
                    }
                    catch (e_3_1) { e_3 = { error: e_3_1 }; }
                    finally {
                        try {
                            if (testGroups_1_1 && !testGroups_1_1.done && (_a = testGroups_1.return)) _a.call(testGroups_1);
                        }
                        finally { if (e_3) throw e_3.error; }
                    }
                }
            }
            else {
                this.stdout.write(chalk(templateObject_2 || (templateObject_2 = __makeTemplateObject(["{red.bold \u274C ", "} Pass: ", " / ", " Todo: ", " Time: ", "ms\n"], ["{red.bold \u274C ",
                    "} Pass: ", " / ", " Todo: ", " Time: ", "ms\\n"])), suite.fileName, passCount.toString(), total.toString(), todos.toString(), deltaT.toString()));
                try {
                    /** If the group failed, report that the group failed. */
                    for (var testGroups_2 = __values(testGroups), testGroups_2_1 = testGroups_2.next(); !testGroups_2_1.done; testGroups_2_1 = testGroups_2.next()) {
                        var group = testGroups_2_1.value;
                        /* istanbul ignore next */
                        if (group.pass)
                            continue;
                        this.stdout.write(chalk(templateObject_3 || (templateObject_3 = __makeTemplateObject(["  {red Failed:} ", "\n"], ["  {red Failed:} ", "\\n"])), group.name));
                        /** Display the reason if there is one. */
                        // if (group.reason)
                        //   this.stdout!.write(chalk`    {yellow Reason:} ${group.reason}`);
                        /** Log each log item in the failed group. */
                        /* istanbul ignore next */
                        if (this.enableLogging) {
                            try {
                                for (var _v = (e_8 = void 0, __values(group.logs)), _w = _v.next(); !_w.done; _w = _v.next()) {
                                    var log = _w.value;
                                    this.onLog(log);
                                }
                            }
                            catch (e_8_1) { e_8 = { error: e_8_1 }; }
                            finally {
                                try {
                                    if (_w && !_w.done && (_f = _v.return)) _f.call(_v);
                                }
                                finally { if (e_8) throw e_8.error; }
                            }
                        }
                        try {
                            inner: for (var _x = (e_9 = void 0, __values(group.groupTests)), _y = _x.next(); !_y.done; _y = _x.next()) {
                                var test_2 = _y.value;
                                if (test_2.pass)
                                    continue inner;
                                this.stdout.write(chalk(templateObject_4 || (templateObject_4 = __makeTemplateObject(["    {red.bold \u274C ", "} - ", "\n"], ["    {red.bold \u274C ", "} - ", "\\n"])), test_2.name, test_2.message));
                                if (test_2.actual !== null)
                                    this.stdout.write(chalk(templateObject_5 || (templateObject_5 = __makeTemplateObject(["      {red.bold [Actual]  :} ", "\n"], ["      {red.bold [Actual]  :} ",
                                        "\\n"])), test_2.actual
                                        .stringify({ indent: 2 })
                                        .trimLeft()));
                                if (test_2.expected !== null) {
                                    var expected = test_2.expected;
                                    this.stdout.write(chalk(templateObject_6 || (templateObject_6 = __makeTemplateObject(["      {green.bold [Expected]:} ", "", "\n"], ["      {green.bold [Expected]:} ",
                                        "", "\\n"])), expected.negated ? "Not " : "", expected.stringify({ indent: 2 }).trimLeft()));
                                }
                                /* istanbul ignore next */
                                if (this.enableLogging) {
                                    try {
                                        for (var _z = (e_10 = void 0, __values(test_2.logs)), _0 = _z.next(); !_0.done; _0 = _z.next()) {
                                            var log = _0.value;
                                            this.onLog(log);
                                        }
                                    }
                                    catch (e_10_1) { e_10 = { error: e_10_1 }; }
                                    finally {
                                        try {
                                            if (_0 && !_0.done && (_h = _z.return)) _h.call(_z);
                                        }
                                        finally { if (e_10) throw e_10.error; }
                                    }
                                }
                            }
                        }
                        catch (e_9_1) { e_9 = { error: e_9_1 }; }
                        finally {
                            try {
                                if (_y && !_y.done && (_g = _x.return)) _g.call(_x);
                            }
                            finally { if (e_9) throw e_9.error; }
                        }
                    }
                }
                catch (e_7_1) { e_7 = { error: e_7_1 }; }
                finally {
                    try {
                        if (testGroups_2_1 && !testGroups_2_1.done && (_e = testGroups_2.return)) _e.call(testGroups_2);
                    }
                    finally { if (e_7) throw e_7.error; }
                }
            }
            try {
                // There are no warnings left in the as-pect test suite software
                for (var _1 = __values(suite.warnings), _2 = _1.next(); !_2.done; _2 = _1.next()) {
                    var warning = _2.value;
                    /* istanbul ignore next */
                    this.stdout.write(chalk(templateObject_7 || (templateObject_7 = __makeTemplateObject(["{yellow  [Warning]}: ", " -> ", "\n"], ["{yellow  [Warning]}: ", " -> ", "\\n"])), warning.type, warning.message));
                    /* istanbul ignore next */
                    var stack = warning.stackTrace.trim();
                    /* istanbul ignore next */
                    if (stack) {
                        this.stdout.write(chalk(templateObject_8 || (templateObject_8 = __makeTemplateObject(["{yellow    [Stack]}: {yellow ", "}\n"], ["{yellow    [Stack]}: {yellow ",
                            "}\\n"])), stack
                            .split("\n")
                            .join("\n      ")));
                    }
                    /* istanbul ignore next */
                    this.stdout.write("\n");
                }
            }
            catch (e_11_1) { e_11 = { error: e_11_1 }; }
            finally {
                try {
                    if (_2 && !_2.done && (_j = _1.return)) _j.call(_1);
                }
                finally { if (e_11) throw e_11.error; }
            }
            try {
                for (var _3 = __values(suite.errors), _4 = _3.next(); !_4.done; _4 = _3.next()) {
                    var error = _4.value;
                    this.stdout.write(chalk(templateObject_9 || (templateObject_9 = __makeTemplateObject(["{red    [Error]}: ", " ", "\n"], ["{red    [Error]}: ", " ", "\\n"])), error.type, error.message));
                    this.stdout.write(chalk(templateObject_10 || (templateObject_10 = __makeTemplateObject(["{red    [Stack]}: {yellow ", "}\n\n"], ["{red    [Stack]}: {yellow ",
                        "}\\n\\n"])), error.stackTrace
                        .split("\n")
                        .join("\n           ")));
                }
            }
            catch (e_12_1) { e_12 = { error: e_12_1 }; }
            finally {
                try {
                    if (_4 && !_4.done && (_k = _3.return)) _k.call(_3);
                }
                finally { if (e_12) throw e_12.error; }
            }
            var diff = suite.snapshotDiff.results;
            try {
                for (var _5 = __values(diff.entries()), _6 = _5.next(); !_6.done; _6 = _5.next()) {
                    var _7 = __read(_6.value, 2), name_1 = _7[0], result = _7[1];
                    if (result.type !== 0 /* NoChange */) {
                        this.stdout.write(chalk(templateObject_11 || (templateObject_11 = __makeTemplateObject(["{red [Snapshot]}: ", "\n"], ["{red [Snapshot]}: ", "\\n"])), name_1));
                        var changes = result.changes;
                        try {
                            for (var changes_1 = (e_14 = void 0, __values(changes)), changes_1_1 = changes_1.next(); !changes_1_1.done; changes_1_1 = changes_1.next()) {
                                var change = changes_1_1.value;
                                var lines = change.value.split("\n");
                                try {
                                    for (var lines_1 = (e_15 = void 0, __values(lines)), lines_1_1 = lines_1.next(); !lines_1_1.done; lines_1_1 = lines_1.next()) {
                                        var line = lines_1_1.value;
                                        if (!line.trim())
                                            continue;
                                        if (change.added) {
                                            this.stdout.write(chalk(templateObject_12 || (templateObject_12 = __makeTemplateObject(["{green + ", "}\n"], ["{green + ", "}\\n"])), line));
                                        }
                                        else if (change.removed) {
                                            this.stdout.write(chalk(templateObject_13 || (templateObject_13 = __makeTemplateObject(["{red - ", "}\n"], ["{red - ", "}\\n"])), line));
                                        }
                                        else {
                                            this.stdout.write(chalk(templateObject_14 || (templateObject_14 = __makeTemplateObject(["  ", "\n"], ["  ", "\\n"])), line));
                                        }
                                    }
                                }
                                catch (e_15_1) { e_15 = { error: e_15_1 }; }
                                finally {
                                    try {
                                        if (lines_1_1 && !lines_1_1.done && (_o = lines_1.return)) _o.call(lines_1);
                                    }
                                    finally { if (e_15) throw e_15.error; }
                                }
                            }
                        }
                        catch (e_14_1) { e_14 = { error: e_14_1 }; }
                        finally {
                            try {
                                if (changes_1_1 && !changes_1_1.done && (_m = changes_1.return)) _m.call(changes_1);
                            }
                            finally { if (e_14) throw e_14.error; }
                        }
                        this.stdout.write("\n");
                    }
                }
            }
            catch (e_13_1) { e_13 = { error: e_13_1 }; }
            finally {
                try {
                    if (_6 && !_6.done && (_l = _5.return)) _l.call(_5);
                }
                finally { if (e_13) throw e_13.error; }
            }
        };
        /**
         * A custom logger function for the default reporter that writes the log values using `console.log()`
         *
         * @param {ReflectedValue} logValue - A value to be logged to the console
         */
        SummaryReporter.prototype.onLog = function (logValue) {
            var chalk = require("chalk");
            var output = logValue.stringify({ indent: 12 }).trimLeft();
            this.stdout.write(chalk(templateObject_15 || (templateObject_15 = __makeTemplateObject(["     {yellow [Log]:} ", "\n"], ["     {yellow [Log]:} ", "\\n"])), output));
        };
        return SummaryReporter;
    }());
    exports.SummaryReporter = SummaryReporter;
    var templateObject_1, templateObject_2, templateObject_3, templateObject_4, templateObject_5, templateObject_6, templateObject_7, templateObject_8, templateObject_9, templateObject_10, templateObject_11, templateObject_12, templateObject_13, templateObject_14, templateObject_15;
});
define("reporter/VerboseReporter", ["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.VerboseReporter = void 0;
    /**
     * This is the default test reporter class for the `asp` command line application. It will pipe
     * all relevant details about each tests to the `stdout` WriteStream.
     */
    var VerboseReporter = /** @class */ (function () {
        function VerboseReporter(_options) {
            this.stdout = null;
            this.stderr = null;
            /** A set of default stringify properties that can be overridden. */
            this.stringifyProperties = {
                maxExpandLevel: 10,
            };
        }
        VerboseReporter.prototype.onEnter = function (_ctx, node) {
            if (node.type === 1 /* Group */) {
                this.onGroupStart(node);
            }
            else {
                this.onTestStart(node.parent, node);
            }
        };
        VerboseReporter.prototype.onExit = function (_ctx, node) {
            if (node.type === 1 /* Group */) {
                this.onGroupFinish(node);
            }
            else {
                this.onTestFinish(node.parent, node);
            }
        };
        /**
         * This method reports a TestGroup is starting.
         *
         * @param {TestNode} group - The started test group.
         */
        VerboseReporter.prototype.onGroupStart = function (group) {
            /* istanbul ignore next */
            if (group.groupTests.length === 0)
                return;
            var chalk = require("chalk");
            /* istanbul ignore next */
            if (group.name)
                this.stdout.write(chalk(templateObject_16 || (templateObject_16 = __makeTemplateObject(["[Describe]: ", "\n\n"], ["[Describe]: ", "\\n\\n"])), group.name));
        };
        /**
         * This method reports a completed TestGroup.
         *
         * @param {TestGroup} group - The finished TestGroup.
         */
        VerboseReporter.prototype.onGroupFinish = function (group) {
            var e_16, _a, e_17, _b;
            if (group.groupTests.length === 0)
                return;
            try {
                for (var _c = __values(group.groupTodos), _d = _c.next(); !_d.done; _d = _c.next()) {
                    var todo = _d.value;
                    this.onTodo(group, todo);
                }
            }
            catch (e_16_1) { e_16 = { error: e_16_1 }; }
            finally {
                try {
                    if (_d && !_d.done && (_a = _c.return)) _a.call(_c);
                }
                finally { if (e_16) throw e_16.error; }
            }
            try {
                for (var _e = __values(group.logs), _f = _e.next(); !_f.done; _f = _e.next()) {
                    var logValue = _f.value;
                    this.onLog(logValue);
                }
            }
            catch (e_17_1) { e_17 = { error: e_17_1 }; }
            finally {
                try {
                    if (_f && !_f.done && (_b = _e.return)) _b.call(_e);
                }
                finally { if (e_17) throw e_17.error; }
            }
            this.stdout.write("\n");
        };
        /** This method is a stub for onTestStart(). */
        VerboseReporter.prototype.onTestStart = function (_group, _test) { };
        /**
         * This method reports a completed test.
         *
         * @param {TestNode} _group - The TestGroup that the TestResult belongs to.
         * @param {TestNode} test - The finished TestResult
         */
        VerboseReporter.prototype.onTestFinish = function (_group, test) {
            var e_18, _a;
            var chalk = require("chalk");
            if (test.pass) {
                /* istanbul ignore next */
                var rtraceDelta = 
                /* istanbul ignore next */
                test.rtraceDelta === 0
                    /* istanbul ignore next */
                    ? ""
                    /* istanbul ignore next */
                    : chalk(templateObject_17 || (templateObject_17 = __makeTemplateObject([" {yellow RTrace: ", "}"], [" {yellow RTrace: "
                        /* istanbul ignore next */
                        ,
                        "}"])), 
                    /* istanbul ignore next */
                    (test.rtraceDelta > 0
                        ? /* istanbul ignore next */
                            "+"
                        : /* istanbul ignore next */
                            "") + test.rtraceDelta.toString());
                this.stdout.write(test.negated
                    ? chalk(templateObject_18 || (templateObject_18 = __makeTemplateObject([" {green  [Throws]: \u2714} ", "", "\n"], [" {green  [Throws]: \u2714} ", "", "\\n"])), test.name, rtraceDelta) : chalk(templateObject_19 || (templateObject_19 = __makeTemplateObject([" {green [Success]: \u2714} ", "", "\n"], [" {green [Success]: \u2714} ", "", "\\n"])), test.name, rtraceDelta));
            }
            else {
                this.stdout.write(chalk(templateObject_20 || (templateObject_20 = __makeTemplateObject(["    {red [Fail]: \u2716} ", "\n"], ["    {red [Fail]: \u2716} ", "\\n"])), test.name));
                var stringifyIndent2 = Object.assign({}, this.stringifyProperties, {
                    indent: 2,
                });
                if (!test.negated) {
                    if (test.actual) {
                        this.stdout.write("  [Actual]: " + test
                            .actual.stringify(stringifyIndent2)
                            .trimLeft() + "\n");
                    }
                    if (test.expected) {
                        var expected = test.expected;
                        this.stdout.write("[Expected]: " + (expected.negated ? "Not " : "") + expected
                            .stringify(stringifyIndent2)
                            .trimLeft() + "\n");
                    }
                }
                /* istanbul ignore next */
                if (test.message) {
                    this.stdout.write(chalk(templateObject_21 || (templateObject_21 = __makeTemplateObject([" [Message]: {yellow ", "}\n"], [" [Message]: {yellow ", "}\\n"])), test.message));
                }
                /* istanbul ignore next */
                if (test.stackTrace) {
                    this.stdout.write("   [Stack]: " + test.stackTrace.split("\n").join("\n        ") + "\n");
                }
            }
            try {
                /** Log the values to stdout if this was a typical test. */
                for (var _b = __values(test.logs), _c = _b.next(); !_c.done; _c = _b.next()) {
                    var logValue = _c.value;
                    this.onLog(logValue);
                }
            }
            catch (e_18_1) { e_18 = { error: e_18_1 }; }
            finally {
                try {
                    if (_c && !_c.done && (_a = _b.return)) _a.call(_b);
                }
                finally { if (e_18) throw e_18.error; }
            }
        };
        /**
         * This method reports that a TestContext has finished.
         *
         * @param {TestContext} suite - The finished test context.
         */
        VerboseReporter.prototype.onFinish = function (suite) {
            var e_19, _a, e_20, _b, e_21, _c, e_22, _d, e_23, _e;
            /* istanbul ignore next */
            if (suite.rootNode.children.length === 0)
                return;
            var chalk = require("chalk");
            var result = suite.pass ? chalk(templateObject_22 || (templateObject_22 = __makeTemplateObject(["{green \u2714 PASS}"], ["{green \u2714 PASS}"]))) : chalk(templateObject_23 || (templateObject_23 = __makeTemplateObject(["{red \u2716 FAIL}"], ["{red \u2716 FAIL}"])));
            var count = suite.testCount;
            var successCount = suite.testPassCount;
            var failText = count === successCount
                ? "0 fail"
                : chalk(templateObject_24 || (templateObject_24 = __makeTemplateObject(["{red ", " fail}"], ["{red ", " fail}"])), (count - successCount).toString());
            try {
                // There are currently no warnings provided by the as-pect testing suite
                /* istanbul ignore next */
                for (var _f = __values(suite.warnings), _g = _f.next(); !_g.done; _g = _f.next()) {
                    var warning = _g.value;
                    /* istanbul ignore next */
                    this.stdout.write(chalk(templateObject_25 || (templateObject_25 = __makeTemplateObject(["\n{yellow  [Warning]}: ", " -> ", "\n"], ["\\n{yellow  [Warning]}: ", " -> ", "\\n"])), warning.type, warning.message));
                    /* istanbul ignore next */
                    var stack = warning.stackTrace.trim();
                    /* istanbul ignore next */
                    if (stack) {
                        /* istanbul ignore next */
                        this.stdout.write(chalk(templateObject_26 || (templateObject_26 = __makeTemplateObject(["{yellow    [Stack]}: {yellow ", "}\n"], ["{yellow    [Stack]}: {yellow ",
                            "}\\n"])), stack
                            .split("\n")
                            .join("\n      ")));
                    }
                    /* istanbul ignore next */
                    this.stdout.write("\n");
                }
            }
            catch (e_19_1) { e_19 = { error: e_19_1 }; }
            finally {
                try {
                    if (_g && !_g.done && (_a = _f.return)) _a.call(_f);
                }
                finally { if (e_19) throw e_19.error; }
            }
            try {
                for (var _h = __values(suite.errors), _j = _h.next(); !_j.done; _j = _h.next()) {
                    var error = _j.value;
                    this.stdout.write(chalk(templateObject_27 || (templateObject_27 = __makeTemplateObject(["\n{red    [Error]}: ", " ", ""], ["\\n{red    [Error]}: ", " ", ""])), error.type, error.message));
                    this.stdout.write(chalk(templateObject_28 || (templateObject_28 = __makeTemplateObject(["\n{red    [Stack]}: {yellow ", "}\n"], ["\\n{red    [Stack]}: {yellow ",
                        "}\\n"])), error.stackTrace
                        .split("\n")
                        .join("\n           ")));
                }
            }
            catch (e_20_1) { e_20 = { error: e_20_1 }; }
            finally {
                try {
                    if (_j && !_j.done && (_b = _h.return)) _b.call(_h);
                }
                finally { if (e_20) throw e_20.error; }
            }
            var diff = suite.snapshotDiff.results;
            var addedCount = 0;
            var removedCount = 0;
            var differentCount = 0;
            var totalCount = 0;
            try {
                for (var _k = __values(diff.entries()), _l = _k.next(); !_l.done; _l = _k.next()) {
                    var _m = __read(_l.value, 2), name_2 = _m[0], result_1 = _m[1];
                    if (result_1.type !== 0 /* NoChange */) {
                        this.stdout.write(chalk(templateObject_29 || (templateObject_29 = __makeTemplateObject(["{red [Snapshot]}: ", "\n"], ["{red [Snapshot]}: ", "\\n"])), name_2));
                        var changes = result_1.changes;
                        try {
                            for (var changes_2 = (e_22 = void 0, __values(changes)), changes_2_1 = changes_2.next(); !changes_2_1.done; changes_2_1 = changes_2.next()) {
                                var change = changes_2_1.value;
                                var lines = change.value.split("\n");
                                try {
                                    for (var lines_2 = (e_23 = void 0, __values(lines)), lines_2_1 = lines_2.next(); !lines_2_1.done; lines_2_1 = lines_2.next()) {
                                        var line = lines_2_1.value;
                                        if (!line.trim())
                                            continue;
                                        if (change.added) {
                                            this.stdout.write(chalk(templateObject_30 || (templateObject_30 = __makeTemplateObject(["{green + ", "}\n"], ["{green + ", "}\\n"])), line));
                                        }
                                        else if (change.removed) {
                                            this.stdout.write(chalk(templateObject_31 || (templateObject_31 = __makeTemplateObject(["{red - ", "}\n"], ["{red - ", "}\\n"])), line));
                                        }
                                        else {
                                            this.stdout.write(chalk(templateObject_32 || (templateObject_32 = __makeTemplateObject(["  ", "\n"], ["  ", "\\n"])), line));
                                        }
                                    }
                                }
                                catch (e_23_1) { e_23 = { error: e_23_1 }; }
                                finally {
                                    try {
                                        if (lines_2_1 && !lines_2_1.done && (_e = lines_2.return)) _e.call(lines_2);
                                    }
                                    finally { if (e_23) throw e_23.error; }
                                }
                            }
                        }
                        catch (e_22_1) { e_22 = { error: e_22_1 }; }
                        finally {
                            try {
                                if (changes_2_1 && !changes_2_1.done && (_d = changes_2.return)) _d.call(changes_2);
                            }
                            finally { if (e_22) throw e_22.error; }
                        }
                        this.stdout.write("\n");
                    }
                    totalCount += 1;
                    addedCount += result_1.type === 1 /* Added */ ? 1 : 0;
                    removedCount += result_1.type === 2 /* Removed */ ? 1 : 0;
                    differentCount +=
                        result_1.type === 3 /* Different */ ? 1 : 0;
                }
            }
            catch (e_21_1) { e_21 = { error: e_21_1 }; }
            finally {
                try {
                    if (_l && !_l.done && (_c = _k.return)) _c.call(_k);
                }
                finally { if (e_21) throw e_21.error; }
            }
            this.stdout.write(chalk(templateObject_33 || (templateObject_33 = __makeTemplateObject(["    [File]: ", "\n  [Groups]: {green ", " pass}, ", " total\n  [Result]: ", "\n[Snapshot]: ", " total, ", " added, ", " removed, ", " different\n [Summary]: {green ", " pass},  ", ", ", " total\n    [Time]: ", "ms\n\n", "\n\n"], ["    [File]: ", "\n  [Groups]: {green ", " pass}, ", " total\n  [Result]: ", "\n[Snapshot]: ", " total, ", " added, ", " removed, ", " different\n [Summary]: {green ", " pass},  ", ", ",
                " total\n    [Time]: ", "ms\n\n", "\\n\\n"])), suite.fileName, suite.groupCount, suite.groupCount, result, totalCount, addedCount, removedCount, differentCount, suite.testPassCount, failText, suite.testCount, suite.rootNode.deltaT, "~".repeat(80)));
        };
        /**
         * This method reports a todo to stdout.
         *
         * @param {TestGroup} _group - The test group the todo belongs to.
         * @param {string} todo - The todo.
         */
        /* istanbul ignore next */
        VerboseReporter.prototype.onTodo = function (_group, todo) {
            /* istanbul ignore next */
            var chalk = require("chalk");
            /* istanbul ignore next */
            this.stdout.write(chalk(templateObject_34 || (templateObject_34 = __makeTemplateObject(["    {yellow [Todo]:} ", "\n"], ["    {yellow [Todo]:} ", "\\n"])), todo));
        };
        /**
         * A custom logger function for the default reporter that writes the log values using `console.log()`
         *
         * @param {ReflectedValue} logValue - A value to be logged to the console
         */
        VerboseReporter.prototype.onLog = function (logValue) {
            var chalk = require("chalk");
            var indent12 = Object.assign({}, this.stringifyProperties, {
                indent: 12,
            });
            var output = logValue.stringify(indent12).trimLeft();
            this.stdout.write(chalk(templateObject_35 || (templateObject_35 = __makeTemplateObject(["     {yellow [Log]:} ", "\n"], ["     {yellow [Log]:} ", "\\n"])), output));
            var stack = logValue.stack.trim();
            /* istanbul ignore next */
            if (stack) {
                this.stdout.write(chalk(templateObject_36 || (templateObject_36 = __makeTemplateObject(["   {yellow [Stack]:} ", "\n"], ["   {yellow [Stack]:} ",
                    "\\n"])), stack
                    .trimLeft()
                    .split("\n")
                    .join("\n        ")));
            }
        };
        return VerboseReporter;
    }());
    exports.VerboseReporter = VerboseReporter;
    var templateObject_16, templateObject_17, templateObject_18, templateObject_19, templateObject_20, templateObject_21, templateObject_22, templateObject_23, templateObject_24, templateObject_25, templateObject_26, templateObject_27, templateObject_28, templateObject_29, templateObject_30, templateObject_31, templateObject_32, templateObject_33, templateObject_34, templateObject_35, templateObject_36;
});
define("index", ["require", "exports", "reporter/CombinationReporter", "reporter/EmptyReporter", "reporter/IReporter", "reporter/SummaryReporter", "reporter/VerboseReporter", "test/IWarning", "test/TestContext", "test/TestNode", "util/IAspectExports", "util/ReflectedValue", "util/TestNodeType"], function (require, exports, CombinationReporter_1, EmptyReporter_1, IReporter_1, SummaryReporter_1, VerboseReporter_1, IWarning_1, TestContext_1, TestNode_2, IAspectExports_1, ReflectedValue_2, TestNodeType_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    __exportStar(CombinationReporter_1, exports);
    __exportStar(EmptyReporter_1, exports);
    __exportStar(IReporter_1, exports);
    __exportStar(SummaryReporter_1, exports);
    __exportStar(VerboseReporter_1, exports);
    __exportStar(IWarning_1, exports);
    __exportStar(TestContext_1, exports);
    __exportStar(TestNode_2, exports);
    __exportStar(IAspectExports_1, exports);
    __exportStar(ReflectedValue_2, exports);
    __exportStar(TestNodeType_1, exports);
});
//@ts-ignore
var path = require("path");
//@ts-ignore
var assemblyscriptPath = Object.getOwnPropertyNames(require.cache).filter(function (s) { return s.endsWith("assemblyscript.js"); })[0];
var transformerPath;
if (assemblyscriptPath) {
    var splitPath = assemblyscriptPath.split(path.sep).slice(0, -2);
    transformerPath = splitPath.concat(["cli", "transform"]).join(path.sep);
}
else {
    assemblyscriptPath = require.resolve("assemblyscript");
    transformerPath = require.resolve("assemblyscript/cli/transform");
}
//@ts-ignore
module.exports.Transform = require(transformerPath).Transform;
module.exports = __assign(__assign({}, module.exports), require(assemblyscriptPath));
define("transform/createGenericTypeParameter", ["require", "exports", "./assemblyscript"], function (require, exports, assemblyscript_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.createGenericTypeParameter = void 0;
    /**
     * This method makes a generic named parameter.
     *
     * @param {string} name - The name of the type.
     * @param {Range} range - The range given for the type parameter.
     */
    function createGenericTypeParameter(name, range) {
        return assemblyscript_1.TypeNode.createNamedType(assemblyscript_1.TypeNode.createSimpleTypeName(name, range), null, false, range);
    }
    exports.createGenericTypeParameter = createGenericTypeParameter;
});
define("transform/hash", ["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.djb2Hash = void 0;
    /**
     * A simple djb2hash that returns a hash of a given string. See http://www.cse.yorku.ca/~oz/hash.html
     * for implementation details.
     *
     * @param {string} str - The string to be hashed
     * @returns {number} The hash of the string
     */
    function djb2Hash(str) {
        var points = Array.from(str);
        var h = 5381;
        for (var p = 0; p < points.length; p++)
            // h = h * 33 + c;
            h = (h << 5) + h + points[p].codePointAt(0);
        return h;
    }
    exports.djb2Hash = djb2Hash;
});
define("transform/createAddReflectedValueKeyValuePairsMember", ["require", "exports", "./assemblyscript", "transform/createGenericTypeParameter", "transform/hash"], function (require, exports, assemblyscript_2, createGenericTypeParameter_1, hash_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.createAddReflectedValueKeyValuePairsMember = void 0;
    /**
     * Create a prototype method called __aspectAddReflectedValueKeyValuePairs on a given
     * ClassDeclaration dynamically.
     *
     * @param {ClassDeclaration} classDeclaration - The target classDeclaration
     */
    function createAddReflectedValueKeyValuePairsMember(classDeclaration) {
        var range = classDeclaration.name.range;
        // __aspectAddReflectedValueKeyValuePairs(reflectedValue: i32, seen: Map<usize, i32>, ignore: StaticArray<i64>): void
        return assemblyscript_2.TypeNode.createMethodDeclaration(assemblyscript_2.TypeNode.createIdentifierExpression("__aspectAddReflectedValueKeyValuePairs", range), null, assemblyscript_2.CommonFlags.PUBLIC |
            assemblyscript_2.CommonFlags.INSTANCE |
            (classDeclaration.isGeneric ? assemblyscript_2.CommonFlags.GENERIC_CONTEXT : 0), null, assemblyscript_2.TypeNode.createFunctionType([
            // reflectedValue: i32
            assemblyscript_2.TypeNode.createParameter(assemblyscript_2.ParameterKind.DEFAULT, assemblyscript_2.TypeNode.createIdentifierExpression("reflectedValue", range), createGenericTypeParameter_1.createGenericTypeParameter("i32", range), null, range),
            // seen: Map<usize, i32>
            assemblyscript_2.TypeNode.createParameter(assemblyscript_2.ParameterKind.DEFAULT, assemblyscript_2.TypeNode.createIdentifierExpression("seen", range), assemblyscript_2.TypeNode.createNamedType(assemblyscript_2.TypeNode.createSimpleTypeName("Map", range), [
                createGenericTypeParameter_1.createGenericTypeParameter("usize", range),
                createGenericTypeParameter_1.createGenericTypeParameter("i32", range),
            ], false, range), null, range),
            // ignore: i64[]
            assemblyscript_2.TypeNode.createParameter(assemblyscript_2.ParameterKind.DEFAULT, assemblyscript_2.TypeNode.createIdentifierExpression("ignore", range), 
            // Array<i64> -> i64[]
            assemblyscript_2.TypeNode.createNamedType(assemblyscript_2.TypeNode.createSimpleTypeName("StaticArray", range), [createGenericTypeParameter_1.createGenericTypeParameter("i64", range)], false, range), null, range),
        ], 
        // : void
        assemblyscript_2.TypeNode.createNamedType(assemblyscript_2.TypeNode.createSimpleTypeName("void", range), [], false, range), null, false, range), createAddReflectedValueKeyValuePairsFunctionBody(classDeclaration), range);
    }
    exports.createAddReflectedValueKeyValuePairsMember = createAddReflectedValueKeyValuePairsMember;
    /**
     * Iterate over a given ClassDeclaration and return a block statement that contains the
     * body of a supposed function that reports the key value pairs of a given class.
     *
     * @param {ClassDeclaration} classDeclaration - The class declaration to be reported
     */
    function createAddReflectedValueKeyValuePairsFunctionBody(classDeclaration) {
        var e_24, _a;
        var body = new Array();
        var range = classDeclaration.name.range;
        var nameHashes = new Array();
        try {
            // for each field declaration, generate a check
            for (var _b = __values(classDeclaration.members), _c = _b.next(); !_c.done; _c = _b.next()) {
                var member = _c.value;
                // if it's an instance member, regardless of access modifier
                if (member.is(assemblyscript_2.CommonFlags.INSTANCE)) {
                    switch (member.kind) {
                        // field declarations automatically get added
                        case assemblyscript_2.NodeKind.FIELDDECLARATION: {
                            var fieldDeclaration = member;
                            var hashValue = hash_1.djb2Hash(member.name.text);
                            pushKeyValueIfStatement(body, member.name.text, hashValue, fieldDeclaration.range);
                            nameHashes.push(hashValue);
                            break;
                        }
                        // function declarations can be getters, check the get flag
                        case assemblyscript_2.NodeKind.METHODDECLARATION: {
                            if (member.is(assemblyscript_2.CommonFlags.GET)) {
                                var methodDeclaration = member;
                                var hashValue = hash_1.djb2Hash(member.name.text);
                                pushKeyValueIfStatement(body, member.name.text, hashValue, methodDeclaration.range);
                                nameHashes.push(hashValue);
                            }
                            break;
                        }
                    }
                }
            }
        }
        catch (e_24_1) { e_24 = { error: e_24_1 }; }
        finally {
            try {
                if (_c && !_c.done && (_a = _b.return)) _a.call(_b);
            }
            finally { if (e_24) throw e_24.error; }
        }
        // call into super first after all the property checks have been added
        body.unshift(createIsDefinedIfStatement(nameHashes, range));
        return assemblyscript_2.TypeNode.createBlockStatement(body, range);
    }
    /**
     * Create an isDefined() function call with an if statement to prevent calls to
     * super where they should not be made.
     *
     * @param {number[]} nameHashes - The array of property names to ignore in the children
     * @param {Range} range - The reporting range of this statement
     */
    function createIsDefinedIfStatement(nameHashes, range) {
        // if (isDefined(super.__aspectAddReflectedValueKeyValuePairs))
        //   super.__aspectAddReflectedValueKeyValuePairs(reflectedValue, seen, StaticArray.concat(ignore, [...] as StaticArray<i64>))
        return assemblyscript_2.TypeNode.createIfStatement(
        // isDefined(super.__aspectAddReflectedValueKeyValuePairs)
        assemblyscript_2.TypeNode.createCallExpression(assemblyscript_2.TypeNode.createIdentifierExpression("isDefined", range), null, [
            // super.__aspectAddReflectedValueKeyValuePairs
            assemblyscript_2.TypeNode.createPropertyAccessExpression(assemblyscript_2.TypeNode.createSuperExpression(range), assemblyscript_2.TypeNode.createIdentifierExpression("__aspectAddReflectedValueKeyValuePairs", range), range),
        ], range), assemblyscript_2.TypeNode.createBlockStatement([
            assemblyscript_2.TypeNode.createExpressionStatement(
            // super.__aspectAddReflectedValueKeyValuePairs(reflectedValue, seen, StaticArray.concat(ignore, [...] as StaticArray<i64>))
            assemblyscript_2.TypeNode.createCallExpression(assemblyscript_2.TypeNode.createPropertyAccessExpression(assemblyscript_2.TypeNode.createSuperExpression(range), assemblyscript_2.TypeNode.createIdentifierExpression("__aspectAddReflectedValueKeyValuePairs", range), range), null, [
                // reflectedValue,
                assemblyscript_2.TypeNode.createIdentifierExpression("reflectedValue", range),
                // seen,
                assemblyscript_2.TypeNode.createIdentifierExpression("seen", range),
                // StaticArray.concat(ignore, [...])
                assemblyscript_2.TypeNode.createCallExpression(assemblyscript_2.TypeNode.createPropertyAccessExpression(assemblyscript_2.TypeNode.createIdentifierExpression("StaticArray", range), assemblyscript_2.TypeNode.createIdentifierExpression("concat", range), range), null, [
                    assemblyscript_2.TypeNode.createIdentifierExpression("ignore", range),
                    // [...propNames]
                    assemblyscript_2.TypeNode.createAssertionExpression(assemblyscript_2.AssertionKind.AS, assemblyscript_2.TypeNode.createArrayLiteralExpression(nameHashes.map(function (e) {
                        return assemblyscript_2.TypeNode.createIntegerLiteralExpression(f64_as_i64(e), range);
                    }), range), assemblyscript_2.TypeNode.createNamedType(assemblyscript_2.TypeNode.createSimpleTypeName("StaticArray", range), [
                        assemblyscript_2.TypeNode.createNamedType(assemblyscript_2.TypeNode.createSimpleTypeName("i64", range), null, false, range),
                    ], false, range), range),
                ], range),
            ], range)),
        ], range), null, range);
    }
    /**
     * For each key-value pair, we need to perform a runtime check to make sure that this property
     * was not overridden in the parent of a given class.
     *
     * @param {Statement[]} body - The collection of statements for the function body
     * @param {string} name - The name of the property
     * @param {Range} range - The range for these statements
     */
    function pushKeyValueIfStatement(body, name, hashValue, range) {
        body.push(
        // if (!ignore.includes("propName")) { ... }
        assemblyscript_2.TypeNode.createIfStatement(assemblyscript_2.TypeNode.createUnaryPrefixExpression(assemblyscript_2.Token.EXCLAMATION, 
        // ignore.includes("propName")
        assemblyscript_2.TypeNode.createCallExpression(assemblyscript_2.TypeNode.createPropertyAccessExpression(assemblyscript_2.TypeNode.createIdentifierExpression("ignore", range), assemblyscript_2.TypeNode.createIdentifierExpression("includes", range), range), null, [
            // hashValue
            assemblyscript_2.TypeNode.createIntegerLiteralExpression(f64_as_i64(hashValue), range),
        ], range), range), assemblyscript_2.TypeNode.createBlockStatement([
            createPushReflectedObjectKeyStatement(name, range),
            createPushReflectedObjectValueStatement(name, range),
        ], range), null, range));
    }
    /**
     * Create a function call to __aspectPushReflectedObjectKey to add a key to a given
     * reflected value.
     *
     * @param {string} name - The name of the property
     * @param {Range} range - The reange for this function call
     */
    function createPushReflectedObjectKeyStatement(name, range) {
        // __aspectPushReflectedObjectKey(reflectedValue, Reflect.toReflectedValue("propertyName", seen));
        return assemblyscript_2.TypeNode.createExpressionStatement(assemblyscript_2.TypeNode.createCallExpression(assemblyscript_2.TypeNode.createIdentifierExpression("__aspectPushReflectedObjectKey", range), null, [
            // reflectedValue
            assemblyscript_2.TypeNode.createIdentifierExpression("reflectedValue", range),
            // Reflect.toReflectedValue("propertyName", seen)
            assemblyscript_2.TypeNode.createCallExpression(
            // Reflect.toReflectedValue
            assemblyscript_2.TypeNode.createPropertyAccessExpression(assemblyscript_2.TypeNode.createIdentifierExpression("Reflect", range), assemblyscript_2.TypeNode.createIdentifierExpression("toReflectedValue", range), range), null, [
                assemblyscript_2.TypeNode.createStringLiteralExpression(name, range),
                assemblyscript_2.TypeNode.createIdentifierExpression("seen", range),
            ], range),
        ], range));
    }
    /**
     * Create a function call to __aspectPushReflectedObjectValue to add a key to a given
     * reflected value.
     *
     * @param {string} name - The name of the property
     * @param {Range} range - The reange for this function call
     */
    function createPushReflectedObjectValueStatement(name, range) {
        // __aspectPushReflectedObjectValue(reflectedValue, Reflect.toReflectedValue(this.propertyName, seen, ignore.concat([...])));
        return assemblyscript_2.TypeNode.createExpressionStatement(
        // __aspectPushReflectedObjectValue(reflectedValue, Reflect.toReflectedValue(this.propertyName, seen, ignore.concat([...])))
        assemblyscript_2.TypeNode.createCallExpression(
        // __aspectPushReflectedObjectValue
        assemblyscript_2.TypeNode.createIdentifierExpression("__aspectPushReflectedObjectValue", range), null, [
            // reflectedValue
            assemblyscript_2.TypeNode.createIdentifierExpression("reflectedValue", range),
            // Reflect.toReflectedValue(this.propertyName, seen))
            assemblyscript_2.TypeNode.createCallExpression(
            // Reflect.toReflectedValue
            assemblyscript_2.TypeNode.createPropertyAccessExpression(assemblyscript_2.TypeNode.createIdentifierExpression("Reflect", range), assemblyscript_2.TypeNode.createIdentifierExpression("toReflectedValue", range), range), null, [
                //this.propertyName
                assemblyscript_2.TypeNode.createPropertyAccessExpression(assemblyscript_2.TypeNode.createThisExpression(range), assemblyscript_2.TypeNode.createIdentifierExpression(name, range), range),
                // seen
                assemblyscript_2.TypeNode.createIdentifierExpression("seen", range),
            ], range),
        ], range));
    }
});
define("transform/createStrictEqualsMember", ["require", "exports", "./assemblyscript", "transform/hash"], function (require, exports, assemblyscript_3, hash_2) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    exports.createStrictEqualsMember = void 0;
    /**
     * This method creates a single FunctionDeclaration that allows Reflect.equals
     * to validate normal class member values.
     *
     * @param {ClassDeclaration} classDeclaration - The class that requires a new function.
     */
    function createStrictEqualsMember(classDeclaration) {
        var range = classDeclaration.name.range;
        // __aspectStrictEquals(ref: T, stackA: usize[], stackB: usize[], ignore: StaticArray<i64>): bool
        return assemblyscript_3.TypeNode.createMethodDeclaration(assemblyscript_3.TypeNode.createIdentifierExpression("__aspectStrictEquals", range), null, assemblyscript_3.CommonFlags.PUBLIC |
            assemblyscript_3.CommonFlags.INSTANCE |
            (classDeclaration.isGeneric ? assemblyscript_3.CommonFlags.GENERIC_CONTEXT : 0), null, assemblyscript_3.TypeNode.createFunctionType([
            // ref: T,
            createDefaultParameter("ref", assemblyscript_3.TypeNode.createNamedType(assemblyscript_3.TypeNode.createSimpleTypeName(classDeclaration.name.text, range), classDeclaration.isGeneric
                ? classDeclaration.typeParameters.map(function (node) {
                    return assemblyscript_3.TypeNode.createNamedType(assemblyscript_3.TypeNode.createSimpleTypeName(node.name.text, range), null, false, range);
                })
                : null, false, range), 
            //createGenericTypeParameter("this", range),
            range),
            // stack: usize[]
            createDefaultParameter("stack", createArrayType("usize", range), range),
            // cache: usize[]
            createDefaultParameter("cache", createArrayType("usize", range), range),
            // ignore: StaticArray<i64>
            createDefaultParameter("ignore", assemblyscript_3.TypeNode.createNamedType(assemblyscript_3.TypeNode.createSimpleTypeName("StaticArray", range), [
                assemblyscript_3.TypeNode.createNamedType(assemblyscript_3.TypeNode.createSimpleTypeName("i64", range), null, false, range),
            ], false, range), range),
        ], 
        // : bool
        createSimpleNamedType("bool", range), null, false, range), createStrictEqualsFunctionBody(classDeclaration), range);
    }
    exports.createStrictEqualsMember = createStrictEqualsMember;
    /**
     * This method creates a simple name type with the given name and source range.
     *
     * @param {string} name - The name of the type.
     * @param {Range} range - The given source range.
     */
    function createSimpleNamedType(name, range) {
        return assemblyscript_3.TypeNode.createNamedType(assemblyscript_3.TypeNode.createSimpleTypeName(name, range), null, false, range);
    }
    /**
     * This method creates an Array<name> type with the given range.
     *
     * @param {Range} range - The source range.
     */
    function createArrayType(name, range) {
        return assemblyscript_3.TypeNode.createNamedType(assemblyscript_3.TypeNode.createSimpleTypeName("Array", range), [
            assemblyscript_3.TypeNode.createNamedType(assemblyscript_3.TypeNode.createSimpleTypeName(name, range), null, false, range),
        ], false, range);
    }
    /**
     * This method creates the entire function body for __aspectStrictEquals.
     *
     * @param {ClassDeclaration} classDeclaration - The class declaration.
     */
    function createStrictEqualsFunctionBody(classDeclaration) {
        var e_25, _a;
        var body = new Array();
        var range = classDeclaration.name.range;
        var nameHashes = new Array();
        try {
            // for each field declaration, generate a check
            for (var _b = __values(classDeclaration.members), _c = _b.next(); !_c.done; _c = _b.next()) {
                var member = _c.value;
                // if it's an instance member, regardless of access modifier
                if (member.is(assemblyscript_3.CommonFlags.INSTANCE)) {
                    switch (member.kind) {
                        // field declarations automatically get added
                        case assemblyscript_3.NodeKind.FIELDDECLARATION: {
                            var fieldDeclaration = member;
                            var hashValue = hash_2.djb2Hash(member.name.text);
                            body.push(createStrictEqualsIfCheck(member.name.text, hashValue, fieldDeclaration.range));
                            nameHashes.push(hashValue);
                            break;
                        }
                        // function declarations can be getters, check the get flag
                        case assemblyscript_3.NodeKind.METHODDECLARATION: {
                            if (member.is(assemblyscript_3.CommonFlags.GET)) {
                                var methodDeclaration = member;
                                var hashValue = hash_2.djb2Hash(member.name.text);
                                body.push(createStrictEqualsIfCheck(methodDeclaration.name.text, hashValue, methodDeclaration.name.range));
                                nameHashes.push(hashValue);
                            }
                            break;
                        }
                    }
                }
            }
        }
        catch (e_25_1) { e_25 = { error: e_25_1 }; }
        finally {
            try {
                if (_c && !_c.done && (_a = _b.return)) _a.call(_b);
            }
            finally { if (e_25) throw e_25.error; }
        }
        // if (isDefined(...)) super.__aspectStrictEquals(ref, stack, cache, ignore.concat([...props]));
        body.push(createSuperCallStatement(classDeclaration, nameHashes));
        // return true;
        body.push(assemblyscript_3.TypeNode.createReturnStatement(assemblyscript_3.TypeNode.createTrueExpression(range), range));
        return assemblyscript_3.TypeNode.createBlockStatement(body, range);
    }
    /**
     * This function generates a single IfStatement with a nested ReturnStatement
     * to validate a nested property on a given class.
     *
     * @param {string} name - The name of the property.
     * @param {Range} range - The source range for the given property.
     */
    function createStrictEqualsIfCheck(name, hashValue, range) {
        var equalsCheck = assemblyscript_3.TypeNode.createBinaryExpression(assemblyscript_3.Token.EQUALS_EQUALS, 
        // Reflect.equals(this.prop, ref.prop, stack, cache)
        assemblyscript_3.TypeNode.createCallExpression(
        // Reflect.equals
        createPropertyAccess("Reflect", "equals", range), null, // types can be inferred by the compiler!
        // arguments
        [
            // this.prop
            assemblyscript_3.TypeNode.createPropertyAccessExpression(assemblyscript_3.TypeNode.createThisExpression(range), assemblyscript_3.TypeNode.createIdentifierExpression(name, range), range),
            // ref.prop
            createPropertyAccess("ref", name, range),
            // stack
            assemblyscript_3.TypeNode.createIdentifierExpression("stack", range),
            // cache
            assemblyscript_3.TypeNode.createIdentifierExpression("cache", range),
        ], range), createPropertyAccess("Reflect", "FAILED_MATCH", range), range);
        // !ignore.includes("prop")
        var includesCheck = assemblyscript_3.TypeNode.createUnaryPrefixExpression(assemblyscript_3.Token.EXCLAMATION, 
        // ignore.includes("prop")
        assemblyscript_3.TypeNode.createCallExpression(
        // ignore.includes
        assemblyscript_3.TypeNode.createPropertyAccessExpression(assemblyscript_3.TypeNode.createIdentifierExpression("ignore", range), assemblyscript_3.TypeNode.createIdentifierExpression("includes", range), range), null, 
        // (nameHash)
        [assemblyscript_3.TypeNode.createIntegerLiteralExpression(f64_as_i64(hashValue), range)], range), range);
        // if (Reflect.equals(this.prop, ref.prop, stack, cache) === Reflect.FAILED_MATCH) return false;
        return assemblyscript_3.TypeNode.createIfStatement(
        // Reflect.equals(this.prop, ref.prop, stack, cache) === Reflect.FAILED_MATCH
        assemblyscript_3.TypeNode.createBinaryExpression(assemblyscript_3.Token.AMPERSAND_AMPERSAND, includesCheck, equalsCheck, range), 
        // return false;
        assemblyscript_3.TypeNode.createReturnStatement(assemblyscript_3.TypeNode.createFalseExpression(range), range), null, range);
    }
    /**
     * Create a simple default parameter with a name and a type.
     *
     * @param {string} name - The name of the parameter.
     * @param {TypeNode} typeNode - The type of the parameter.
     * @param {Range} range - The source range of the parameter.
     */
    function createDefaultParameter(name, typeNode, range) {
        return assemblyscript_3.TypeNode.createParameter(assemblyscript_3.ParameterKind.DEFAULT, assemblyscript_3.TypeNode.createIdentifierExpression(name, range), typeNode, null, range);
    }
    /**
     * This method creates a single property access and passes the given range to the AST.
     *
     * @param {string} root - The name of the identifier representing the root.
     * @param {string} property - The name of the identifier representing the property.
     * @param {Range} range - The range of the property access.
     */
    function createPropertyAccess(root, property, range) {
        // root.property
        return assemblyscript_3.TypeNode.createPropertyAccessExpression(assemblyscript_3.TypeNode.createIdentifierExpression(root, range), assemblyscript_3.TypeNode.createIdentifierExpression(property, range), range);
    }
    /**
     * This method creates the function call into super.__aspectStrictEquals,
     * wrapping it in a check to make sure the super function is defined first.
     *
     * @param {ClassDeclaration} classDeclaration - The given class declaration.
     * @param {number[]} nameHashes - A collection of hash values of the comparing class properties.
     */
    function createSuperCallStatement(classDeclaration, nameHashes) {
        var range = classDeclaration.name.range;
        var ifStatement = assemblyscript_3.TypeNode.createIfStatement(assemblyscript_3.TypeNode.createCallExpression(assemblyscript_3.TypeNode.createIdentifierExpression("isDefined", range), null, [
            assemblyscript_3.TypeNode.createPropertyAccessExpression(assemblyscript_3.TypeNode.createSuperExpression(range), assemblyscript_3.TypeNode.createIdentifierExpression("__aspectStrictEquals", range), range),
        ], range), assemblyscript_3.TypeNode.createBlockStatement([
            assemblyscript_3.TypeNode.createIfStatement(assemblyscript_3.TypeNode.createUnaryPrefixExpression(assemblyscript_3.Token.EXCLAMATION, createSuperCallExpression(nameHashes, range), range), assemblyscript_3.TypeNode.createReturnStatement(assemblyscript_3.TypeNode.createFalseExpression(range), range), null, range),
        ], range), null, range);
        return ifStatement;
    }
    /**
     * This method actually creates the super.__aspectStrictEquals function call.
     *
     * @param {number[]} hashValues - The collection of hashed property name values
     * @param {Range} range - The super call expression range
     */
    function createSuperCallExpression(hashValues, range) {
        return assemblyscript_3.TypeNode.createCallExpression(assemblyscript_3.TypeNode.createPropertyAccessExpression(assemblyscript_3.TypeNode.createSuperExpression(range), assemblyscript_3.TypeNode.createIdentifierExpression("__aspectStrictEquals", range), range), null, [
            assemblyscript_3.TypeNode.createIdentifierExpression("ref", range),
            assemblyscript_3.TypeNode.createIdentifierExpression("stack", range),
            assemblyscript_3.TypeNode.createIdentifierExpression("cache", range),
            // StaticArray.concat(ignore, [... props] as StaticArray<i64>)
            assemblyscript_3.TypeNode.createCallExpression(assemblyscript_3.TypeNode.createPropertyAccessExpression(assemblyscript_3.TypeNode.createIdentifierExpression("StaticArray", range), assemblyscript_3.TypeNode.createIdentifierExpression("concat", range), range), null, [
                assemblyscript_3.TypeNode.createIdentifierExpression("ignore", range),
                // [...] as StaticArray<i64>
                assemblyscript_3.TypeNode.createAssertionExpression(assemblyscript_3.AssertionKind.AS, assemblyscript_3.TypeNode.createArrayLiteralExpression(hashValues.map(function (e) {
                    return assemblyscript_3.TypeNode.createIntegerLiteralExpression(f64_as_i64(e), range);
                }), range), assemblyscript_3.TypeNode.createNamedType(assemblyscript_3.TypeNode.createSimpleTypeName("StaticArray", range), [
                    assemblyscript_3.TypeNode.createNamedType(assemblyscript_3.TypeNode.createSimpleTypeName("i64", range), null, false, range),
                ], false, range), range),
            ], range),
        ], range);
    }
});
define("transform/emptyTransformer", ["require", "exports", "./assemblyscript"], function (require, exports, assemblyscript_4) {
    "use strict";
    return /** @class */ (function (_super) {
        __extends(AspectTransform, _super);
        function AspectTransform() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        AspectTransform.prototype.afterParse = function (_parser) { };
        return AspectTransform;
    }(assemblyscript_4.Transform));
});
define("transform/index", ["require", "exports", "./assemblyscript", "transform/createStrictEqualsMember", "transform/createAddReflectedValueKeyValuePairsMember"], function (require, exports, assemblyscript_5, createStrictEqualsMember_1, createAddReflectedValueKeyValuePairsMember_1) {
    "use strict";
    function traverseStatements(statements) {
        var e_26, _a;
        try {
            // for each statement in the source
            for (var statements_1 = __values(statements), statements_1_1 = statements_1.next(); !statements_1_1.done; statements_1_1 = statements_1.next()) {
                var statement = statements_1_1.value;
                // find each class declaration
                if (statement.kind === assemblyscript_5.NodeKind.CLASSDECLARATION) {
                    // cast and create a strictEquals function
                    var classDeclaration = statement;
                    classDeclaration.members.push(createStrictEqualsMember_1.createStrictEqualsMember(classDeclaration));
                    classDeclaration.members.push(createAddReflectedValueKeyValuePairsMember_1.createAddReflectedValueKeyValuePairsMember(classDeclaration));
                }
                else if (statement.kind === assemblyscript_5.NodeKind.NAMESPACEDECLARATION) {
                    var namespaceDeclaration = statement;
                    traverseStatements(namespaceDeclaration.members);
                }
            }
        }
        catch (e_26_1) { e_26 = { error: e_26_1 }; }
        finally {
            try {
                if (statements_1_1 && !statements_1_1.done && (_a = statements_1.return)) _a.call(statements_1);
            }
            finally { if (e_26) throw e_26.error; }
        }
    }
    return /** @class */ (function (_super) {
        __extends(AspectTransform, _super);
        function AspectTransform() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        /**
         * This method results in a pure AST transform that inserts a strictEquals member
         * into each ClassDeclaration.
         *
         * @param {Parser} parser - The AssemblyScript parser.
         */
        AspectTransform.prototype.afterParse = function (parser) {
            var e_27, _a;
            // For backwards compatibility
            var sources = parser.program
                ? parser.program.sources
                : parser.sources;
            try {
                // for each program source
                for (var sources_1 = __values(sources), sources_1_1 = sources_1.next(); !sources_1_1.done; sources_1_1 = sources_1.next()) {
                    var source = sources_1_1.value;
                    traverseStatements(source.statements);
                }
            }
            catch (e_27_1) { e_27 = { error: e_27_1 }; }
            finally {
                try {
                    if (sources_1_1 && !sources_1_1.done && (_a = sources_1.return)) _a.call(sources_1);
                }
                finally { if (e_27) throw e_27.error; }
            }
        };
        return AspectTransform;
    }(assemblyscript_5.Transform));
});
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
        var e_28, _a;
        if (this.oninfo) {
            try {
                for (var _b = __values(this.blocks), _c = _b.next(); !_c.done; _c = _b.next()) {
                    var _d = __read(_c.value, 2), ptr = _d[0], info = _d[1];
                    this.oninfo("LIVE " + ptr + "\n" + info.allocStack.join("\n"));
                }
            }
            catch (e_28_1) { e_28 = { error: e_28_1 }; }
            finally {
                try {
                    if (_c && !_c.done && (_a = _b.return)) _a.call(_b);
                }
                finally { if (e_28) throw e_28.error; }
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
//# sourceMappingURL=as-pect.core.amd.js.map