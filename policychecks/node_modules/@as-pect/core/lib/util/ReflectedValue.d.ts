import { ReflectedValueType } from "@as-pect/assembly/assembly/internal/ReflectedValueType";
import { StringifyReflectedValueProps } from "./stringifyReflectedValue";
/**
 * A JavaScript object that represents a reflected value from the as-pect testing
 * module.
 */
export declare class ReflectedValue {
    /** An indicator if the reflected object was managed by the runtime. */
    isManaged: boolean;
    /** An indicator if the reflected object was null. */
    isNull: boolean;
    /** A set of keys for Maps or Classes in the reflected object. */
    keys: ReflectedValue[] | null;
    /** Used to indicate if an expected assertion value was negated. */
    negated: boolean;
    /** An indicator wether the reflected object was in a nullable context. */
    nullable: boolean;
    /** The size of the heap allocation for a given class. */
    offset: number;
    /** The pointer to the value in the module. */
    pointer: number;
    /** An indicator if a number was signed. */
    signed: boolean;
    /** The size of an array, or the byte size of a number. */
    size: number;
    /** A stack trace for the given value. */
    stack: string;
    /** The reflected value type. */
    type: ReflectedValueType;
    /** The runtime class id for the reflected reflected value. */
    typeId: number;
    /** The name of the class for a given reflected reflected value. */
    typeName: string | null;
    /** A string or number representing the reflected value. */
    value: number | string;
    /** A set of values that are contained in a given reflected Set, Map, or Class object. */
    values: ReflectedValue[] | null;
    /**
     * Stringify the ReflectedValue with custom formatting.
     *
     * @param {Partial<StringifyReflectedValueProps>} props - The stringify configuration
     */
    stringify(props?: Partial<StringifyReflectedValueProps>): string;
}
//# sourceMappingURL=ReflectedValue.d.ts.map