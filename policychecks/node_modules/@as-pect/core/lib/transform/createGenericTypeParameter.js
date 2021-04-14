"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createGenericTypeParameter = void 0;
var assemblyscript_1 = require("./assemblyscript");
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
//# sourceMappingURL=createGenericTypeParameter.js.map