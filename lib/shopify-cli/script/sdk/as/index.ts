import { Int, Str } from "./runtime-types";

@unmanaged
export class Money {
    public readonly subunits: Int;
    private readonly _currency: Str;

    constructor(subunits: i32, currency: String) {
        this._currency = Str.from(currency);
        this.subunits = subunits;
    }

    get currency(): String {
        return this._currency.toString();
    }
}

export * from "./runtime-types"
