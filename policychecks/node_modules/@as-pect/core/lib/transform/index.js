"use strict";
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
// import { Transform } from "assemblyscript/cli/transform";
var assemblyscript_1 = require("./assemblyscript");
var createStrictEqualsMember_1 = require("./createStrictEqualsMember");
var createAddReflectedValueKeyValuePairsMember_1 = require("./createAddReflectedValueKeyValuePairsMember");
function traverseStatements(statements) {
    var e_1, _a;
    try {
        // for each statement in the source
        for (var statements_1 = __values(statements), statements_1_1 = statements_1.next(); !statements_1_1.done; statements_1_1 = statements_1.next()) {
            var statement = statements_1_1.value;
            // find each class declaration
            if (statement.kind === assemblyscript_1.NodeKind.CLASSDECLARATION) {
                // cast and create a strictEquals function
                var classDeclaration = statement;
                classDeclaration.members.push(createStrictEqualsMember_1.createStrictEqualsMember(classDeclaration));
                classDeclaration.members.push(createAddReflectedValueKeyValuePairsMember_1.createAddReflectedValueKeyValuePairsMember(classDeclaration));
            }
            else if (statement.kind === assemblyscript_1.NodeKind.NAMESPACEDECLARATION) {
                var namespaceDeclaration = statement;
                traverseStatements(namespaceDeclaration.members);
            }
        }
    }
    catch (e_1_1) { e_1 = { error: e_1_1 }; }
    finally {
        try {
            if (statements_1_1 && !statements_1_1.done && (_a = statements_1.return)) _a.call(statements_1);
        }
        finally { if (e_1) throw e_1.error; }
    }
}
module.exports = /** @class */ (function (_super) {
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
        var e_2, _a;
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
        catch (e_2_1) { e_2 = { error: e_2_1 }; }
        finally {
            try {
                if (sources_1_1 && !sources_1_1.done && (_a = sources_1.return)) _a.call(sources_1);
            }
            finally { if (e_2) throw e_2.error; }
        }
    };
    return AspectTransform;
}(assemblyscript_1.Transform));
//# sourceMappingURL=index.js.map