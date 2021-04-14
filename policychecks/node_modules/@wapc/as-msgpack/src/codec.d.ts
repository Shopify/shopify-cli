import { Decoder } from "./decoder";
import { Writer } from "./writer";

export declare interface Codec {
  decode(decoder: Decoder): void;
  encode(encoder: Writer): void;
}

export declare function toArrayBuffer(codec: Codec): ArrayBuffer;
