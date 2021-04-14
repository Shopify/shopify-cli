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
exports.createStrictEqualsMember = void 0;
var assemblyscript_1 = require("./assemblyscript");
var hash_1 = require("./hash");
/**
 * This method creates a single FunctionDeclaration that allows Reflect.equals
 * to validate normal class member values.
 *
 * @param {ClassDeclaration} classDeclaration - The class that requires a new function.
 */
function createStrictEqualsMember(classDeclaration) {
    var range = classDeclaration.name.range;
    // __aspectStrictEquals(ref: T, stackA: usize[], stackB: usize[], ignore: StaticArray<i64>): bool
    return assemblyscript_1.TypeNode.createMethodDeclaration(assemblyscript_1.TypeNode.createIdentifierExpression("__aspectStrictEquals", range), null, assemblyscript_1.CommonFlags.PUBLIC |
        assemblyscript_1.CommonFlags.INSTANCE |
        (classDeclaration.isGeneric ? assemblyscript_1.CommonFlags.GENERIC_CONTEXT : 0), null, assemblyscript_1.TypeNode.createFunctionType([
        // ref: T,
        createDefaultParameter("ref", assemblyscript_1.TypeNode.createNamedType(assemblyscript_1.TypeNode.createSimpleTypeName(classDeclaration.name.text, range), classDeclaration.isGeneric
            ? classDeclaration.typeParameters.map(function (node) {
                return assemblyscript_1.TypeNode.createNamedType(assemblyscript_1.TypeNode.createSimpleTypeName(node.name.text, range), null, false, range);
            })
            : null, false, range), 
        //createGenericTypeParameter("this", range),
        range),
        // stack: usize[]
        createDefaultParameter("stack", createArrayType("usize", range), range),
        // cache: usize[]
        createDefaultParameter("cache", createArrayType("usize", range), range),
        // ignore: StaticArray<i64>
        createDefaultParameter("ignore", assemblyscript_1.TypeNode.createNamedType(assemblyscript_1.TypeNode.createSimpleTypeName("StaticArray", range), [
            assemblyscript_1.TypeNode.createNamedType(assemblyscript_1.TypeNode.createSimpleTypeName("i64", range), null, false, range),
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
    return assemblyscript_1.TypeNode.createNamedType(assemblyscript_1.TypeNode.createSimpleTypeName(name, range), null, false, range);
}
/**
 * This method creates an Array<name> type with the given range.
 *
 * @param {Range} range - The source range.
 */
function createArrayType(name, range) {
    return assemblyscript_1.TypeNode.createNamedType(assemblyscript_1.TypeNode.createSimpleTypeName("Array", range), [
        assemblyscript_1.TypeNode.createNamedType(assemblyscript_1.TypeNode.createSimpleTypeName(name, range), null, false, range),
    ], false, range);
}
/**
 * This method creates the entire function body for __aspectStrictEquals.
 *
 * @param {ClassDeclaration} classDeclaration - The class declaration.
 */
function createStrictEqualsFunctionBody(classDeclaration) {
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
                        body.push(createStrictEqualsIfCheck(member.name.text, hashValue, fieldDeclaration.range));
                        nameHashes.push(hashValue);
                        break;
                    }
                    // function declarations can be getters, check the get flag
                    case assemblyscript_1.NodeKind.METHODDECLARATION: {
                        if (member.is(assemblyscript_1.CommonFlags.GET)) {
                            var methodDeclaration = member;
                            var hashValue = hash_1.djb2Hash(member.name.text);
                            body.push(createStrictEqualsIfCheck(methodDeclaration.name.text, hashValue, methodDeclaration.name.range));
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
    // if (isDefined(...)) super.__aspectStrictEquals(ref, stack, cache, ignore.concat([...props]));
    body.push(createSuperCallStatement(classDeclaration, nameHashes));
    // return true;
    body.push(assemblyscript_1.TypeNode.createReturnStatement(assemblyscript_1.TypeNode.createTrueExpression(range), range));
    return assemblyscript_1.TypeNode.createBlockStatement(body, range);
}
/**
 * This function generates a single IfStatement with a nested ReturnStatement
 * to validate a nested property on a given class.
 *
 * @param {string} name - The name of the property.
 * @param {Range} range - The source range for the given property.
 */
function createStrictEqualsIfCheck(name, hashValue, range) {
    var equalsCheck = assemblyscript_1.TypeNode.createBinaryExpression(assemblyscript_1.Token.EQUALS_EQUALS, 
    // Reflect.equals(this.prop, ref.prop, stack, cache)
    assemblyscript_1.TypeNode.createCallExpression(
    // Reflect.equals
    createPropertyAccess("Reflect", "equals", range), null, // types can be inferred by the compiler!
    // arguments
    [
        // this.prop
        assemblyscript_1.TypeNode.createPropertyAccessExpression(assemblyscript_1.TypeNode.createThisExpression(range), assemblyscript_1.TypeNode.createIdentifierExpression(name, range), range),
        // ref.prop
        createPropertyAccess("ref", name, range),
        // stack
        assemblyscript_1.TypeNode.createIdentifierExpression("stack", range),
        // cache
        assemblyscript_1.TypeNode.createIdentifierExpression("cache", range),
    ], range), createPropertyAccess("Reflect", "FAILED_MATCH", range), range);
    // !ignore.includes("prop")
    var includesCheck = assemblyscript_1.TypeNode.createUnaryPrefixExpression(assemblyscript_1.Token.EXCLAMATION, 
    // ignore.includes("prop")
    assemblyscript_1.TypeNode.createCallExpression(
    // ignore.includes
    assemblyscript_1.TypeNode.createPropertyAccessExpression(assemblyscript_1.TypeNode.createIdentifierExpression("ignore", range), assemblyscript_1.TypeNode.createIdentifierExpression("includes", range), range), null, 
    // (nameHash)
    [assemblyscript_1.TypeNode.createIntegerLiteralExpression(f64_as_i64(hashValue), range)], range), range);
    // if (Reflect.equals(this.prop, ref.prop, stack, cache) === Reflect.FAILED_MATCH) return false;
    return assemblyscript_1.TypeNode.createIfStatement(
    // Reflect.equals(this.prop, ref.prop, stack, cache) === Reflect.FAILED_MATCH
    assemblyscript_1.TypeNode.createBinaryExpression(assemblyscript_1.Token.AMPERSAND_AMPERSAND, includesCheck, equalsCheck, range), 
    // return false;
    assemblyscript_1.TypeNode.createReturnStatement(assemblyscript_1.TypeNode.createFalseExpression(range), range), null, range);
}
/**
 * Create a simple default parameter with a name and a type.
 *
 * @param {string} name - The name of the parameter.
 * @param {TypeNode} typeNode - The type of the parameter.
 * @param {Range} range - The source range of the parameter.
 */
function createDefaultParameter(name, typeNode, range) {
    return assemblyscript_1.TypeNode.createParameter(assemblyscript_1.ParameterKind.DEFAULT, assemblyscript_1.TypeNode.createIdentifierExpression(name, range), typeNode, null, range);
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
    return assemblyscript_1.TypeNode.createPropertyAccessExpression(assemblyscript_1.TypeNode.createIdentifierExpression(root, range), assemblyscript_1.TypeNode.createIdentifierExpression(property, range), range);
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
    var ifStatement = assemblyscript_1.TypeNode.createIfStatement(assemblyscript_1.TypeNode.createCallExpression(assemblyscript_1.TypeNode.createIdentifierExpression("isDefined", range), null, [
        assemblyscript_1.TypeNode.createPropertyAccessExpression(assemblyscript_1.TypeNode.createSuperExpression(range), assemblyscript_1.TypeNode.createIdentifierExpression("__aspectStrictEquals", range), range),
    ], range), assemblyscript_1.TypeNode.createBlockStatement([
        assemblyscript_1.TypeNode.createIfStatement(assemblyscript_1.TypeNode.createUnaryPrefixExpression(assemblyscript_1.Token.EXCLAMATION, createSuperCallExpression(nameHashes, range), range), assemblyscript_1.TypeNode.createReturnStatement(assemblyscript_1.TypeNode.createFalseExpression(range), range), null, range),
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
    return assemblyscript_1.TypeNode.createCallExpression(assemblyscript_1.TypeNode.createPropertyAccessExpression(assemblyscript_1.TypeNode.createSuperExpression(range), assemblyscript_1.TypeNode.createIdentifierExpression("__aspectStrictEquals", range), range), null, [
        assemblyscript_1.TypeNode.createIdentifierExpression("ref", range),
        assemblyscript_1.TypeNode.createIdentifierExpression("stack", range),
        assemblyscript_1.TypeNode.createIdentifierExpression("cache", range),
        // StaticArray.concat(ignore, [... props] as StaticArray<i64>)
        assemblyscript_1.TypeNode.createCallExpression(assemblyscript_1.TypeNode.createPropertyAccessExpression(assemblyscript_1.TypeNode.createIdentifierExpression("StaticArray", range), assemblyscript_1.TypeNode.createIdentifierExpression("concat", range), range), null, [
            assemblyscript_1.TypeNode.createIdentifierExpression("ignore", range),
            // [...] as StaticArray<i64>
            assemblyscript_1.TypeNode.createAssertionExpression(assemblyscript_1.AssertionKind.AS, assemblyscript_1.TypeNode.createArrayLiteralExpression(hashValues.map(function (e) {
                return assemblyscript_1.TypeNode.createIntegerLiteralExpression(f64_as_i64(e), range);
            }), range), assemblyscript_1.TypeNode.createNamedType(assemblyscript_1.TypeNode.createSimpleTypeName("StaticArray", range), [
                assemblyscript_1.TypeNode.createNamedType(assemblyscript_1.TypeNode.createSimpleTypeName("i64", range), null, false, range),
            ], false, range), range),
        ], range),
    ], range);
}
//# sourceMappingURL=createStrictEqualsMember.js.map