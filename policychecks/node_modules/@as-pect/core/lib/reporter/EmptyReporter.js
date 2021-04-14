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
//# sourceMappingURL=EmptyReporter.js.map