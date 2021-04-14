export class Value<T> {
  value: T;

  constructor(value: T) {
    this.value = value;
  }

  @inline
  @operator("+")
  protected add(rhs: T): T {
    return this.value + rhs;
  }

  @inline
  @operator("-")
  protected subtract(rhs: T): T {
    return this.value - rhs;
  }

  @inline
  @operator("*")
  protected multiply(rhs: T): T {
    return this.value * rhs;
  }

  @inline
  @operator("/")
  protected divide(rhs: T): T {
    return this.value / rhs;
  }

  @inline
  @operator("%")
  protected modulo(rhs: T): T {
    return this.value % rhs;
  }

  @inline
  @operator("==")
  protected eq(rhs: T): bool {
    return this.value == rhs;
  }

  @inline
  @operator("!=")
  protected neq(rhs: T): bool {
    return this.value != rhs;
  }

  @inline
  @operator(">")
  protected gt(rhs: T): bool {
    return this.value > rhs;
  }

  @inline
  @operator(">=")
  protected gte(rhs: T): bool {
    return this.value >= rhs;
  }

  @inline
  @operator("<")
  protected lt(rhs: T): bool {
    return this.value < rhs;
  }

  @inline
  @operator("<=")
  protected lte(rhs: T): bool {
    return this.value <= rhs;
  }

  @inline
  @operator("<<")
  protected bsl(rhs: T): T {
    return this.value << rhs;
  }

  @inline
  @operator(">>")
  protected arithmeticSR(rhs: T): T {
    return this.value >> rhs;
  }

  @inline
  @operator(">>>")
  protected logicalSR(rhs: T): T {
    return this.value >>> rhs;
  }

  @inline
  @operator("&")
  protected bitwiseAND(rhs: T): T {
    return this.value & rhs;
  }

  @inline
  @operator("^")
  protected bitwiseXOR(rhs: T): T {
    return this.value ^ rhs;
  }

  @inline
  @operator("|")
  protected bitwiseOR(rhs: T): T {
    return this.value | rhs;
  }

  @inline
  @operator.prefix("!")
  protected not(): T {
    return !this.value;
  }

  @inline
  @operator.prefix("~")
  protected bitwiseNot(): T {
    return ~this.value;
  }

  @inline
  @operator.post("++")
  protected inc(): T {
    return this.value++;
  }

  @inline
  @operator.post("--")
  protected dec(): T {
    return this.value--;
  }
}
