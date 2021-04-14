import { ReflectedValue } from "./ReflectedValue";
export declare type StringifyReflectedValueProps = {
    keywordFormatter: (prop: string) => string;
    stringFormatter: (prop: string) => string;
    classNameFormatter: (prop: string) => string;
    numberFormatter: (prop: string) => string;
    indent: number;
    tab: number;
    maxPropertyCount: number;
    maxLineLength: number;
    maxExpandLevel: number;
};
export declare function stringifyReflectedValue(reflectedValue: ReflectedValue, props: Partial<StringifyReflectedValueProps>): string;
//# sourceMappingURL=stringifyReflectedValue.d.ts.map