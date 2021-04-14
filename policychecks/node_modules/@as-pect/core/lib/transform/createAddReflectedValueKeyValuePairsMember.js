"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.createAddReflectedValueKeyValuePairsMember = void 0;
var assemblyscript_1 = require("./assemblyscript");
var createGenericTypeParameter_1 = require("./createGenericTypeParameter");
var hash_1 = require("./hash");
/**
 * Create a prototype method called __aspectAddReflectedValueKeyValuePairs on a given
 * ClassDeclaration dynamically.
 *
 * @param {ClassDeclaration} classDeclaration - The target classDeclaration
 */
function createAddReflectedValueKeyValuePairsMember(classDeclaration) {
    var range = classDeclaration.name.range;
    // __aspectAddReflectedValueKeyValuePairs(reflectedValue: i32, seen: Map<usize, i32>, ignore: StaticArray<i64>): void
    return assemblyscript_1.TypeNode.createMethodDeclaration(assemblyscript_1.TypeNode.createIdentifierExpression("__aspectAddReflectedValueKeyValuePairs", range), null, assemblyscript_1.CommonFlags.PUBLIC |
        assemblyscript_1.CommonFlags.INSTANCE |
        (classDeclaration.isGeneric ? assemblyscript_1.CommonFlags.GENERIC_CONTEXT : 0), null, assemblyscript_1.TypeNode.createFunctionType([
        // reflectedValue: i32
        assemblyscript_1.TypeNode.createParameter(assemblyscript_1.ParameterKind.DEFAULT, assemblyscript_1.TypeNode.createIdentifierExpression("reflectedValue", range), createGenericTypeParameter_1.createGenericTypeParameter("i32", range), null, range),
        // seen: Map<usize, i32>
        assemblyscript_1.TypeNode.createParameter(assemblyscript_1.ParameterKind.DEFAULT, assemblyscript_1.TypeNode.createIdentifierExpression("seen", range), assemblyscript_1.TypeNode.createNamedType(assemblyscript_1.TypeNode.createSimpleTypeName("Map", range), [
            createGenericTypeParameter_1.createGenericTypeParameter("usize", range),
            createGenericTypeParameter_1.createGenericTypeParameter("i32", range),
        ], false, range), null, range),
        // ignore: i64[]
        assemblyscript_1.TypeNode.createParameter(assemblyscript_1.ParameterKind.DEFAULT, assemblyscript_1.TypeNode.createIdentifierExpression("ignore", range), 
        // Array<i64> -> i64[]
        assemblyscript_1.TypeNode.createNamedType(assemblyscript_1.TypeNode.createSimpleTypeName("StaticArray", range), [createGenericTypeParameter_1.createGenericTypeParameter("i64", range)], false, range), null, range),
    ], 
    // : void
    assemblyscript_1.TypeNode.createNamedType(assemblyscript_1.TypeNode.createSimpleTypeName("void", range), [], false, range), null, false, range), createAddReflectedValueKeyValuePairsFunctionBody(classDeclaration), range);
}
exports.createAddReflectedValueKeyValuePairsMember = createAddReflectedValueKeyValuePairsMember;
/**
 * Iterate over a given ClassDeclaration and return a block statement that contains the
 * body of a supposed function that reports the key value pairs of a given class.
 *
 * @param {ClassDeclaration} classDeclaration - The class declaration to be reported
 */
function createAddReflectedValueKeyValuePairsFunctionBody(classDeclaration) {
    var e_1, _a;
    var body = new Array();
    var range = classDeclaration.name.range;
    var nameHashes = new Array();
    try {
        // for each field declaration, generate a check
        for (var _b = __values(classDeclaration.members), _c = _b.next(); !_c.done; _c = _b.next()) {
            var member = _c.value;
            // if it's an instance member, regardless of access modifier
            if (member.is(assemblyscript_1.CommonFlags.INSTANCE)) {
                switch (member.kind) {
                    // field declarations automatically get added
                    case assemblyscript_1.NodeKind.FIELDDECLARATION: {
                        var fieldDeclaration = member;
                        var hashValue = hash_1.djb2Hash(member.name.text);
                        pushKeyValueIfStatement(body, member.name.text, hashValue, fieldDeclaration.range);
                        nameHashes.push(hashValue);
                        break;
                    }
                    // function declarations can be getters, check the get flag
                    case assemblyscript_1.NodeKind.METHODDECLARATION: {
                        if (member.is(assemblyscript_1.CommonFlags.GET)) {
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
    catch (e_1_1) { e_1 = { error: e_1_1 }; }
    finally {
        try {
            if (_c && !_c.done && (_a = _b.return)) _a.call(_b);
        }
        finally { if (e_1) throw e_1.error; }
    }
    // call into super first after all the property checks have been added
    body.unshift(createIsDefinedIfStatement(nameHashes, range));
    return assemblyscript_1.TypeNode.createBlockStatement(body, range);
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
    return assemblyscript_1.TypeNode.createIfStatement(
    // isDefined(super.__aspectAddReflectedValueKeyValuePairs)
    assemblyscript_1.TypeNode.createCallExpression(assemblyscript_1.TypeNode.createIdentifierExpression("isDefined", range), null, [
        // super.__aspectAddReflectedValueKeyValuePairs
        assemblyscript_1.TypeNode.createPropertyAccessExpression(assemblyscript_1.TypeNode.createSuperExpression(range), assemblyscript_1.TypeNode.createIdentifierExpression("__aspectAddReflectedValueKeyValuePairs", range), range),
    ], range), assemblyscript_1.TypeNode.createBlockStatement([
        assemblyscript_1.TypeNode.createExpressionStatement(
        // super.__aspectAddReflectedValueKeyValuePairs(reflectedValue, seen, StaticArray.concat(ignore, [...] as StaticArray<i64>))
        assemblyscript_1.TypeNode.createCallExpression(assemblyscript_1.TypeNode.createPropertyAccessExpression(assemblyscript_1.TypeNode.createSuperExpression(range), assemblyscript_1.TypeNode.createIdentifierExpression("__aspectAddReflectedValueKeyValuePairs", range), range), null, [
            // reflectedValue,
            assemblyscript_1.TypeNode.createIdentifierExpression("reflectedValue", range),
            // seen,
            assemblyscript_1.TypeNode.createIdentifierExpression("seen", range),
            // StaticArray.concat(ignore, [...])
            assemblyscript_1.TypeNode.createCallExpression(assemblyscript_1.TypeNode.createPropertyAccessExpression(assemblyscript_1.TypeNode.createIdentifierExpression("StaticArray", range), assemblyscript_1.TypeNode.createIdentifierExpression("concat", range), range), null, [
                assemblyscript_1.TypeNode.createIdentifierExpression("ignore", range),
                // [...propNames]
                assemblyscript_1.TypeNode.createAssertionExpression(assemblyscript_1.AssertionKind.AS, assemblyscript_1.TypeNode.createArrayLiteralExpression(nameHashes.map(function (e) {
                    return assemblyscript_1.TypeNode.createIntegerLiteralExpression(f64_as_i64(e), range);
                }), range), assemblyscript_1.TypeNode.createNamedType(assemblyscript_1.TypeNode.createSimpleTypeName("StaticArray", range), [
                    assemblyscript_1.TypeNode.createNamedType(assemblyscript_1.TypeNode.createSimpleTypeName("i64", range), null, false, range),
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
    assemblyscript_1.TypeNode.createIfStatement(assemblyscript_1.TypeNode.createUnaryPrefixExpression(assemblyscript_1.Token.EXCLAMATION, 
    // ignore.includes("propName")
    assemblyscript_1.TypeNode.createCallExpression(assemblyscript_1.TypeNode.createPropertyAccessExpression(assemblyscript_1.TypeNode.createIdentifierExpression("ignore", range), assemblyscript_1.TypeNode.createIdentifierExpression("includes", range), range), null, [
        // hashValue
        assemblyscript_1.TypeNode.createIntegerLiteralExpression(f64_as_i64(hashValue), range),
    ], range), range), assemblyscript_1.TypeNode.createBlockStatement([
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
    return assemblyscript_1.TypeNode.createExpressionStatement(assemblyscript_1.TypeNode.createCallExpression(assemblyscript_1.TypeNode.createIdentifierExpression("__aspectPushReflectedObjectKey", range), null, [
        // reflectedValue
        assemblyscript_1.TypeNode.createIdentifierExpression("reflectedValue", range),
        // Reflect.toReflectedValue("propertyName", seen)
        assemblyscript_1.TypeNode.createCallExpression(
        // Reflect.toReflectedValue
        assemblyscript_1.TypeNode.createPropertyAccessExpression(assemblyscript_1.TypeNode.createIdentifierExpression("Reflect", range), assemblyscript_1.TypeNode.createIdentifierExpression("toReflectedValue", range), range), null, [
            assemblyscript_1.TypeNode.createStringLiteralExpression(name, range),
            assemblyscript_1.TypeNode.createIdentifierExpression("seen", range),
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
    return assemblyscript_1.TypeNode.createExpressionStatement(
    // __aspectPushReflectedObjectValue(reflectedValue, Reflect.toReflectedValue(this.propertyName, seen, ignore.concat([...])))
    assemblyscript_1.TypeNode.createCallExpression(
    // __aspectPushReflectedObjectValue
    assemblyscript_1.TypeNode.createIdentifierExpression("__aspectPushReflectedObjectValue", range), null, [
        // reflectedValue
        assemblyscript_1.TypeNode.createIdentifierExpression("reflectedValue", range),
        // Reflect.toReflectedValue(this.propertyName, seen))
        assemblyscript_1.TypeNode.createCallExpression(
        // Reflect.toReflectedValue
        assemblyscript_1.TypeNode.createPropertyAccessExpression(assemblyscript_1.TypeNode.createIdentifierExpression("Reflect", range), assemblyscript_1.TypeNode.createIdentifierExpression("toReflectedValue", range), range), null, [
            //this.propertyName
            assemblyscript_1.TypeNode.createPropertyAccessExpression(assemblyscript_1.TypeNode.createThisExpression(range), assemblyscript_1.TypeNode.createIdentifierExpression(name, range), range),
            // seen
            assemblyscript_1.TypeNode.createIdentifierExpression("seen", range),
        ], range),
    ], range));
}
//# sourceMappingURL=createAddReflectedValueKeyValuePairsMember.js.map