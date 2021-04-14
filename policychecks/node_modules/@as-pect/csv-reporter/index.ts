import stringify, { Stringifier } from "csv-stringify";
import { WriteStream, createWriteStream } from "fs";
import { basename, extname, dirname, join } from "path";
import { TestNodeType, TestContext, IReporter, TestNode } from "@as-pect/core";

/**
 * This is a list of all the columns in the exported csv file.
 */
const csvColumns = [
  "Group",
  "Name",
  "Ran",
  "Negated",
  "Pass",
  "Runtime",
  "Message",
  "Actual",
  "Expected",
];

/**
 * This class is responsible for creating a csv file located at {testName}.spec.csv. It will
 * contain a set of tests with relevant pass and fail information.
 */
module.exports = class CSVReporter implements IReporter {
  protected output: Stringifier | null = null;
  protected fileName: WriteStream | null = null;

  public onEnter(ctx: TestContext): void {
    this.output = stringify({ columns: csvColumns });
    const extension = extname(ctx.fileName);
    const dir = dirname(ctx.fileName);
    const base = basename(ctx.fileName, extension);
    const outPath = join(process.cwd(), dir, base + ".csv");
    this.fileName = createWriteStream(outPath, "utf8");
    this.output.pipe(this.fileName);
    this.output.write(csvColumns);
  }

  public onExit(_ctx: TestContext, node: TestNode): void {
    if (node.type === TestNodeType.Group) {
      this.onGroupFinish(node);
    }
  }

  public onFinish(): void {
    this.output!.end();
  }

  protected onGroupFinish(group: TestNode): void {
    if (group.children.length === 0) return;

    group.groupTests.forEach((test) => this.onTestFinish(group, test));
    group.groupTodos.forEach((desc) => this.onTodo(group, desc));
  }

  protected onTestFinish(group: TestNode, test: TestNode) {
    this.output!.write([
      group.name,
      test.ran ? "RAN" : "NOT RUN",
      test.name,
      test.negated ? "TRUE" : "FALSE",
      test.pass ? "PASS" : "FAIL",
      test.deltaT.toString(),
      test.message,
      test.actual ? test.actual.stringify({ indent: 0 }) : "",
      test.expected
        ? `${test.negated ? "Not " : ""}${test.expected.stringify({
            indent: 0,
          })}`
        : "",
    ]);
  }

  protected onTodo(group: TestNode, desc: string) {
    this.output!.write([group.name, "TODO", desc, "", "", "", "", "", ""]);
  }
};
