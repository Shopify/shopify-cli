"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ReflectedValue = void 0;
var stringifyReflectedValue_1 = require("./stringifyReflectedValue");
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
//# sourceMappingURL=ReflectedValue.js.map