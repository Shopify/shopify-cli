import { DataReader } from "./datareader";
import { Format } from "./format";
import { Writer } from "./writer";

export class Encoder implements Writer {
    private reader: DataReader;
  
    constructor(ua: ArrayBuffer) {
      this.reader = new DataReader(ua, 0, ua.byteLength);
    }
  
    writeNil(): void {
      this.reader.setUint8(<u8>Format.NIL);
    }
  
    writeBool(value: bool): void {
      this.reader.setUint8(value ? <u8>Format.TRUE : <u8>Format.FALSE);
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
      if (value >= 0 && value < 1 << 7) {
        this.reader.setUint8(<u8>value);
      } else if (value < 0 && value >= -32) {
        this.reader.setUint8((<u8>value) | (<u8>Format.NEGATIVE_FIXINT));
      } else if (value <= <i64>i8.MAX_VALUE && value >= <i64>i8.MIN_VALUE) {
        this.reader.setUint8(<u8>Format.INT8);
        this.reader.setInt8(<i8>value);
      } else if (value <= <i64>i16.MAX_VALUE && value >= <i64>i16.MIN_VALUE) {
        this.reader.setUint8(<u8>Format.INT16);
        this.reader.setInt16(<i16>value);
      } else if (value <= <i64>i32.MAX_VALUE && value >= <i64>i32.MIN_VALUE) {
        this.reader.setUint8(<u8>Format.INT32);
        this.reader.setInt32(<i32>value);
      } else {
        this.reader.setUint8(<u8>Format.INT64);
        this.reader.setInt64(value);
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
        this.reader.setUint8(<u8>value);
      } else if (value <= <u64>u8.MAX_VALUE) {
        this.reader.setUint8(<u8>Format.UINT8);
        this.reader.setUint8(<u8>value);
      } else if (value <= <u64>u16.MAX_VALUE) {
        this.reader.setUint8(<u8>Format.UINT16);
        this.reader.setUint16(<u16>value);
      } else if (value <= <u64>u32.MAX_VALUE) {
        this.reader.setUint8(<u8>Format.UINT32);
        this.reader.setUint32(<u32>value);
      } else {
        this.reader.setUint8(<u8>Format.UINT64);
        this.reader.setUint64(value);
      }
    }
  
    writeFloat32(value: f32): void {
      this.reader.setUint8(<u8>Format.FLOAT32);
      this.reader.setFloat32(value);
    }
  
    writeFloat64(value: f64): void {
      this.reader.setUint8(<u8>Format.FLOAT64);
      this.reader.setFloat64(value);
    }
  
    writeStringLength(length: u32): void {
      if (length < 32) {
        this.reader.setUint8((<u8>length) | (<u8>Format.FIXSTR));
      } else if (length <= <u32>u8.MAX_VALUE) {
        this.reader.setUint8(<u8>Format.STR8);
        this.reader.setUint8(<u8>length);
      } else if (length <= <u32>u16.MAX_VALUE) {
        this.reader.setUint8(<u8>Format.STR16);
        this.reader.setUint16(<u16>length);
      } else {
        this.reader.setUint8(<u8>Format.STR32);
        this.reader.setUint32(length);
      }
    }
  
    writeString(value: string): void {
      const buf = String.UTF8.encode(value);
      this.writeStringLength(buf.byteLength);
      this.reader.setBytes(buf);
    }
  
    writeBinLength(length: u32): void {
      if (length <= <u32>u8.MAX_VALUE) {
        this.reader.setUint8(<u8>Format.BIN8);
        this.reader.setUint8(<u8>length);
      } else if (length <= <u32>u16.MAX_VALUE) {
        this.reader.setUint8(<u8>Format.BIN16);
        this.reader.setUint16(<u16>length);
      } else {
        this.reader.setUint8(<u8>Format.BIN32);
        this.reader.setUint32(length);
      }
    }
  
    writeByteArray(ab: ArrayBuffer): void {
      if (ab.byteLength == 0) {
        this.writeNil();
        return;
      }
      this.writeBinLength(ab.byteLength);
      this.reader.setBytes(ab);
    }
  
    writeArraySize(length: u32): void {
      if (length < 16) {
        this.reader.setInt8((<u8>length) | (<u8>Format.FIXARRAY));
      } else if (length <= <u32>u16.MAX_VALUE) {
        this.reader.setUint8(<u8>Format.ARRAY16);
        this.reader.setUint16(<u16>length);
      } else {
        this.reader.setUint8(<u8>Format.ARRAY32);
        this.reader.setUint32(length);
      }
    }
  
    writeMapSize(length: u32): void {
      if (length < 16) {
        this.reader.setInt8((<u8>length) | (<u8>Format.FIXMAP));
      } else if (length <= <u32>u16.MAX_VALUE) {
        this.reader.setUint8(<u8>Format.MAP16);
        this.reader.setUint16(<u16>length);
      } else {
        this.reader.setUint8(<u8>Format.MAP32);
        this.reader.setUint32(length);
      }
    }
  
    writeArray<T>(a: Array<T>, fn: (writer: Writer, item: T) => void): void {
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