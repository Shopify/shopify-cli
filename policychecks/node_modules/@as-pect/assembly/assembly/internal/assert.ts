export function assert(condition: i32, message: string): void {
  if (!condition) throw new Error(message);
}
