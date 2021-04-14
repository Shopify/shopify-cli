import { BLOCK_MAXSIZE } from "rt/common";
import { E_INDEXOUTOFRANGE, E_INVALIDLENGTH } from "util/error";

export class DataReader {
  readonly buffer: ArrayBuffer;
  @unsafe readonly dataStart: usize;
  private byteOffset: i32;
  readonly byteLength: i32;

  constructor(
    buffer: ArrayBuffer,
    byteOffset: i32 = 0,
    byteLength: i32 = buffer.byteLength
  ) {
    if (
      i32(<u32>byteLength > <u32>BLOCK_MAXSIZE) |
      i32(<u32>byteOffset + byteLength > <u32>buffer.byteLength)
    )
      throw new RangeError(E_INVALIDLENGTH);
    this.buffer = buffer; // retains
    var dataStart = changetype<usize>(buffer);
    this.dataStart = dataStart;
    this.byteLength = byteLength;
    this.byteOffset = byteOffset;
  }

  getBytes(length: i32): ArrayBuffer {
    if (this.byteOffset + length > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    const result = this.buffer.slice(this.byteOffset, this.byteOffset + length);
    this.byteOffset += length;
    return result;
  }

  setBytes(buf: ArrayBuffer): void {
    if (this.byteOffset + buf.byteLength > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    memory.copy(
      changetype<i32>(this.dataStart) + this.byteOffset,
      changetype<i32>(buf),
      buf.byteLength
    );
    this.byteOffset += buf.byteLength;
  }

  peekUint8(): u8 {
    if (this.byteOffset > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    return bswap(load<u8>(this.dataStart + this.byteOffset));
  }

  discard(length: i32): void {
    if (this.byteOffset + length > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    this.byteOffset += length;
  }

  getFloat32(): f32 {
    if (this.byteOffset + 4 > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    const result = reinterpret<f32>(bswap(load<u32>(this.dataStart + this.byteOffset)));
    this.byteOffset += 4;
    return result;
  }

  getFloat64(): f64 {
    if (this.byteOffset + 8 > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    const result = reinterpret<f64>(bswap(load<u64>(this.dataStart + this.byteOffset)));
    this.byteOffset += 8;
    return result;
  }

  getInt8(): i8 {
    if (this.byteOffset >= this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    const result = load<i8>(this.dataStart + this.byteOffset);
    this.byteOffset++;
    return bswap(result);
  }

  getInt16(): i16 {
    if (this.byteOffset + 2 > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    const result = load<i16>(this.dataStart + this.byteOffset);
    this.byteOffset += 2;
    return bswap(result);
  }

  getInt32(): i32 {
    if (this.byteOffset + 4 > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    const result = load<i32>(this.dataStart + this.byteOffset);
    this.byteOffset += 4;
    return bswap(result);
  }

  getUint8(): u8 {
    if (this.byteOffset >= this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    const result = load<u8>(this.dataStart + this.byteOffset);
    this.byteOffset++;
    return bswap(result);
  }

  getUint16(): u16 {
    if (this.byteOffset + 2 > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    const result = load<u16>(this.dataStart + this.byteOffset);
    this.byteOffset += 2;
    return bswap(result);
  }

  getUint32(): u32 {
    if (this.byteOffset + 4 > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    const result = load<u32>(this.dataStart + this.byteOffset);
    this.byteOffset += 4;
    return bswap(result);
  }

  setFloat32(value: f32): void {
    if (this.byteOffset + 4 > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    store<u32>(this.dataStart + this.byteOffset, bswap(reinterpret<u32>(value)));
    this.byteOffset += 4;
  }

  setFloat64(value: f64): void {
    if (this.byteOffset + 8 > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    store<u64>(this.dataStart + this.byteOffset, bswap(reinterpret<u64>(value)));
    this.byteOffset += 8;
  }

  setInt8(value: i8): void {
    if (this.byteOffset >= this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    store<i8>(this.dataStart + this.byteOffset, bswap(value));
    this.byteOffset++;
  }

  setInt16(value: i16): void {
    if (this.byteOffset + 2 > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    store<i16>(this.dataStart + this.byteOffset, bswap(value));
    this.byteOffset += 2;
  }

  setInt32(value: i32): void {
    if (this.byteOffset + 4 > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    store<i32>(this.dataStart + this.byteOffset, bswap(value));
    this.byteOffset += 4;
  }

  setUint8(value: u8): void {
    if (this.byteOffset >= this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    store<u8>(this.dataStart + this.byteOffset, bswap(value));
    this.byteOffset++;
  }

  setUint16(value: u16): void {
    if (this.byteOffset + 2 > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    store<i32>(this.dataStart + this.byteOffset, bswap(value));
    this.byteOffset += 2;
  }

  setUint32(value: u32): void {
    if (this.byteOffset + 4 > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    store<u32>(this.dataStart + this.byteOffset, bswap(value));
    this.byteOffset += 4;
  }

  // Non-standard additions that make sense in WebAssembly, but won't work in JS:
  getInt64(): i64 {
    if (this.byteOffset + 8 > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    const result = load<i64>(this.dataStart + this.byteOffset);
    this.byteOffset += 8;
    return bswap(result);
  }

  getUint64(): u64 {
    if (this.byteOffset + 8 > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    const result = load<u64>(this.dataStart + this.byteOffset);
    this.byteOffset += 8;
    return bswap(result);
  }

  setInt64(value: i64): void {
    if (this.byteOffset + 8 > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    store<i64>(this.dataStart + this.byteOffset, bswap(value));
    this.byteOffset += 8;
  }

  setUint64(value: u64): void {
    if (this.byteOffset + 8 > this.byteLength)
      throw new RangeError(E_INDEXOUTOFRANGE);
    store<u64>(this.dataStart + this.byteOffset, bswap(value));
    this.byteOffset += 8;
  }

  toString(): string {
    return "[object DataReader]";
  }
}
