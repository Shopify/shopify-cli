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
//# sourceMappingURL=CombinationReporter.js.map