export declare class Decoder {
  private reader;
  constructor(ua: ArrayBuffer);
  isNextNil(): bool;
  readBool(): bool;
  readInt8(): i8;
  readInt16(): i16;
  readInt32(): i32;
  readInt64(): i64;
  readUInt8(): u8;
  readUInt16(): u16;
  readUInt32(): u32;
  readUInt64(): u64;
  readFloat32(): f32;
  readFloat64(): f64;
  readString(): string;
  readStringLength(): u32;
  readBinLength(): u32;
  readByteArray(): ArrayBuffer;
  readArraySize(): u32;
  readMapSize(): u32;
  isFloat32(u: u8): bool;
  isFloat64(u: u8): bool;
  isFixedInt(u: u8): bool;
  isNegativeFixedInt(u: u8): bool;
  isFixedMap(u: u8): bool;
  isFixedArray(u: u8): bool;
  isFixedString(u: u8): bool;
  isNil(u: u8): bool;
  skip(): void;
  getSize(): i32;
  readArray<T>(fn: (decoder: Decoder) => T): Array<T>;
  readNullableArray<T>(fn: (decoder: Decoder) => T): Array<T> | null;
  readMap<K, V>(
    keyFn: (decoder: Decoder) => K,
    valueFn: (decoder: Decoder) => V
  ): Map<K, V>;
  readNullableMap<K, V>(
    keyFn: (decoder: Decoder) => K,
    valueFn: (decoder: Decoder) => V
  ): Map<K, V> | null;
}
