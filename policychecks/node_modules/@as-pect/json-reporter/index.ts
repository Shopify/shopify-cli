import { WriteStream, createWriteStream } from "fs";
import { basename, extname, dirname, join } from "path";
import { TestNodeType, TestContext, IReporter, TestNode } from "@as-pect/core";

/**
 * This class reports all relevant test statistics to a JSON file located at
 * `{testLocation}.spec.json`.
 */
module.exports = class JSONReporter implements IReporter {
  protected file: WriteStream | null = null;

  private first: boolean = true;

  public onEnter(ctx: TestContext): void {
    const extension = extname(ctx.fileName);
    const dir = dirname(ctx.fileName);
    const base = basename(ctx.fileName, extension);
    const outPath = join(process.cwd(), dir, base + ".json");
    this.file = createWriteStream(outPath, "utf8");
    this.file.write("[");
    this.first = true;
  }

  public onExit(_ctx: TestContext, node: TestNode): void {
    if (node.type === TestNodeType.Group) {
      this.onGroupFinish(node);
    }
  }

  public onFinish(_ctx: TestContext): void {
    this.file!.end();
  }

  protected onGroupFinish(group: TestNode) {
    if (group.children.length === 0) return;

    group.groupTests.forEach((test) => this.onTestFinish(group, test));
    group.groupTodos.forEach((desc) => this.onTodo(group, desc));
  }

  protected onTestFinish(group: TestNode, test: TestNode): void {
    this.file!.write(
      (this.first ? "\n" : ",\n") +
        JSON.stringify({
          group: group.name,
          name: test.name,
          ran: test.ran,
          pass: test.pass,
          negated: test.negated,
          runtime: test.deltaT,
          message: test.message,
          actual: test.actual ? test.actual.stringify({ indent: 0 }) : null,
          expected: test.expected
            ? `${test.negated ? "Not " : ""}${test.expected.stringify({
                indent: 0,
              })}`
            : null,
        }),
    );
    this.first = false;
  }

  protected onTodo(group: TestNode, desc: string) {
    this.file!.write(
      (this.first ? "\n" : ",\n") +
        JSON.stringify({
          group: group.name,
          name: "TODO: " + desc,
          ran: false,
          pass: null,
          negated: false,
          runtime: 0,
          message: "",
          actual: null,
          expected: null,
        }),
    );
    this.first = false;
  }
};
