import { Decoder, Writer, Encoder, Sizer } from "..";

class Wrapper<T> {
  constructor(public value: T) {}

  fromBuffer(buffer: ArrayBuffer): void {
    const decoder = new Decoder(buffer);
    this.decode(decoder);
  }

  toBuffer(): ArrayBuffer {
    const sizer = new Sizer();
    this.encode(sizer);
    const buffer = new ArrayBuffer(sizer.length);
    const encoder = new Encoder(buffer);
    this.encode(encoder);
    return buffer;
  }

  decode(reader: Decoder): void {
    var numFields = reader.readMapSize();

    while (numFields > 0) {
      numFields--;
      const field = reader.readString();

      if (field == "value") {
        if (this.value instanceof u8) {
          this.value = <T>reader.readUInt8();
        } else if (this.value instanceof u16) {
          this.value = <T>reader.readUInt16();
        } else if (this.value instanceof i32) {
          this.value = <T>reader.readInt32();
        } else if (this.value instanceof f32) {
          this.value = <T>reader.readFloat32();
        } else if (this.value instanceof f64) {
          this.value = <T>reader.readFloat64();
        } else {
          throw new Error("not implemented");
        }
      } else {
        reader.skip();
      }
    }
  }

  encode(writer: Writer): void {
    writer.writeMapSize(1);
    writer.writeString("value");
    if (this.value instanceof u8) {
      writer.writeUInt8(<u8>this.value);
    } else if (this.value instanceof u16) {
      writer.writeUInt16(<u16>this.value);
    } else if (this.value instanceof i32) {
      writer.writeInt32(<i32>this.value);
    } else if (this.value instanceof f32) {
      writer.writeFloat32(<f32>this.value);
    } else if (this.value instanceof f64) {
      writer.writeFloat64(<f64>this.value);
    } else {
      throw new Error("not implemented");
    }
  }
}

describe("CodecNumericConversionCheck", () => {
  describe("integer", () => {
    it("auto converts for compatible value from u8 to i32", () => {
      const input = new Wrapper<u8>(128);
      const output = new Wrapper<i32>(0);
      output.fromBuffer(input.toBuffer());
      expect(output.value).toStrictEqual(128);
    });

    it("auto converts for compatible value from i32 to u16", () => {
      const input = new Wrapper<i32>(128);
      const output = new Wrapper<u16>(0);
      output.fromBuffer(input.toBuffer());
      expect(output.value).toStrictEqual(128);
    });

    it("throws an error for underflow value", () => {
      expect(() => {
        const input = new Wrapper<i32>(-42);
        const output = new Wrapper<u8>(0);
        output.fromBuffer(input.toBuffer())
      }).toThrow();
    });

    it("throws an error for overflow value", () => {
      expect(() => {
        const input = new Wrapper<u16>(257);
        const output = new Wrapper<u8>(0);
        output.fromBuffer(input.toBuffer())
      }).toThrow();
    });
  });

  describe("float", () => {
    it("auto converts compatible value from f32 to f64", () => {
      const input = new Wrapper<f32>(1.0);
      const output = new Wrapper<f64>(0.0);
      output.fromBuffer(input.toBuffer());
      expect(output.value).toStrictEqual(1.0);
    });

    it("auto converts compatible value from f64 to f32", () => {
      const input = new Wrapper<f64>(1.0);
      const output = new Wrapper<f32>(0.0);
      output.fromBuffer(input.toBuffer());
      expect(output.value).toStrictEqual(1.0);
    });

    it("throws an error for overflow value", () => {
      expect(() => {
        const input = new Wrapper<f64>(f64.MAX_VALUE);
        const output = new Wrapper<f32>(0.0);
        output.fromBuffer(input.toBuffer())
      }).toThrow();
    });
  });
});
