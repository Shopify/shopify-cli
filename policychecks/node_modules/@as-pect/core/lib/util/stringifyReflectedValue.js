"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.stringifyReflectedValue = void 0;
var chalk_1 = __importDefault(require("chalk"));
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
//# sourceMappingURL=stringifyReflectedValue.js.map