declare module binaryen {

  const isReady: boolean;
  const ready: Promise<typeof binaryen>;

  type Type = number;

  const none: Type;
  const i32: Type;
  const i64: Type;
  const f32: Type;
  const f64: Type;
  const v128: Type;
  const funcref: Type;
  const externref: Type;
  const exnref: Type;
  const anyref: Type;
  const eqref: Type;
  const i31ref: Type;
  const unreachable: Type;
  const auto: Type;

  function createType(types: Type[]): Type;
  function expandType(type: Type): Type[];

  const enum ExpressionIds {
    Invalid,
    Block,
    If,
    Loop,
    Break,
    Switch,
    Call,
    CallIndirect,
    LocalGet,
    LocalSet,
    GlobalGet,
    GlobalSet,
    Load,
    Store,
    Const,
    Unary,
    Binary,
    Select,
    Drop,
    Return,
    MemorySize,
    MemoryGrow,
    Nop,
    Unreachable,
    AtomicCmpxchg,
    AtomicRMW,
    AtomicWait,
    AtomicNotify,
    AtomicFence,
    SIMDExtract,
    SIMDReplace,
    SIMDShuffle,
    SIMDTernary,
    SIMDShift,
    SIMDLoad,
    MemoryInit,
    DataDrop,
    MemoryCopy,
    MemoryFill,
    RefNull,
    RefIsNull,
    RefFunc,
    RefEq,
    Try,
    Throw,
    Rethrow,
    BrOnExn,
    TupleMake,
    TupleExtract,
    Pop,
    I31New,
    I31Get,
    CallRef,
    RefTest,
    RefCast,
    BrOnCast,
    RttCanon,
    RttSub,
    StructNew,
    StructGet,
    StructSet,
    ArrayNew,
    ArrayGet,
    ArraySet,
    ArrayLen
  }

  const InvalidId: ExpressionIds;
  const BlockId: ExpressionIds;
  const IfId: ExpressionIds;
  const LoopId: ExpressionIds;
  const BreakId: ExpressionIds;
  const SwitchId: ExpressionIds;
  const CallId: ExpressionIds;
  const CallIndirectId: ExpressionIds;
  const LocalGetId: ExpressionIds;
  const LocalSetId: ExpressionIds;
  const GlobalGetId: ExpressionIds;
  const GlobalSetId: ExpressionIds;
  const LoadId: ExpressionIds;
  const StoreId: ExpressionIds;
  const ConstId: ExpressionIds;
  const UnaryId: ExpressionIds;
  const BinaryId: ExpressionIds;
  const SelectId: ExpressionIds;
  const DropId: ExpressionIds;
  const ReturnId: ExpressionIds;
  const MemorySizeId: ExpressionIds;
  const MemoryGrowId: ExpressionIds;
  const NopId: ExpressionIds;
  const UnreachableId: ExpressionIds;
  const AtomicCmpxchgId: ExpressionIds;
  const AtomicRMWId: ExpressionIds;
  const AtomicWaitId: ExpressionIds;
  const AtomicNotifyId: ExpressionIds;
  const AtomicFenceId: ExpressionIds;
  const SIMDExtractId: ExpressionIds;
  const SIMDReplaceId: ExpressionIds;
  const SIMDShuffleId: ExpressionIds;
  const SIMDTernaryId: ExpressionIds;
  const SIMDShiftId: ExpressionIds;
  const SIMDLoadId: ExpressionIds;
  const MemoryInitId: ExpressionIds;
  const DataDropId: ExpressionIds;
  const MemoryCopyId: ExpressionIds;
  const MemoryFillId: ExpressionIds;
  const RefNullId: ExpressionIds;
  const RefIsNullId: ExpressionIds;
  const RefFuncId: ExpressionIds;
  const RefEqId: ExpressionIds;
  const TryId: ExpressionIds;
  const ThrowId: ExpressionIds;
  const RethrowId: ExpressionIds;
  const BrOnExnId: ExpressionIds;
  const TupleMakeId: ExpressionIds;
  const TupleExtractId: ExpressionIds;
  const PopId: ExpressionIds;
  const I31NewId: ExpressionIds;
  const I31GetId: ExpressionIds;
  const CallRefId: ExpressionIds;
  const RefTestId: ExpressionIds;
  const RefCastId: ExpressionIds;
  const BrOnCastId: ExpressionIds;
  const RttCanonId: ExpressionIds;
  const RttSubId: ExpressionIds;
  const StructNewId: ExpressionIds;
  const StructGetId: ExpressionIds;
  const StructSetId: ExpressionIds;
  const ArrayNewId: ExpressionIds;
  const ArrayGetId: ExpressionIds;
  const ArraySetId: ExpressionIds;
  const ArrayLenId: ExpressionIds;

  const enum ExternalKinds {
    Function,
    Table,
    Memory,
    Global,
    Event
  }

  const ExternalFunction: ExternalKinds;
  const ExternalTable: ExternalKinds;
  const ExternalMemory: ExternalKinds;
  const ExternalGlobal: ExternalKinds;
  const ExternalEvent: ExternalKinds;

  enum Features {
    MVP,
    Atomics,
    BulkMemory,
    MutableGlobals,
    NontrappingFPToInt,
    SignExt,
    SIMD128,
    ExceptionHandling,
    TailCall,
    ReferenceTypes,
    Multivalue,
    GC,
    Memory64,
    All
  }

  const enum Operations {
    ClzInt32,
    CtzInt32,
    PopcntInt32,
    NegFloat32,
    AbsFloat32,
    CeilFloat32,
    FloorFloat32,
    TruncFloat32,
    NearestFloat32,
    SqrtFloat32,
    EqZInt32,
    ClzInt64,
    CtzInt64,
    PopcntInt64,
    NegFloat64,
    AbsFloat64,
    CeilFloat64,
    FloorFloat64,
    TruncFloat64,
    NearestFloat64,
    SqrtFloat64,
    EqZInt64,
    ExtendSInt32,
    ExtendUInt32,
    WrapInt64,
    TruncSFloat32ToInt32,
    TruncSFloat32ToInt64,
    TruncUFloat32ToInt32,
    TruncUFloat32ToInt64,
    TruncSFloat64ToInt32,
    TruncSFloat64ToInt64,
    TruncUFloat64ToInt32,
    TruncUFloat64ToInt64,
    TruncSatSFloat32ToInt32,
    TruncSatSFloat32ToInt64,
    TruncSatUFloat32ToInt32,
    TruncSatUFloat32ToInt64,
    TruncSatSFloat64ToInt32,
    TruncSatSFloat64ToInt64,
    TruncSatUFloat64ToInt32,
    TruncSatUFloat64ToInt64,
    ReinterpretFloat32,
    ReinterpretFloat64,
    ConvertSInt32ToFloat32,
    ConvertSInt32ToFloat64,
    ConvertUInt32ToFloat32,
    ConvertUInt32ToFloat64,
    ConvertSInt64ToFloat32,
    ConvertSInt64ToFloat64,
    ConvertUInt64ToFloat32,
    ConvertUInt64ToFloat64,
    PromoteFloat32,
    DemoteFloat64,
    ReinterpretInt32,
    ReinterpretInt64,
    ExtendS8Int32,
    ExtendS16Int32,
    ExtendS8Int64,
    ExtendS16Int64,
    ExtendS32Int64,
    AddInt32,
    SubInt32,
    MulInt32,
    DivSInt32,
    DivUInt32,
    RemSInt32,
    RemUInt32,
    AndInt32,
    OrInt32,
    XorInt32,
    ShlInt32,
    ShrUInt32,
    ShrSInt32,
    RotLInt32,
    RotRInt32,
    EqInt32,
    NeInt32,
    LtSInt32,
    LtUInt32,
    LeSInt32,
    LeUInt32,
    GtSInt32,
    GtUInt32,
    GeSInt32,
    GeUInt32,
    AddInt64,
    SubInt64,
    MulInt64,
    DivSInt64,
    DivUInt64,
    RemSInt64,
    RemUInt64,
    AndInt64,
    OrInt64,
    XorInt64,
    ShlInt64,
    ShrUInt64,
    ShrSInt64,
    RotLInt64,
    RotRInt64,
    EqInt64,
    NeInt64,
    LtSInt64,
    LtUInt64,
    LeSInt64,
    LeUInt64,
    GtSInt64,
    GtUInt64,
    GeSInt64,
    GeUInt64,
    AddFloat32,
    SubFloat32,
    MulFloat32,
    DivFloat32,
    CopySignFloat32,
    MinFloat32,
    MaxFloat32,
    EqFloat32,
    NeFloat32,
    LtFloat32,
    LeFloat32,
    GtFloat32,
    GeFloat32,
    AddFloat64,
    SubFloat64,
    MulFloat64,
    DivFloat64,
    CopySignFloat64,
    MinFloat64,
    MaxFloat64,
    EqFloat64,
    NeFloat64,
    LtFloat64,
    LeFloat64,
    GtFloat64,
    GeFloat64,
    AtomicRMWAdd,
    AtomicRMWSub,
    AtomicRMWAnd,
    AtomicRMWOr,
    AtomicRMWXor,
    AtomicRMWXchg,
    SplatVecI8x16,
    ExtractLaneSVecI8x16,
    ExtractLaneUVecI8x16,
    ReplaceLaneVecI8x16,
    SplatVecI16x8,
    ExtractLaneSVecI16x8,
    ExtractLaneUVecI16x8,
    ReplaceLaneVecI16x8,
    SplatVecI32x4,
    ExtractLaneVecI32x4,
    ReplaceLaneVecI32x4,
    SplatVecI64x2,
    ExtractLaneVecI64x2,
    ReplaceLaneVecI64x2,
    SplatVecF32x4,
    ExtractLaneVecF32x4,
    ReplaceLaneVecF32x4,
    SplatVecF64x2,
    ExtractLaneVecF64x2,
    ReplaceLaneVecF64x2,
    EqVecI8x16,
    NeVecI8x16,
    LtSVecI8x16,
    LtUVecI8x16,
    GtSVecI8x16,
    GtUVecI8x16,
    LeSVecI8x16,
    LeUVecI8x16,
    GeSVecI8x16,
    GeUVecI8x16,
    EqVecI16x8,
    NeVecI16x8,
    LtSVecI16x8,
    LtUVecI16x8,
    GtSVecI16x8,
    GtUVecI16x8,
    LeSVecI16x8,
    LeUVecI16x8,
    GeSVecI16x8,
    GeUVecI16x8,
    EqVecI32x4,
    NeVecI32x4,
    LtSVecI32x4,
    LtUVecI32x4,
    GtSVecI32x4,
    GtUVecI32x4,
    LeSVecI32x4,
    LeUVecI32x4,
    GeSVecI32x4,
    GeUVecI32x4,
    EqVecF32x4,
    NeVecF32x4,
    LtVecF32x4,
    GtVecF32x4,
    LeVecF32x4,
    GeVecF32x4,
    EqVecF64x2,
    NeVecF64x2,
    LtVecF64x2,
    GtVecF64x2,
    LeVecF64x2,
    GeVecF64x2,
    NotVec128,
    AndVec128,
    OrVec128,
    XorVec128,
    AndNotVec128,
    BitselectVec128,
    NegVecI8x16,
    AnyTrueVecI8x16,
    AllTrueVecI8x16,
    ShlVecI8x16,
    ShrSVecI8x16,
    ShrUVecI8x16,
    AddVecI8x16,
    AddSatSVecI8x16,
    AddSatUVecI8x16,
    SubVecI8x16,
    SubSatSVecI8x16,
    SubSatUVecI8x16,
    MulVecI8x16,
    MinSVecI8x16,
    MinUVecI8x16,
    MaxSVecI8x16,
    MaxUVecI8x16,
    NegVecI16x8,
    AnyTrueVecI16x8,
    AllTrueVecI16x8,
    ShlVecI16x8,
    ShrSVecI16x8,
    ShrUVecI16x8,
    AddVecI16x8,
    AddSatSVecI16x8,
    AddSatUVecI16x8,
    SubVecI16x8,
    SubSatSVecI16x8,
    SubSatUVecI16x8,
    MulVecI16x8,
    MinSVecI16x8,
    MinUVecI16x8,
    MaxSVecI16x8,
    MaxUVecI16x8,
    DotSVecI16x8ToVecI32x4,
    NegVecI32x4,
    AnyTrueVecI32x4,
    AllTrueVecI32x4,
    ShlVecI32x4,
    ShrSVecI32x4,
    ShrUVecI32x4,
    AddVecI32x4,
    SubVecI32x4,
    MulVecI32x4,
    MinSVecI32x4,
    MinUVecI32x4,
    MaxSVecI32x4,
    MaxUVecI32x4,
    NegVecI64x2,
    AnyTrueVecI64x2,
    AllTrueVecI64x2,
    ShlVecI64x2,
    ShrSVecI64x2,
    ShrUVecI64x2,
    AddVecI64x2,
    SubVecI64x2,
    AbsVecF32x4,
    NegVecF32x4,
    SqrtVecF32x4,
    QFMAVecF32x4,
    QFMSVecF32x4,
    AddVecF32x4,
    SubVecF32x4,
    MulVecF32x4,
    DivVecF32x4,
    MinVecF32x4,
    MaxVecF32x4,
    AbsVecF64x2,
    NegVecF64x2,
    SqrtVecF64x2,
    QFMAVecF64x2,
    QFMSVecF64x2,
    AddVecF64x2,
    SubVecF64x2,
    MulVecF64x2,
    DivVecF64x2,
    MinVecF64x2,
    MaxVecF64x2,
    TruncSatSVecF32x4ToVecI32x4,
    TruncSatUVecF32x4ToVecI32x4,
    TruncSatSVecF64x2ToVecI64x2,
    TruncSatUVecF64x2ToVecI64x2,
    ConvertSVecI32x4ToVecF32x4,
    ConvertUVecI32x4ToVecF32x4,
    ConvertSVecI64x2ToVecF64x2,
    ConvertUVecI64x2ToVecF64x2,
    LoadSplatVec8x16,
    LoadSplatVec16x8,
    LoadSplatVec32x4,
    LoadSplatVec64x2,
    LoadExtSVec8x8ToVecI16x8,
    LoadExtUVec8x8ToVecI16x8,
    LoadExtSVec16x4ToVecI32x4,
    LoadExtUVec16x4ToVecI32x4,
    LoadExtSVec32x2ToVecI64x2,
    LoadExtUVec32x2ToVecI64x2,
    NarrowSVecI16x8ToVecI8x16,
    NarrowUVecI16x8ToVecI8x16,
    NarrowSVecI32x4ToVecI16x8,
    NarrowUVecI32x4ToVecI16x8,
    WidenLowSVecI8x16ToVecI16x8,
    WidenHighSVecI8x16ToVecI16x8,
    WidenLowUVecI8x16ToVecI16x8,
    WidenHighUVecI8x16ToVecI16x8,
    WidenLowSVecI16x8ToVecI32x4,
    WidenHighSVecI16x8ToVecI32x4,
    WidenLowUVecI16x8ToVecI32x4,
    WidenHighUVecI16x8ToVecI32x4,
    SwizzleVec8x16
  }

  const ClzInt32: Operations;
  const CtzInt32: Operations;
  const PopcntInt32: Operations;
  const NegFloat32: Operations;
  const AbsFloat32: Operations;
  const CeilFloat32: Operations;
  const FloorFloat32: Operations;
  const TruncFloat32: Operations;
  const NearestFloat32: Operations;
  const SqrtFloat32: Operations;
  const EqZInt32: Operations;
  const ClzInt64: Operations;
  const CtzInt64: Operations;
  const PopcntInt64: Operations;
  const NegFloat64: Operations;
  const AbsFloat64: Operations;
  const CeilFloat64: Operations;
  const FloorFloat64: Operations;
  const TruncFloat64: Operations;
  const NearestFloat64: Operations;
  const SqrtFloat64: Operations;
  const EqZInt64: Operations;
  const ExtendSInt32: Operations;
  const ExtendUInt32: Operations;
  const WrapInt64: Operations;
  const TruncSFloat32ToInt32: Operations;
  const TruncSFloat32ToInt64: Operations;
  const TruncUFloat32ToInt32: Operations;
  const TruncUFloat32ToInt64: Operations;
  const TruncSFloat64ToInt32: Operations;
  const TruncSFloat64ToInt64: Operations;
  const TruncUFloat64ToInt32: Operations;
  const TruncUFloat64ToInt64: Operations;
  const TruncSatSFloat32ToInt32: Operations;
  const TruncSatSFloat32ToInt64: Operations;
  const TruncSatUFloat32ToInt32: Operations;
  const TruncSatUFloat32ToInt64: Operations;
  const TruncSatSFloat64ToInt32: Operations;
  const TruncSatSFloat64ToInt64: Operations;
  const TruncSatUFloat64ToInt32: Operations;
  const TruncSatUFloat64ToInt64: Operations;
  const ReinterpretFloat32: Operations;
  const ReinterpretFloat64: Operations;
  const ConvertSInt32ToFloat32: Operations;
  const ConvertSInt32ToFloat64: Operations;
  const ConvertUInt32ToFloat32: Operations;
  const ConvertUInt32ToFloat64: Operations;
  const ConvertSInt64ToFloat32: Operations;
  const ConvertSInt64ToFloat64: Operations;
  const ConvertUInt64ToFloat32: Operations;
  const ConvertUInt64ToFloat64: Operations;
  const PromoteFloat32: Operations;
  const DemoteFloat64: Operations;
  const ReinterpretInt32: Operations;
  const ReinterpretInt64: Operations;
  const ExtendS8Int32: Operations;
  const ExtendS16Int32: Operations;
  const ExtendS8Int64: Operations;
  const ExtendS16Int64: Operations;
  const ExtendS32Int64: Operations;
  const AddInt32: Operations;
  const SubInt32: Operations;
  const MulInt32: Operations;
  const DivSInt32: Operations;
  const DivUInt32: Operations;
  const RemSInt32: Operations;
  const RemUInt32: Operations;
  const AndInt32: Operations;
  const OrInt32: Operations;
  const XorInt32: Operations;
  const ShlInt32: Operations;
  const ShrUInt32: Operations;
  const ShrSInt32: Operations;
  const RotLInt32: Operations;
  const RotRInt32: Operations;
  const EqInt32: Operations;
  const NeInt32: Operations;
  const LtSInt32: Operations;
  const LtUInt32: Operations;
  const LeSInt32: Operations;
  const LeUInt32: Operations;
  const GtSInt32: Operations;
  const GtUInt32: Operations;
  const GeSInt32: Operations;
  const GeUInt32: Operations;
  const AddInt64: Operations;
  const SubInt64: Operations;
  const MulInt64: Operations;
  const DivSInt64: Operations;
  const DivUInt64: Operations;
  const RemSInt64: Operations;
  const RemUInt64: Operations;
  const AndInt64: Operations;
  const OrInt64: Operations;
  const XorInt64: Operations;
  const ShlInt64: Operations;
  const ShrUInt64: Operations;
  const ShrSInt64: Operations;
  const RotLInt64: Operations;
  const RotRInt64: Operations;
  const EqInt64: Operations;
  const NeInt64: Operations;
  const LtSInt64: Operations;
  const LtUInt64: Operations;
  const LeSInt64: Operations;
  const LeUInt64: Operations;
  const GtSInt64: Operations;
  const GtUInt64: Operations;
  const GeSInt64: Operations;
  const GeUInt64: Operations;
  const AddFloat32: Operations;
  const SubFloat32: Operations;
  const MulFloat32: Operations;
  const DivFloat32: Operations;
  const CopySignFloat32: Operations;
  const MinFloat32: Operations;
  const MaxFloat32: Operations;
  const EqFloat32: Operations;
  const NeFloat32: Operations;
  const LtFloat32: Operations;
  const LeFloat32: Operations;
  const GtFloat32: Operations;
  const GeFloat32: Operations;
  const AddFloat64: Operations;
  const SubFloat64: Operations;
  const MulFloat64: Operations;
  const DivFloat64: Operations;
  const CopySignFloat64: Operations;
  const MinFloat64: Operations;
  const MaxFloat64: Operations;
  const EqFloat64: Operations;
  const NeFloat64: Operations;
  const LtFloat64: Operations;
  const LeFloat64: Operations;
  const GtFloat64: Operations;
  const GeFloat64: Operations;
  const AtomicRMWAdd: Operations;
  const AtomicRMWSub: Operations;
  const AtomicRMWAnd: Operations;
  const AtomicRMWOr: Operations;
  const AtomicRMWXor: Operations;
  const AtomicRMWXchg: Operations;
  const SplatVecI8x16: Operations;
  const ExtractLaneSVecI8x16: Operations;
  const ExtractLaneUVecI8x16: Operations;
  const ReplaceLaneVecI8x16: Operations;
  const SplatVecI16x8: Operations;
  const ExtractLaneSVecI16x8: Operations;
  const ExtractLaneUVecI16x8: Operations;
  const ReplaceLaneVecI16x8: Operations;
  const SplatVecI32x4: Operations;
  const ExtractLaneVecI32x4: Operations;
  const ReplaceLaneVecI32x4: Operations;
  const SplatVecI64x2: Operations;
  const ExtractLaneVecI64x2: Operations;
  const ReplaceLaneVecI64x2: Operations;
  const SplatVecF32x4: Operations;
  const ExtractLaneVecF32x4: Operations;
  const ReplaceLaneVecF32x4: Operations;
  const SplatVecF64x2: Operations;
  const ExtractLaneVecF64x2: Operations;
  const ReplaceLaneVecF64x2: Operations;
  const EqVecI8x16: Operations;
  const NeVecI8x16: Operations;
  const LtSVecI8x16: Operations;
  const LtUVecI8x16: Operations;
  const GtSVecI8x16: Operations;
  const GtUVecI8x16: Operations;
  const LeSVecI8x16: Operations;
  const LeUVecI8x16: Operations;
  const GeSVecI8x16: Operations;
  const GeUVecI8x16: Operations;
  const EqVecI16x8: Operations;
  const NeVecI16x8: Operations;
  const LtSVecI16x8: Operations;
  const LtUVecI16x8: Operations;
  const GtSVecI16x8: Operations;
  const GtUVecI16x8: Operations;
  const LeSVecI16x8: Operations;
  const LeUVecI16x8: Operations;
  const GeSVecI16x8: Operations;
  const GeUVecI16x8: Operations;
  const EqVecI32x4: Operations;
  const NeVecI32x4: Operations;
  const LtSVecI32x4: Operations;
  const LtUVecI32x4: Operations;
  const GtSVecI32x4: Operations;
  const GtUVecI32x4: Operations;
  const LeSVecI32x4: Operations;
  const LeUVecI32x4: Operations;
  const GeSVecI32x4: Operations;
  const GeUVecI32x4: Operations;
  const EqVecF32x4: Operations;
  const NeVecF32x4: Operations;
  const LtVecF32x4: Operations;
  const GtVecF32x4: Operations;
  const LeVecF32x4: Operations;
  const GeVecF32x4: Operations;
  const EqVecF64x2: Operations;
  const NeVecF64x2: Operations;
  const LtVecF64x2: Operations;
  const GtVecF64x2: Operations;
  const LeVecF64x2: Operations;
  const GeVecF64x2: Operations;
  const NotVec128: Operations;
  const AndVec128: Operations;
  const OrVec128: Operations;
  const XorVec128: Operations;
  const AndNotVec128: Operations;
  const BitselectVec128: Operations;
  const NegVecI8x16: Operations;
  const AnyTrueVecI8x16: Operations;
  const AllTrueVecI8x16: Operations;
  const ShlVecI8x16: Operations;
  const ShrSVecI8x16: Operations;
  const ShrUVecI8x16: Operations;
  const AddVecI8x16: Operations;
  const AddSatSVecI8x16: Operations;
  const AddSatUVecI8x16: Operations;
  const SubVecI8x16: Operations;
  const SubSatSVecI8x16: Operations;
  const SubSatUVecI8x16: Operations;
  const MulVecI8x16: Operations;
  const MinSVecI8x16: Operations;
  const MinUVecI8x16: Operations;
  const MaxSVecI8x16: Operations;
  const MaxUVecI8x16: Operations;
  const NegVecI16x8: Operations;
  const AnyTrueVecI16x8: Operations;
  const AllTrueVecI16x8: Operations;
  const ShlVecI16x8: Operations;
  const ShrSVecI16x8: Operations;
  const ShrUVecI16x8: Operations;
  const AddVecI16x8: Operations;
  const AddSatSVecI16x8: Operations;
  const AddSatUVecI16x8: Operations;
  const SubVecI16x8: Operations;
  const SubSatSVecI16x8: Operations;
  const SubSatUVecI16x8: Operations;
  const MulVecI16x8: Operations;
  const MinSVecI16x8: Operations;
  const MinUVecI16x8: Operations;
  const MaxSVecI16x8: Operations;
  const MaxUVecI16x8: Operations;
  const DotSVecI16x8ToVecI32x4: Operations;
  const NegVecI32x4: Operations;
  const AnyTrueVecI32x4: Operations;
  const AllTrueVecI32x4: Operations;
  const ShlVecI32x4: Operations;
  const ShrSVecI32x4: Operations;
  const ShrUVecI32x4: Operations;
  const AddVecI32x4: Operations;
  const SubVecI32x4: Operations;
  const MulVecI32x4: Operations;
  const MinSVecI32x4: Operations;
  const MinUVecI32x4: Operations;
  const MaxSVecI32x4: Operations;
  const MaxUVecI32x4: Operations;
  const NegVecI64x2: Operations;
  const AnyTrueVecI64x2: Operations;
  const AllTrueVecI64x2: Operations;
  const ShlVecI64x2: Operations;
  const ShrSVecI64x2: Operations;
  const ShrUVecI64x2: Operations;
  const AddVecI64x2: Operations;
  const SubVecI64x2: Operations;
  const AbsVecF32x4: Operations;
  const NegVecF32x4: Operations;
  const SqrtVecF32x4: Operations;
  const QFMAVecF32x4: Operations;
  const QFMSVecF32x4: Operations;
  const AddVecF32x4: Operations;
  const SubVecF32x4: Operations;
  const MulVecF32x4: Operations;
  const DivVecF32x4: Operations;
  const MinVecF32x4: Operations;
  const MaxVecF32x4: Operations;
  const AbsVecF64x2: Operations;
  const NegVecF64x2: Operations;
  const SqrtVecF64x2: Operations;
  const QFMAVecF64x2: Operations;
  const QFMSVecF64x2: Operations;
  const AddVecF64x2: Operations;
  const SubVecF64x2: Operations;
  const MulVecF64x2: Operations;
  const DivVecF64x2: Operations;
  const MinVecF64x2: Operations;
  const MaxVecF64x2: Operations;
  const TruncSatSVecF32x4ToVecI32x4: Operations;
  const TruncSatUVecF32x4ToVecI32x4: Operations;
  const TruncSatSVecF64x2ToVecI64x2: Operations;
  const TruncSatUVecF64x2ToVecI64x2: Operations;
  const ConvertSVecI32x4ToVecF32x4: Operations;
  const ConvertUVecI32x4ToVecF32x4: Operations;
  const ConvertSVecI64x2ToVecF64x2: Operations;
  const ConvertUVecI64x2ToVecF64x2: Operations;
  const LoadSplatVec8x16: Operations;
  const LoadSplatVec16x8: Operations;
  const LoadSplatVec32x4: Operations;
  const LoadSplatVec64x2: Operations;
  const LoadExtSVec8x8ToVecI16x8: Operations;
  const LoadExtUVec8x8ToVecI16x8: Operations;
  const LoadExtSVec16x4ToVecI32x4: Operations;
  const LoadExtUVec16x4ToVecI32x4: Operations;
  const LoadExtSVec32x2ToVecI64x2: Operations;
  const LoadExtUVec32x2ToVecI64x2: Operations;
  const NarrowSVecI16x8ToVecI8x16: Operations;
  const NarrowUVecI16x8ToVecI8x16: Operations;
  const NarrowSVecI32x4ToVecI16x8: Operations;
  const NarrowUVecI32x4ToVecI16x8: Operations;
  const WidenLowSVecI8x16ToVecI16x8: Operations;
  const WidenHighSVecI8x16ToVecI16x8: Operations;
  const WidenLowUVecI8x16ToVecI16x8: Operations;
  const WidenHighUVecI8x16ToVecI16x8: Operations;
  const WidenLowSVecI16x8ToVecI32x4: Operations;
  const WidenHighSVecI16x8ToVecI32x4: Operations;
  const WidenLowUVecI16x8ToVecI32x4: Operations;
  const WidenHighUVecI16x8ToVecI32x4: Operations;
  const SwizzleVec8x16: Operations;

  type ExpressionRef = number;
  type FunctionRef = number;
  type GlobalRef = number;
  type ExportRef = number;
  type EventRef = number;

  class Module {
    constructor();
    readonly ptr: number;
    block(label: string, children: ExpressionRef[], resultType?: Type): ExpressionRef;
    if(condition: ExpressionRef, ifTrue: ExpressionRef, ifFalse?: ExpressionRef): ExpressionRef;
    loop(label: string, body: ExpressionRef): ExpressionRef;
    br(label: string, condition?: ExpressionRef, value?: ExpressionRef): ExpressionRef;
    br_if(label: string, condition?: ExpressionRef, value?: ExpressionRef): ExpressionRef;
    switch(labels: string[], defaultLabel: string, condition: ExpressionRef, value?: ExpressionRef): ExpressionRef;
    call(name: string, operands: ExpressionRef[], returnType: Type): ExpressionRef;
    return_call(name: string, operands: ExpressionRef[], returnType: Type): ExpressionRef;
    call_indirect(target: ExpressionRef, operands: ExpressionRef[], params: Type, results: Type): ExpressionRef;
    return_call_indirect(target: ExpressionRef, operands: ExpressionRef[], params: Type, results: Type): ExpressionRef;
    local: {
      get(index: number, type: Type): ExpressionRef;
      set(index: number, value: ExpressionRef): ExpressionRef;
      tee(index: number, value: ExpressionRef, type: Type): ExpressionRef;
    };
    global: {
      get(name: string, type: Type): ExpressionRef;
      set(name: string, value: ExpressionRef): ExpressionRef;
    };
    memory: {
      size(): ExpressionRef;
      grow(value: ExpressionRef): ExpressionRef;
      init(segment: number, dest: ExpressionRef, offset: ExpressionRef, size: ExpressionRef): ExpressionRef;
      copy(dest: ExpressionRef, source: ExpressionRef, size: ExpressionRef): ExpressionRef;
      fill(dest: ExpressionRef, value: ExpressionRef, size: ExpressionRef): ExpressionRef;
      atomic: {
        notify(ptr: ExpressionRef, notifyCount: ExpressionRef): ExpressionRef;
        wait32(ptr: ExpressionRef, expected: ExpressionRef, timeout: ExpressionRef): ExpressionRef;
        wait64(ptr: ExpressionRef, expected: ExpressionRef, timeout: ExpressionRef): ExpressionRef;
      }
    };
    data: {
      drop(segment: number): ExpressionRef;
    };
    i32: {
      load(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      load8_s(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      load8_u(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      load16_s(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      load16_u(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      store(offset: number, align: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
      store8(offset: number, align: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
      store16(offset: number, align: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
      const(value: number): ExpressionRef;
      clz(value: ExpressionRef): ExpressionRef;
      ctz(value: ExpressionRef): ExpressionRef;
      popcnt(value: ExpressionRef): ExpressionRef;
      eqz(value: ExpressionRef): ExpressionRef;
      trunc_s: {
        f32(value: ExpressionRef): ExpressionRef;
        f64(value: ExpressionRef): ExpressionRef;
      };
      trunc_u: {
        f32(value: ExpressionRef): ExpressionRef;
        f64(value: ExpressionRef): ExpressionRef;
      };
      trunc_s_sat: {
        f32(value: ExpressionRef): ExpressionRef;
        f64(value: ExpressionRef): ExpressionRef;
      };
      trunc_u_sat: {
        f32(value: ExpressionRef): ExpressionRef;
        f64(value: ExpressionRef): ExpressionRef;
      };
      reinterpret(value: ExpressionRef): ExpressionRef;
      extend8_s(value: ExpressionRef): ExpressionRef;
      extend16_s(value: ExpressionRef): ExpressionRef;
      wrap(value: ExpressionRef): ExpressionRef;
      add(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      sub(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      mul(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      div_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      div_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      rem_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      rem_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      and(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      or(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      xor(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      shl(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      shr_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      shr_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      rotl(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      rotr(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      eq(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ne(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      lt_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      lt_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      le_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      le_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      gt_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      gt_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ge_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ge_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      atomic: {
        load(offset: number, ptr: ExpressionRef): ExpressionRef;
        load8_u(offset: number, ptr: ExpressionRef): ExpressionRef;
        load16_u(offset: number, ptr: ExpressionRef): ExpressionRef;
        store(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
        store8(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
        store16(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
        rmw: {
          add(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          sub(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          and(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          or(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          xor(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          xchg(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          cmpxchg(offset: number, ptr: ExpressionRef, expected: ExpressionRef, replacement: ExpressionRef): ExpressionRef;
        },
        rmw8_u: {
          add(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          sub(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          and(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          or(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          xor(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          xchg(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          cmpxchg(offset: number, ptr: ExpressionRef, expected: ExpressionRef, replacement: ExpressionRef): ExpressionRef;
        },
        rmw16_u: {
          add(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          sub(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          and(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          or(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          xor(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          xchg(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          cmpxchg(offset: number, ptr: ExpressionRef, expected: ExpressionRef, replacement: ExpressionRef): ExpressionRef;
        },
      },
      pop(): ExpressionRef;
    };
    i64: {
      load(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      load8_s(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      load8_u(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      load16_s(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      load16_u(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      load32_s(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      load32_u(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      store(offset: number, align: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
      store8(offset: number, align: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
      store16(offset: number, align: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
      store32(offset: number, align: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
      const(low: number, high: number): ExpressionRef;
      clz(value: ExpressionRef): ExpressionRef;
      ctz(value: ExpressionRef): ExpressionRef;
      popcnt(value: ExpressionRef): ExpressionRef;
      eqz(value: ExpressionRef): ExpressionRef;
      trunc_s: {
        f32(value: ExpressionRef): ExpressionRef;
        f64(value: ExpressionRef): ExpressionRef;
      };
      trunc_u: {
        f32(value: ExpressionRef): ExpressionRef;
        f64(value: ExpressionRef): ExpressionRef;
      };
      trunc_s_sat: {
        f32(value: ExpressionRef): ExpressionRef;
        f64(value: ExpressionRef): ExpressionRef;
      };
      trunc_u_sat: {
        f32(value: ExpressionRef): ExpressionRef;
        f64(value: ExpressionRef): ExpressionRef;
      };
      reinterpret(value: ExpressionRef): ExpressionRef;
      extend8_s(value: ExpressionRef): ExpressionRef;
      extend16_s(value: ExpressionRef): ExpressionRef;
      extend32_s(value: ExpressionRef): ExpressionRef;
      extend_s(value: ExpressionRef): ExpressionRef;
      extend_u(value: ExpressionRef): ExpressionRef;
      add(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      sub(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      mul(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      div_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      div_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      rem_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      rem_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      and(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      or(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      xor(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      shl(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      shr_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      shr_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      rotl(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      rotr(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      eq(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ne(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      lt_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      lt_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      le_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      le_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      gt_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      gt_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ge_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ge_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      atomic: {
        load(offset: number, ptr: ExpressionRef): ExpressionRef;
        load8_u(offset: number, ptr: ExpressionRef): ExpressionRef;
        load16_u(offset: number, ptr: ExpressionRef): ExpressionRef;
        load32_u(offset: number, ptr: ExpressionRef): ExpressionRef;
        store(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
        store8(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
        store16(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
        store32(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
        rmw: {
          add(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          sub(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          and(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          or(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          xor(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          xchg(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          cmpxchg(offset: number, ptr: ExpressionRef, expected: ExpressionRef, replacement: ExpressionRef): ExpressionRef;
        },
        rmw8_u: {
          add(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          sub(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          and(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          or(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          xor(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          xchg(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          cmpxchg(offset: number, ptr: ExpressionRef, expected: ExpressionRef, replacement: ExpressionRef): ExpressionRef;
        },
        rmw16_u: {
          add(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          sub(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          and(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          or(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          xor(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          xchg(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          cmpxchg(offset: number, ptr: ExpressionRef, expected: ExpressionRef, replacement: ExpressionRef): ExpressionRef;
        },
        rmw32_u: {
          add(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          sub(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          and(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          or(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          xor(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          xchg(offset: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
          cmpxchg(offset: number, ptr: ExpressionRef, expected: ExpressionRef, replacement: ExpressionRef): ExpressionRef;
        },
      },
      pop(): ExpressionRef;
    };
    f32: {
      load(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      store(offset: number, align: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
      const(value: number): ExpressionRef;
      const_bits(value: number): ExpressionRef;
      neg(value: ExpressionRef): ExpressionRef;
      abs(value: ExpressionRef): ExpressionRef;
      ceil(value: ExpressionRef): ExpressionRef;
      floor(value: ExpressionRef): ExpressionRef;
      trunc(value: ExpressionRef): ExpressionRef;
      nearest(value: ExpressionRef): ExpressionRef;
      sqrt(value: ExpressionRef): ExpressionRef;
      reinterpret(value: ExpressionRef): ExpressionRef;
      convert_s: {
        i32(value: ExpressionRef): ExpressionRef;
        i64(value: ExpressionRef): ExpressionRef;
      };
      convert_u: {
        i32(value: ExpressionRef): ExpressionRef;
        i64(value: ExpressionRef): ExpressionRef;
      };
      demote(value: ExpressionRef): ExpressionRef;
      add(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      sub(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      mul(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      div(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      copysign(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      min(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      max(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      eq(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ne(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      lt(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      le(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      gt(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ge(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      pop(): ExpressionRef;
    };
    f64: {
      load(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      store(offset: number, align: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
      const(value: number): ExpressionRef;
      const_bits(low: number, high: number): ExpressionRef;
      neg(value: ExpressionRef): ExpressionRef;
      abs(value: ExpressionRef): ExpressionRef;
      ceil(value: ExpressionRef): ExpressionRef;
      floor(value: ExpressionRef): ExpressionRef;
      trunc(value: ExpressionRef): ExpressionRef;
      nearest(value: ExpressionRef): ExpressionRef;
      sqrt(value: ExpressionRef): ExpressionRef;
      reinterpret(value: ExpressionRef): ExpressionRef;
      convert_s: {
        i32(value: ExpressionRef): ExpressionRef;
        i64(value: ExpressionRef): ExpressionRef;
      };
      convert_u: {
        i32(value: ExpressionRef): ExpressionRef;
        i64(value: ExpressionRef): ExpressionRef;
      };
      promote(value: ExpressionRef): ExpressionRef;
      add(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      sub(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      mul(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      div(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      copysign(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      min(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      max(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      eq(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ne(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      lt(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      le(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      gt(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ge(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      pop(): ExpressionRef;
    };
    v128: {
      load(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      store(offset: number, align: number, ptr: ExpressionRef, value: ExpressionRef): ExpressionRef;
      const(value: number): ExpressionRef;
      not(value: ExpressionRef): ExpressionRef;
      and(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      or(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      xor(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      andnot(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      bitselect(left: ExpressionRef, right: ExpressionRef, cond: ExpressionRef): ExpressionRef;
      pop(): ExpressionRef;
    };
    i8x16: {
      splat(value: ExpressionRef): ExpressionRef;
      extract_lane_s(vec: ExpressionRef, index: ExpressionRef): ExpressionRef;
      extract_lane_u(vec: ExpressionRef, index: ExpressionRef): ExpressionRef;
      replace_lane(vec: ExpressionRef, index: ExpressionRef, value: ExpressionRef): ExpressionRef;
      eq(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ne(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      lt_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      lt_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      gt_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      gt_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      le_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      le_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ge_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ge_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      neg(value: ExpressionRef): ExpressionRef;
      any_true(value: ExpressionRef): ExpressionRef;
      all_true(value: ExpressionRef): ExpressionRef;
      shl(vec: ExpressionRef, shift: ExpressionRef): ExpressionRef;
      shr_s(vec: ExpressionRef, shift: ExpressionRef): ExpressionRef;
      shr_u(vec: ExpressionRef, shift: ExpressionRef): ExpressionRef;
      add(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      add_saturate_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      add_saturate_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      sub(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      sub_saturate_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      sub_saturate_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      mul(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      min_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      min_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      max_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      max_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      avgr_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      narrow_i16x8_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      narrow_i16x8_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
    };
    i16x8: {
      splat(value: ExpressionRef): ExpressionRef;
      extract_lane_s(vec: ExpressionRef, index: ExpressionRef): ExpressionRef;
      extract_lane_u(vec: ExpressionRef, index: ExpressionRef): ExpressionRef;
      replace_lane(vec: ExpressionRef, index: ExpressionRef, value: ExpressionRef): ExpressionRef;
      eq(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ne(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      lt_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      lt_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      gt_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      gt_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      le_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      le_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ge_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ge_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      neg(value: ExpressionRef): ExpressionRef;
      any_true(value: ExpressionRef): ExpressionRef;
      all_true(value: ExpressionRef): ExpressionRef;
      shl(vec: ExpressionRef, shift: ExpressionRef): ExpressionRef;
      shr_s(vec: ExpressionRef, shift: ExpressionRef): ExpressionRef;
      shr_u(vec: ExpressionRef, shift: ExpressionRef): ExpressionRef;
      add(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      add_saturate_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      add_saturate_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      sub(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      sub_saturate_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      sub_saturate_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      mul(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      min_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      min_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      max_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      max_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      avgr_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      narrow_i32x4_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      narrow_i32x4_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      widen_low_i8x16_s(value: ExpressionRef): ExpressionRef;
      widen_high_i8x16_s(value: ExpressionRef): ExpressionRef;
      widen_low_i8x16_u(value: ExpressionRef): ExpressionRef;
      widen_high_i8x16_u(value: ExpressionRef): ExpressionRef;
      load8x8_s(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      load8x8_u(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
    };
    i32x4: {
      splat(value: ExpressionRef): ExpressionRef;
      extract_lane(vec: ExpressionRef, index: ExpressionRef): ExpressionRef;
      replace_lane(vec: ExpressionRef, index: ExpressionRef, value: ExpressionRef): ExpressionRef;
      eq(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ne(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      lt_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      lt_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      gt_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      gt_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      le_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      le_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ge_s(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ge_u(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      neg(value: ExpressionRef): ExpressionRef;
      any_true(value: ExpressionRef): ExpressionRef;
      all_true(value: ExpressionRef): ExpressionRef;
      shl(vec: ExpressionRef, shift: ExpressionRef): ExpressionRef;
      shr_s(vec: ExpressionRef, shift: ExpressionRef): ExpressionRef;
      shr_u(vec: ExpressionRef, shift: ExpressionRef): ExpressionRef;
      add(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      sub(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      mul(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      trunc_sat_f32x4_s(value: ExpressionRef): ExpressionRef;
      trunc_sat_f32x4_u(value: ExpressionRef): ExpressionRef;
      widen_low_i16x8_s(value: ExpressionRef): ExpressionRef;
      widen_high_i16x8_s(value: ExpressionRef): ExpressionRef;
      widen_low_i16x8_u(value: ExpressionRef): ExpressionRef;
      widen_high_i16x8_u(value: ExpressionRef): ExpressionRef;
      load16x4_s(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      load16x4_u(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
    };
    i64x2: {
      splat(value: ExpressionRef): ExpressionRef;
      extract_lane(vec: ExpressionRef, index: ExpressionRef): ExpressionRef;
      replace_lane(vec: ExpressionRef, index: ExpressionRef, value: ExpressionRef): ExpressionRef;
      neg(value: ExpressionRef): ExpressionRef;
      any_true(value: ExpressionRef): ExpressionRef;
      all_true(value: ExpressionRef): ExpressionRef;
      shl(vec: ExpressionRef, shift: ExpressionRef): ExpressionRef;
      shr_s(vec: ExpressionRef, shift: ExpressionRef): ExpressionRef;
      shr_u(vec: ExpressionRef, shift: ExpressionRef): ExpressionRef;
      add(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      sub(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      trunc_sat_f64x2_s(value: ExpressionRef): ExpressionRef;
      trunc_sat_f64x2_u(value: ExpressionRef): ExpressionRef;
      load32x2_s(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
      load32x2_u(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
    };
    f32x4: {
      splat(value: ExpressionRef): ExpressionRef;
      extract_lane(vec: ExpressionRef, index: ExpressionRef): ExpressionRef;
      replace_lane(vec: ExpressionRef, index: ExpressionRef, value: ExpressionRef): ExpressionRef;
      eq(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ne(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      lt(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      gt(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      le(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ge(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      abs(value: ExpressionRef): ExpressionRef;
      neg(value: ExpressionRef): ExpressionRef;
      sqrt(value: ExpressionRef): ExpressionRef;
      qfma(a: ExpressionRef, b: ExpressionRef, c: ExpressionRef): ExpressionRef;
      qfms(a: ExpressionRef, b: ExpressionRef, c: ExpressionRef): ExpressionRef;
      add(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      sub(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      mul(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      div(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      min(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      max(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      convert_i32x4_s(value: ExpressionRef): ExpressionRef;
      convert_i32x4_u(value: ExpressionRef): ExpressionRef;
    };
    f64x2: {
      splat(value: ExpressionRef): ExpressionRef;
      extract_lane(vec: ExpressionRef, index: ExpressionRef): ExpressionRef;
      replace_lane(vec: ExpressionRef, index: ExpressionRef, value: ExpressionRef): ExpressionRef;
      eq(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ne(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      lt(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      gt(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      le(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      ge(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      abs(value: ExpressionRef): ExpressionRef;
      neg(value: ExpressionRef): ExpressionRef;
      sqrt(value: ExpressionRef): ExpressionRef;
      qfma(a: ExpressionRef, b: ExpressionRef, c: ExpressionRef): ExpressionRef;
      qfms(a: ExpressionRef, b: ExpressionRef, c: ExpressionRef): ExpressionRef;
      add(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      sub(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      mul(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      div(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      min(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      max(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      convert_i64x2_s(value: ExpressionRef): ExpressionRef;
      convert_i64x2_u(value: ExpressionRef): ExpressionRef;
    };
    v8x16: {
      shuffle(left: ExpressionRef, right: ExpressionRef, mask: number[]): ExpressionRef;
      swizzle(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
      load_splat(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
    };
    v16x8: {
      load_splat(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
    };
    v32x4: {
      load_splat(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
    };
    v64x2: {
      load_splat(offset: number, align: number, ptr: ExpressionRef): ExpressionRef;
    };
    funcref: {
      pop(): ExpressionRef;
    };
    externref: {
      pop(): ExpressionRef;
    };
    exnref: {
      pop(): ExpressionRef;
    };
    anyref: {
      pop(): ExpressionRef;
    };
    eqref: {
      pop(): ExpressionRef;
    };
    i31ref: {
      pop(): ExpressionRef;
    };
    ref: {
      null(type: Type): ExpressionRef;
      is_null(value: ExpressionRef): ExpressionRef;
      func(name: string, type: Type): ExpressionRef;
      eq(left: ExpressionRef, right: ExpressionRef): ExpressionRef;
    };
    i31: {
      'new'(value: ExpressionRef): ExpressionRef;
      get_s(i31: ExpressionRef): ExpressionRef;
      get_u(i31: ExpressionRef): ExpressionRef;
    }
    atomic: {
      fence(): ExpressionRef;
    };
    tuple: {
      make(elements: ExportRef[]): ExpressionRef;
      extract(tuple: ExpressionRef, index: number): ExpressionRef;
    };
    try(body: ExpressionRef, catchBody: ExpressionRef): ExpressionRef;
    throw(event: string, operands: ExpressionRef[]): ExpressionRef;
    rethrow(exnref: ExpressionRef): ExpressionRef;
    br_on_exn(label: string, event: string, exnref: ExpressionRef): ExpressionRef;
    select(condition: ExpressionRef, ifTrue: ExpressionRef, ifFalse: ExpressionRef, type?: Type): ExpressionRef;
    drop(value: ExpressionRef): ExpressionRef;
    return(value?: ExpressionRef): ExpressionRef;
    nop(): ExpressionRef;
    unreachable(): ExpressionRef;
    addFunction(name: string, params: Type, results: Type, vars: Type[], body: ExpressionRef): FunctionRef;
    getFunction(name: string): FunctionRef;
    removeFunction(name: string): void;
    getNumFunctions(): number;
    getFunctionByIndex(index: number): FunctionRef;
    addGlobal(name: string, type: Type, mutable: boolean, init: ExpressionRef): GlobalRef;
    getGlobal(name: string): GlobalRef;
    removeGlobal(name: string): void;
    addEvent(name: string, attribute: number, params: Type, results: Type): EventRef;
    getEvent(name: string): EventRef;
    removeEvent(name: string): void;
    addFunctionImport(internalName: string, externalModuleName: string, externalBaseName: string, params: Type, results: Type): void;
    addTableImport(internalName: string, externalModuleName: string, externalBaseName: string): void;
    addMemoryImport(internalName: string, externalModuleName: string, externalBaseName: string): void;
    addGlobalImport(internalName: string, externalModuleName: string, externalBaseName: string, globalType: Type): void;
    addEventImport(internalName: string, externalModuleName: string, externalBaseName: string, attribute: number, params: Type, results: Type): void;
    addFunctionExport(internalName: string, externalName: string): ExportRef;
    addTableExport(internalName: string, externalName: string): ExportRef;
    addMemoryExport(internalName: string, externalName: string): ExportRef;
    addGlobalExport(internalName: string, externalName: string): ExportRef;
    removeExport(externalName: string): void;
    getNumExports(): number;
    getExportByIndex(index: number): ExportRef;
    setFunctionTable(initial: number, maximum: number, funcNames: number[], offset?: ExpressionRef): void;
    getFunctionTable(): { imported: boolean, segments: TableElement[] };
    setMemory(initial: number, maximum: number, exportName?: string | null, segments?: MemorySegment[] | null, flags?: number[] | null, shared?: boolean): void;
    getNumMemorySegments(): number;
    getMemorySegmentInfoByIndex(index: number): MemorySegmentInfo;
    setStart(start: FunctionRef): void;
    getFeatures(): Features;
    setFeatures(features: Features): void;
    addCustomSection(name: string, contents: Uint8Array): void;
    emitText(): string;
    emitStackIR(optimize?: boolean): string;
    emitAsmjs(): string;
    validate(): number;
    optimize(): void;
    optimizeFunction(func: string | FunctionRef): void;
    runPasses(passes: string[]): void;
    runPassesOnFunction(func: string | FunctionRef, passes: string[]): void;
    autoDrop(): void;
    dispose(): void;
    emitBinary(): Uint8Array;
    emitBinary(sourceMapUrl: string | null): { binary: Uint8Array; sourceMap: string | null; };
    interpret(): void;
    addDebugInfoFileName(filename: string): number;
    getDebugInfoFileName(index: number): string | null;
    setDebugLocation(func: FunctionRef, expr: ExpressionRef, fileIndex: number, lineNumber: number, columnNumber: number): void;
    copyExpression(expr: ExpressionRef): ExpressionRef;
  }

  interface MemorySegment {
    offset: ExpressionRef;
    data: Uint8Array;
    passive?: boolean;
  }

  interface TableElement {
    offset: ExpressionRef;
    names: string[];
  }

  function wrapModule(ptr: number): Module;

  function getExpressionId(expression: ExpressionRef): number;
  function getExpressionType(expression: ExpressionRef): Type;
  function getExpressionInfo(expression: ExpressionRef): ExpressionInfo;

  interface MemorySegmentInfo {
    offset: ExpressionRef;
    data: Uint8Array;
    passive: boolean;
  }

  interface ExpressionInfo {
    id: ExpressionIds;
    type: Type;
  }

  interface BlockInfo extends ExpressionInfo {
    name: string;
    children: ExpressionRef[];
  }

  interface IfInfo extends ExpressionInfo {
    condition: ExpressionRef;
    ifTrue: ExpressionRef;
    ifFalse: ExpressionRef;
  }

  interface LoopInfo extends ExpressionInfo {
    name: string;
    body: ExpressionRef;
  }

  interface BreakInfo extends ExpressionInfo {
    name: string;
    condition: ExpressionRef;
    value: ExpressionRef;
  }

  interface SwitchInfo extends ExpressionInfo {
    names: string[];
    defaultName: string | null;
    condition: ExpressionRef;
    value: ExpressionRef;
  }

  interface CallInfo extends ExpressionInfo {
    isReturn: boolean;
    target: string;
    operands: ExpressionRef[];
  }

  interface CallIndirectInfo extends ExpressionInfo {
    isReturn: boolean;
    target: ExpressionRef;
    operands: ExpressionRef[];
  }

  interface LocalGetInfo extends ExpressionInfo {
    index: number;
  }

  interface LocalSetInfo extends ExpressionInfo {
    isTee: boolean;
    index: number;
    value: ExpressionRef;
  }

  interface GlobalGetInfo extends ExpressionInfo {
    name: string;
  }

  interface GlobalSetInfo extends ExpressionInfo {
    name: string;
    value: ExpressionRef;
  }

  interface LoadInfo extends ExpressionInfo {
    isAtomic: boolean;
    isSigned: boolean;
    offset: number;
    bytes: number;
    align: number;
    ptr: ExpressionRef;
  }

  interface StoreInfo extends ExpressionInfo {
    isAtomic: boolean;
    offset: number;
    bytes: number;
    align: number;
    ptr: ExpressionRef;
    value: ExpressionRef;
  }

  interface ConstInfo extends ExpressionInfo {
    value: number | { low: number, high: number };
  }

  interface UnaryInfo extends ExpressionInfo {
    op: Operations;
    value: ExpressionRef;
  }

  interface BinaryInfo extends ExpressionInfo {
    op: Operations;
    left: ExpressionRef;
    right: ExpressionRef;
  }

  interface SelectInfo extends ExpressionInfo {
    ifTrue: ExpressionRef;
    ifFalse: ExpressionRef;
    condition: ExpressionRef;
  }

  interface DropInfo extends ExpressionInfo {
    value: ExpressionRef;
  }

  interface ReturnInfo extends ExpressionInfo {
    value: ExpressionRef;
  }

  interface NopInfo extends ExpressionInfo {
  }

  interface UnreachableInfo extends ExpressionInfo {
  }

  interface HostInfo extends ExpressionInfo {
    op: Operations;
    nameOperand: string | null;
    operands: ExpressionRef[];
  }

  interface AtomicRMWInfo extends ExpressionInfo {
    op: Operations;
    bytes: number;
    offset: number;
    ptr: ExpressionRef;
    value: ExpressionRef;
  }

  interface AtomicCmpxchgInfo extends ExpressionInfo {
    bytes: number;
    offset: number;
    ptr: ExpressionRef;
    expected: ExpressionRef;
    replacement: ExpressionRef;
  }

  interface AtomicWaitInfo extends ExpressionInfo {
    ptr: ExpressionRef;
    expected: ExpressionRef;
    timeout: ExpressionRef;
    expectedType: Type;
  }

  interface AtomicNotifyInfo extends ExpressionInfo {
    ptr: ExpressionRef;
    notifyCount: ExpressionRef;
  }

  interface AtomicFenceInfo extends ExpressionInfo {
    order: number;
  }

  interface SIMDExtractInfo extends ExpressionInfo {
    op: Operations;
    vec: ExpressionRef;
    index: ExpressionRef;
  }

  interface SIMDReplaceInfo extends ExpressionInfo {
    op: Operations;
    vec: ExpressionRef;
    index: ExpressionRef;
    value: ExpressionRef;
  }

  interface SIMDShuffleInfo extends ExpressionInfo {
    left: ExpressionRef;
    right: ExpressionRef;
    mask: number[];
  }

  interface SIMDTernaryInfo extends ExpressionInfo {
    op: Operations;
    a: ExpressionRef;
    b: ExpressionRef;
    c: ExpressionRef;
  }

  interface SIMDShiftInfo extends ExpressionInfo {
    op: Operations;
    vec: ExpressionRef;
    shift: ExpressionRef;
  }

  interface SIMDLoadInfo extends ExpressionInfo {
    op: Operations;
    offset: number;
    align: number;
    ptr: ExpressionRef;
  }

  interface MemoryInitInfo extends ExpressionInfo {
    segment: number;
    dest: ExpressionRef;
    offset: ExpressionRef;
    size: ExpressionRef;
  }

  interface MemoryDropInfo extends ExpressionInfo {
    segment: number;
  }

  interface MemoryCopyInfo extends ExpressionInfo {
    dest: ExpressionRef;
    source: ExpressionRef;
    size: ExpressionRef;
  }

  interface MemoryFillInfo extends ExpressionInfo {
    dest: ExpressionRef;
    value: ExpressionRef;
    size: ExpressionRef;
  }

  interface RefNullInfo extends ExpressionInfo {
  }

  interface RefIsNullInfo extends ExpressionInfo {
    value: ExpressionRef;
  }

  interface RefFuncInfo extends ExpressionInfo {
    func: string;
  }

  interface TryInfo extends ExpressionInfo {
    body: ExpressionRef;
    catchBody: ExpressionRef;
  }

  interface ThrowInfo extends ExpressionInfo {
    event: string;
    operands: ExpressionRef[];
  }

  interface RethrowInfo extends ExpressionInfo {
    exnref: ExpressionRef;
  }

  interface BrOnExnInfo extends ExpressionInfo {
    name: string;
    event: string;
    exnref: ExpressionRef;
  }

  interface PopInfo extends ExpressionInfo {
  }

  interface PushInfo extends ExpressionInfo {
    type: never; // ?
    value: ExpressionRef;
  }

  function getFunctionInfo(func: FunctionRef): FunctionInfo;

  interface FunctionInfo {
    name: string;
    module: string | null;
    base: string | null;
    params: Type;
    results: Type;
    vars: Type[];
    body: ExpressionRef;
  }

  function getGlobalInfo(global: GlobalRef): GlobalInfo;

  interface GlobalInfo {
    name: string;
    module: string | null;
    base: string | null;
    type: Type;
    mutable: boolean;
    init: ExpressionRef;
  }

  function getExportInfo(export_: ExportRef): ExportInfo;

  interface ExportInfo {
    kind: ExternalKinds;
    name: string;
    value: string;
  }

  function getEventInfo(event: EventRef): EventInfo;

  interface EventInfo {
    name: string;
    module: string | null;
    base: string | null;
    attribute: number;
    params: Type;
    results: Type;
  }

  function getSideEffects(expr: ExpressionRef, features: Features): SideEffects;

  const enum SideEffects {
    None,
    Branches,
    Calls,
    ReadsLocal,
    WritesLocal,
    ReadsGlobal,
    WritesGlobal,
    ReadsMemory,
    WritesMemory,
    ImplicitTrap,
    IsAtomic,
    Throws,
    DanglingPop,
    Any
  }

  function emitText(expression: ExpressionRef | Module): string;
  function readBinary(data: Uint8Array): Module;
  function parseText(text: string): Module;
  function getOptimizeLevel(): number;
  function setOptimizeLevel(level: number): number;
  function getShrinkLevel(): number;
  function setShrinkLevel(level: number): number;
  function getDebugInfo(): boolean;
  function setDebugInfo(on: boolean): void;
  function getLowMemoryUnused(): boolean;
  function setLowMemoryUnused(on: boolean): void;
  function getFastMath(): boolean;
  function setFastMath(on: boolean): void;
  function getPassArgument(key: string): string | null;
  function setPassArgument(key: string, value: string | null): void;
  function clearPassArguments(): void;
  function getAlwaysInlineMaxSize(): number;
  function setAlwaysInlineMaxSize(size: number): void;
  function getFlexibleInlineMaxSize(): number;
  function setFlexibleInlineMaxSize(size: number): void;
  function getOneCallerInlineMaxSize(): number;
  function setOneCallerInlineMaxSize(size: number): void;
  function exit(status: number): void;

  type RelooperBlockRef = number;

  class Relooper {
    constructor(module: Module);
    addBlock(expression: ExpressionRef): RelooperBlockRef;
    addBranch(from: RelooperBlockRef, to: RelooperBlockRef, condition: ExpressionRef, code: ExpressionRef): void;
    addBlockWithSwitch(code: ExpressionRef, condition: ExpressionRef): RelooperBlockRef;
    addBranchForSwitch(from: RelooperBlockRef, to: RelooperBlockRef, indexes: number[], code: ExpressionRef): void;
    renderAndDispose(entry: RelooperBlockRef, labelHelper: number): ExpressionRef;
  }
}

export = binaryen;
