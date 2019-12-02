export type ID = u64;
export type Int = i32;
export type Float = f64;

@unmanaged
export class Slice<T> {
  [key: number]: T

  _data: u32;
  _length: u32;

  @unsafe
  constructor(data: usize, length: usize) {
    this._data = <u32>data;
    this._length = <u32>length;
  }

  @inline
  get length(): i32 { return <i32>this._length; }

  @operator("[]")
  private __get(index: u32): T {
    return index < this._length ? load<T>(changetype<usize>(this._data) + (<usize>index << alignof<T>())) : <T>unreachable();
  }

  @operator("==")
  private __eq(other_slice: Slice<T>): bool {
    if(other_slice.length != this.length) { return false; }
    for(let i = 0; i < this.length; i++) {
      if(!(this[i] == other_slice[i])) {
        return false
      }
    }
    return true;
  }

  // NOTE: fromArray, fromArrayBuffer, and fromString do not retain the argument,
  // with runtime stub/none this is fine as nothing is ever freed, but with
  // runtime full/half this could be DANGEROUS and should be reconsidered

  @inline
  static from<T>(arr: Array<T>): Slice<T> {
    return new Slice(arr.dataStart, arr.length);
  }

  @inline
  static fromArray<T>(arr: Array<T>): Slice<T> {
    return new Slice(arr.dataStart, arr.length);
  }

  @inline
  static fromArrayBuffer(buf: ArrayBuffer): Slice<u8> {
    return new Slice(changetype<usize>(buf), buf.byteLength);
  }

  @inline
  static fromString(str: String): Str {
    return <Str>Slice.fromArrayBuffer(String.UTF8.encode(str));
  }

  extend_array(array: Array<T>): Array<T> {
    for(let i = 0; i < this.length; i++) {
      array.push(this[i]);
    }
    return array;
  }

  map<U>(fn: (value: T) => U): Array<U> {
    var length = this.length;
    var out = changetype<Array<U>>(__allocArray(length, alignof<U>(), idof<Array<U>>())); // retains
    var outStart = out.dataStart;
    for (let index = 0; index < min(length, this.length); ++index) {
      let result = fn(this[index]); // retains
      if (isManaged<U>()) {
        store<usize>(outStart + (<usize>index << alignof<U>()), __retain(changetype<usize>(result)));
      } else {
        store<U>(outStart + (<usize>index << alignof<U>()), result);
      }
      // releases result
    }
    return out;
  }

  reduce<U>(fn: (previousValue: U, currentValue: T) => U, initialValue: U) : U {
    let accum = initialValue;
    for(let i = 0; i < this.length; i++) {
      accum = fn(accum, this[i]);
    }
    return accum;
  }

  filter<E>(callbackFn: (thing: T) => bool): Array<T> {
    let array = new Array<T>();

    for(let i = 0; i < this.length; i++) {
      if(callbackFn.call(this[i])) {
        array.push(this[i]);
      }
    }

    return array;
  }

  every(callbackFn: (thing: T, index: i32, array: Slice<T>) => bool): bool {
    for(let i = 0; i < this.length; i++) {
      if (!callbackFn(this[i], i, this)) {
        return false;
      }
    }
    return true;
  }

  some(callbackFn: (thing: T, index: i32, array: Slice<T>) => bool): bool {
    for(let i = 0; i < this.length; i++) {
      if (callbackFn(this[i], i, this)) {
        return true;
      }
    }
    return false;
  }

  @inline
  includes(searchElement: T, fromIndex: i32 = 0): bool {
    return this.indexOf(searchElement, fromIndex) >= 0;
  }

  indexOf(searchElement: T, fromIndex: i32 = 0): i32 {
    if (this.length == 0 || fromIndex >= this.length) return -1;
    if (fromIndex < 0) fromIndex = max(this.length + fromIndex, 0);
    while (fromIndex < this.length) {
      if (this[fromIndex] == searchElement) return fromIndex;
      ++fromIndex;
    }
    return -1;
  }

  sort(comparator: (a: T, b: T) => i32 = COMPARATOR<T>()): Array<T> {
    return this.extend_array([]).sort(comparator);
  }

  concat(other: Array<T>): Array<T> {
    return this.extend_array([]).concat(other);
  }
}

@unmanaged
export class Str extends Slice<u8> {
  @inline
  static from(string: String): Str {
    return Str.fromString(string);
  }

  get length(): usize { return this.toString().length; }

  @operator("==")
  private __eq(other: Str): bool {
    return this.toString() == other.toString();
  }

  @operator("!=")
  private __ne(other: Str): bool {
    return !this.__eq(other);
  }

  @operator("+")
  concat(other: String): String {
    return this.toString() + other;
  }

  toString(): String {
    return String.UTF8.decodeUnsafe(<usize>this._data, <usize>this._length);
  }

  indexOf(other: String): i32 {
    return this.toString().indexOf(other);
  }
}
