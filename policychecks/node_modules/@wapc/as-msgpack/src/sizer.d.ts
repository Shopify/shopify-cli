import { Writer } from "./writer";

export declare class Sizer {
  length: i32;
  constructor();
  writeNil(): void;
  writeString(value: string): void;
  writeStringLength(length: u32): void;
  writeBool(value: bool): void;
  writeArraySize(length: u32): void;
  writeByteArray(ab: ArrayBuffer): void;
  writeBinLength(length: u32): void;
  writeMapSize(length: u32): void;
  writeInt8(value: i8): void;
  writeInt16(value: i16): void;
  writeInt32(value: i32): void;
  writeInt64(value: i64): void;
  writeUInt8(value: u8): void;
  writeUInt16(value: u16): void;
  writeUInt32(value: u32): void;
  writeUInt64(value: u64): void;
  writeFloat32(value: f32): void;
  writeFloat64(value: f64): void;
  writeArray<T>(a: Array<T>, fn: (writer: Writer, item: T) => void): void;
  writeNullableArray<T>(
    a: Array<T> | null,
    fn: (writer: Writer, item: T) => void
  ): void;
  writeMap<K, V>(
    m: Map<K, V>,
    keyFn: (writer: Writer, key: K) => void,
    valueFn: (writer: Writer, value: V) => void
  ): void;
  writeNullableMap<K, V>(
    m: Map<K, V> | null,
    keyFn: (writer: Writer, key: K) => void,
    valueFn: (writer: Writer, value: V) => void
  ): void;
}
