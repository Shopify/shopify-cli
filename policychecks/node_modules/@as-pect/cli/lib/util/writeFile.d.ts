/**
 * @ignore
 * This method promisifies the fs.writeFile function call, and is compatible with node 10.
 *
 * @param {string} file - The file location to write to.
 * @param {Uint8Array} contents - The file contents to write to the disk.
 */
export declare function writeFile(file: string, contents: Uint8Array | string): Promise<void>;
//# sourceMappingURL=writeFile.d.ts.map