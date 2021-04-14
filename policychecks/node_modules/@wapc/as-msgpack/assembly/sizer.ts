import { Writer } from "./writer";

export class Sizer implements Writer {
  length: i32;

  constructor() {}

  writeNil(): void {
    this.length++;
  }

  writeString(value: string): void {
    const buf = String.UTF8.encode(value);
    this.writeStringLength(buf.byteLength);
    this.length += buf.byteLength;
  }

  writeStringLength(length: u32): void {
    if (length < 32) {
      this.length++;
    } else if (length <= <u32>u8.MAX_VALUE) {
      this.length += 2;
    } else if (length <= <u32>u16.MAX_VALUE) {
      this.length += 3;
    } else {
      this.length += 5;
    }
  }

  writeBool(value: bool): void {
    this.length++;
  }

  writeArraySize(length: u32): void {
    if (length < 16) {
      this.length++;
    } else if (length <= <u32>u16.MAX_VALUE) {
      this.length += 3;
    } else {
      this.length += 5;
    }
  }

  writeBinLength(length: u32): void {
    if (length <= <u32>u8.MAX_VALUE) {
      this.length += 1;
    } else if (length <= <u32>u16.MAX_VALUE) {
      this.length += 2;
    } else {
      this.length += 4;
    }
  }

  writeByteArray(ab: ArrayBuffer): void {
    if (ab.byteLength == 0) {
      this.length++; //nil byte
      return;
    }
    this.writeBinLength(ab.byteLength);
    this.length += ab.byteLength + 1;
  }

  writeMapSize(length: u32): void {
    if (length < 16) {
      this.length++;
    } else if (length <= <u32>u16.MAX_VALUE) {
      this.length += 3;
    } else {
      this.length += 5;
    }
  }

  writeInt8(value: i8): void {
    this.writeInt64(<i64>value);
  }
  writeInt16(value: i16): void {
    this.writeInt64(<i64>value);
  }
  writeInt32(value: i32): void {
    this.writeInt64(<i64>value);
  }
  writeInt64(value: i64): void {
    if (value >= -(1 << 5) && value < 1 << 7) {
      this.length++;
    } else if (value < 1 << 7 && value >= -(1 << 7)) {
      this.length += 2;
    } else if (value < 1 << 15 && value >= -(1 << 15)) {
      this.length += 3;
    } else if (value < 1 << 31 && value >= -(1 << 31)) {
      this.length += 5;
    } else {
      this.length += 9;
    }
  }

  writeUInt8(value: u8): void {
    this.writeUInt64(<u64>value);
  }
  writeUInt16(value: u16): void {
    this.writeUInt64(<u64>value);
  }
  writeUInt32(value: u32): void {
    this.writeUInt64(<u64>value);
  }
  writeUInt64(value: u64): void {
    if (value < 1 << 7) {
      this.length++;
    } else if (value < 1 << 8) {
      this.length += 2;
    } else if (value < 1 << 16) {
      this.length += 3;
    } else if (value < 1 << 32) {
      this.length += 5;
    } else {
      this.length += 9;
    }
  }

  writeFloat32(value: f32): void {
    this.length += 5;
  }
  writeFloat64(value: f64): void {
    this.length += 9;
  }

  writeArray<T>(a: Array<T>, fn: (sizer: Sizer, item: T) => void): void {
    this.writeArraySize(a.length);
    for (let i: i32 = 0; i < a.length; i++) {
      fn(this, a[i]);
    }
  }

  writeNullableArray<T>(
    a: Array<T> | null,
    fn: (writer: Writer, item: T) => void
  ): void {
    if (a === null) {
      this.writeNil();
      return;
    }
    this.writeArray(a, fn);
  }

  writeMap<K, V>(
    m: Map<K, V>,
    keyFn: (writer: Writer, key: K) => void,
    valueFn: (writer: Writer, value: V) => void
  ): void {
    this.writeMapSize(m.size);
    const keys = m.keys();
    for (let i: i32 = 0; i < keys.length; i++) {
      const key = keys[i];
      const value = m.get(key);
      keyFn(this, key);
      valueFn(this, value);
    }
  }

  writeNullableMap<K, V>(
    m: Map<K, V> | null,
    keyFn: (writer: Writer, key: K) => void,
    valueFn: (writer: Writer, value: V) => void
  ): void {
    if (m === null) {
      this.writeNil();
      return;
    }
    this.writeMap(m, keyFn, valueFn);
  }
}

