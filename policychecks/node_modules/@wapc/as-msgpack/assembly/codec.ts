import { Decoder } from "./decoder";
import { Writer } from "./writer";
import { Sizer } from "./sizer";
import { Encoder } from "./encoder";

export interface Codec {
  decode(decoder: Decoder): void;
  encode(encoder: Writer): void;
}

export function toArrayBuffer(codec: Codec): ArrayBuffer {
  let sizer = new Sizer();
  codec.encode(sizer);
  let buffer = new ArrayBuffer(sizer.length);
  let encoder = new Encoder(buffer);
  codec.encode(encoder);
  return buffer;
}
