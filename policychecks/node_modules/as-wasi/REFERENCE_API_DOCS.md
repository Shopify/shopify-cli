
<a name="readmemd"></a>

**[as-wasi](#readmemd)**

> Globals

# as-wasi

## Index

### Classes

* [CommandLine](#classescommandlinemd)
* [Console](#classesconsolemd)
* [Date](#classesdatemd)
* [Descriptor](#classesdescriptormd)
* [Environ](#classesenvironmd)
* [EnvironEntry](#classesenvironentrymd)
* [FileStat](#classesfilestatmd)
* [FileSystem](#classesfilesystemmd)
* [Performance](#classesperformancemd)
* [Process](#classesprocessmd)
* [Random](#classesrandommd)
* [StringUtils](#classesstringutilsmd)
* [Time](#classestimemd)
* [WASIError](#classeswasierrormd)

### Type aliases

* [aisize](#aisize)

### Functions

* [wasi\_abort](#wasi_abort)

## Type aliases

### aisize

Ƭ  **aisize**: i32

*Defined in [assembly/as-wasi.ts:55](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L55)*

## Functions

### wasi\_abort

▸ **wasi_abort**(`message?`: string, `fileName?`: string, `lineNumber?`: u32, `columnNumber?`: u32): void

*Defined in [assembly/as-wasi.ts:1102](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L1102)*

#### Parameters:

Name | Type | Default value |
------ | ------ | ------ |
`message` | string | "" |
`fileName` | string | "" |
`lineNumber` | u32 | 0 |
`columnNumber` | u32 | 0 |

**Returns:** void

# Classes


<a name="classescommandlinemd"></a>

**[as-wasi](#readmemd)**

> [Globals](#readmemd) / CommandLine

## Class: CommandLine

### Hierarchy

* **CommandLine**

### Index

#### Constructors

* [constructor](#constructor)

#### Properties

* [args](#args)

#### Accessors

* [all](#all)

#### Methods

* [all](#all)
* [get](#get)

### Constructors

#### constructor

\+ **new CommandLine**(): [CommandLine](#classescommandlinemd)

*Defined in [assembly/as-wasi.ts:989](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L989)*

**Returns:** [CommandLine](#classescommandlinemd)

### Properties

#### args

•  **args**: string[]

*Defined in [assembly/as-wasi.ts:989](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L989)*

### Accessors

#### all

• `Static`get **all**(): Array\<string>

*Defined in [assembly/as-wasi.ts:1018](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L1018)*

Return all the command-line arguments

**Returns:** Array\<string>

### Methods

#### all

▸ **all**(): Array\<string>

*Defined in [assembly/as-wasi.ts:1026](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L1026)*

Return all the command-line arguments

**Returns:** Array\<string>

___

#### get

▸ **get**(`index`: usize): string \| null

*Defined in [assembly/as-wasi.ts:1034](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L1034)*

Return the i-th command-ine argument

##### Parameters:

Name | Type |
------ | ------ |
`index` | usize |

**Returns:** string \| null


<a name="classesconsolemd"></a>

**[as-wasi](#readmemd)**

> [Globals](#readmemd) / Console

## Class: Console

### Hierarchy

* **Console**

### Index

#### Methods

* [error](#error)
* [log](#log)
* [readAll](#readall)
* [readLine](#readline)
* [write](#write)

### Methods

#### error

▸ `Static`**error**(`s`: string, `newline?`: bool): void

*Defined in [assembly/as-wasi.ts:857](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L857)*

Write an error to the console

##### Parameters:

Name | Type | Default value | Description |
------ | ------ | ------ | ------ |
`s` | string | - | string |
`newline` | bool | true | `false` to avoid inserting a newline after the string  |

**Returns:** void

___

#### log

▸ `Static`**log**(`s`: string): void

*Defined in [assembly/as-wasi.ts:848](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L848)*

Alias for `Console.write()`

##### Parameters:

Name | Type |
------ | ------ |
`s` | string |

**Returns:** void

___

#### readAll

▸ `Static`**readAll**(): string \| null

*Defined in [assembly/as-wasi.ts:834](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L834)*

Read an UTF8 string from the console, convert it to a native string

**Returns:** string \| null

___

#### readLine

▸ `Static`**readLine**(): string \| null

*Defined in [assembly/as-wasi.ts:841](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L841)*

Read a line of text from the console, convert it from UTF8 to a native string

**Returns:** string \| null

___

#### write

▸ `Static`**write**(`s`: string, `newline?`: bool): void

*Defined in [assembly/as-wasi.ts:827](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L827)*

Write a string to the console

##### Parameters:

Name | Type | Default value | Description |
------ | ------ | ------ | ------ |
`s` | string | - | string |
`newline` | bool | true | `false` to avoid inserting a newline after the string  |

**Returns:** void


<a name="classesdatemd"></a>

**[as-wasi](#readmemd)**

> [Globals](#readmemd) / Date

## Class: Date

### Hierarchy

* **Date**

### Index

#### Methods

* [now](#now)

### Methods

#### now

▸ `Static`**now**(): f64

*Defined in [assembly/as-wasi.ts:895](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L895)*

Return the current timestamp, as a number of milliseconds since the epoch

**Returns:** f64


<a name="classesdescriptormd"></a>

**[as-wasi](#readmemd)**

> [Globals](#readmemd) / Descriptor

## Class: Descriptor

A descriptor, that doesn't necessarily have to represent a file

### Hierarchy

* **Descriptor**

### Index

#### Constructors

* [constructor](#constructor)

#### Accessors

* [rawfd](#rawfd)
* [Invalid](#invalid)
* [Stderr](#stderr)
* [Stdin](#stdin)
* [Stdout](#stdout)

#### Methods

* [advise](#advise)
* [allocate](#allocate)
* [close](#close)
* [dirName](#dirname)
* [fatime](#fatime)
* [fdatasync](#fdatasync)
* [fileType](#filetype)
* [fmtime](#fmtime)
* [fsync](#fsync)
* [ftruncate](#ftruncate)
* [futimes](#futimes)
* [read](#read)
* [readAll](#readall)
* [readLine](#readline)
* [readString](#readstring)
* [seek](#seek)
* [setFlags](#setflags)
* [stat](#stat)
* [tell](#tell)
* [touch](#touch)
* [write](#write)
* [writeString](#writestring)
* [writeStringLn](#writestringln)

### Constructors

#### constructor

\+ **new Descriptor**(`rawfd`: fd): [Descriptor](#classesdescriptormd)

*Defined in [assembly/as-wasi.ts:109](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L109)*

Build a new descriptor from a raw WASI file descriptor

##### Parameters:

Name | Type | Description |
------ | ------ | ------ |
`rawfd` | fd | a raw file descriptor  |

**Returns:** [Descriptor](#classesdescriptormd)

### Accessors

#### rawfd

• get **rawfd**(): fd

*Defined in [assembly/as-wasi.ts:119](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L119)*

**Returns:** fd

___

#### Invalid

• `Static`get **Invalid**(): [Descriptor](#classesdescriptormd)

*Defined in [assembly/as-wasi.ts:94](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L94)*

An invalid file descriptor, that can represent an error

**Returns:** [Descriptor](#classesdescriptormd)

___

#### Stderr

• `Static`get **Stderr**(): [Descriptor](#classesdescriptormd)

*Defined in [assembly/as-wasi.ts:109](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L109)*

The standard error

**Returns:** [Descriptor](#classesdescriptormd)

___

#### Stdin

• `Static`get **Stdin**(): [Descriptor](#classesdescriptormd)

*Defined in [assembly/as-wasi.ts:99](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L99)*

The standard input

**Returns:** [Descriptor](#classesdescriptormd)

___

#### Stdout

• `Static`get **Stdout**(): [Descriptor](#classesdescriptormd)

*Defined in [assembly/as-wasi.ts:104](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L104)*

The standard output

**Returns:** [Descriptor](#classesdescriptormd)

### Methods

#### advise

▸ **advise**(`offset`: u64, `len`: u64, `advice`: advice): bool

*Defined in [assembly/as-wasi.ts:130](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L130)*

Hint at how the data accessible via the descriptor will be used

**`offset`** offset

**`len`** length

**`advice`** `advice.{NORMAL, SEQUENTIAL, RANDOM, WILLNEED, DONTNEED, NOREUSE}`

##### Parameters:

Name | Type |
------ | ------ |
`offset` | u64 |
`len` | u64 |
`advice` | advice |

**Returns:** bool

`true` on success, `false` on error

___

#### allocate

▸ **allocate**(`offset`: u64, `len`: u64): bool

*Defined in [assembly/as-wasi.ts:140](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L140)*

Preallocate data

##### Parameters:

Name | Type | Description |
------ | ------ | ------ |
`offset` | u64 | where to start preallocating data in the file |
`len` | u64 | bytes to preallocate |

**Returns:** bool

`true` on success, `false` on error

___

#### close

▸ **close**(): void

*Defined in [assembly/as-wasi.ts:283](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L283)*

Close a file descriptor

**Returns:** void

___

#### dirName

▸ **dirName**(): string

*Defined in [assembly/as-wasi.ts:261](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L261)*

Return the directory associated to that descriptor

**Returns:** string

___

#### fatime

▸ **fatime**(`ts`: f64): bool

*Defined in [assembly/as-wasi.ts:207](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L207)*

Update the access time

**`ts`** timestamp in seconds

##### Parameters:

Name | Type |
------ | ------ |
`ts` | f64 |

**Returns:** bool

`true` on success, `false` on error

___

#### fdatasync

▸ **fdatasync**(): bool

*Defined in [assembly/as-wasi.ts:148](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L148)*

Wait for the data to be written

**Returns:** bool

`true` on success, `false` on error

___

#### fileType

▸ **fileType**(): filetype

*Defined in [assembly/as-wasi.ts:163](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L163)*

Return the file type

**Returns:** filetype

___

#### fmtime

▸ **fmtime**(`ts`: f64): bool

*Defined in [assembly/as-wasi.ts:219](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L219)*

Update the modification time

**`ts`** timestamp in seconds

##### Parameters:

Name | Type |
------ | ------ |
`ts` | f64 |

**Returns:** bool

`true` on success, `false` on error

___

#### fsync

▸ **fsync**(): bool

*Defined in [assembly/as-wasi.ts:156](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L156)*

Wait for the data and metadata to be written

**Returns:** bool

`true` on success, `false` on error

___

#### ftruncate

▸ **ftruncate**(`size?`: u64): bool

*Defined in [assembly/as-wasi.ts:198](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L198)*

Change the size of a file

##### Parameters:

Name | Type | Default value | Description |
------ | ------ | ------ | ------ |
`size` | u64 | 0 | new size |

**Returns:** bool

`true` on success, `false` on error

___

#### futimes

▸ **futimes**(`atime`: f64, `mtime`: f64): bool

*Defined in [assembly/as-wasi.ts:232](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L232)*

Update both the access and the modification times

**`atime`** timestamp in seconds

**`mtime`** timestamp in seconds

##### Parameters:

Name | Type |
------ | ------ |
`atime` | f64 |
`mtime` | f64 |

**Returns:** bool

`true` on success, `false` on error

___

#### read

▸ **read**(`data?`: u8[], `chunk_size?`: usize): u8[] \| null

*Defined in [assembly/as-wasi.ts:348](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L348)*

Read data from a file descriptor

##### Parameters:

Name | Type | Default value | Description |
------ | ------ | ------ | ------ |
`data` | u8[] | [] | existing array to push data to |
`chunk_size` | usize | 4096 | chunk size (default: 4096)  |

**Returns:** u8[] \| null

___

#### readAll

▸ **readAll**(`data?`: u8[], `chunk_size?`: usize): u8[] \| null

*Defined in [assembly/as-wasi.ts:378](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L378)*

Read from a file descriptor until the end of the stream

##### Parameters:

Name | Type | Default value | Description |
------ | ------ | ------ | ------ |
`data` | u8[] | [] | existing array to push data to |
`chunk_size` | usize | 4096 | chunk size (default: 4096)  |

**Returns:** u8[] \| null

___

#### readLine

▸ **readLine**(): string \| null

*Defined in [assembly/as-wasi.ts:411](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L411)*

Read a line of text from a file descriptor

**Returns:** string \| null

___

#### readString

▸ **readString**(`chunk_size?`: usize): string \| null

*Defined in [assembly/as-wasi.ts:450](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L450)*

Read an UTF8 string from a file descriptor, convert it to a native string

##### Parameters:

Name | Type | Default value | Description |
------ | ------ | ------ | ------ |
`chunk_size` | usize | 4096 | chunk size (default: 4096)  |

**Returns:** string \| null

___

#### seek

▸ **seek**(`off`: u64, `w`: whence): bool

*Defined in [assembly/as-wasi.ts:464](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L464)*

Seek into a stream

**`off`** offset

**`w`** the position relative to which to set the offset of the file descriptor.

##### Parameters:

Name | Type |
------ | ------ |
`off` | u64 |
`w` | whence |

**Returns:** bool

___

#### setFlags

▸ **setFlags**(`flags`: fdflags): bool

*Defined in [assembly/as-wasi.ts:177](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L177)*

Set WASI flags for that descriptor

**`params`** flags: one or more of `fdflags.{APPEND, DSYNC, NONBLOCK, RSYNC, SYNC}`

##### Parameters:

Name | Type |
------ | ------ |
`flags` | fdflags |

**Returns:** bool

`true` on success, `false` on error

___

#### stat

▸ **stat**(): [FileStat](#classesfilestatmd)

*Defined in [assembly/as-wasi.ts:185](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L185)*

Retrieve information about a descriptor

**Returns:** [FileStat](#classesfilestatmd)

a `FileStat` object`

___

#### tell

▸ **tell**(): u64

*Defined in [assembly/as-wasi.ts:475](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L475)*

Return the current offset in the stream

**Returns:** u64

offset

___

#### touch

▸ **touch**(): bool

*Defined in [assembly/as-wasi.ts:247](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L247)*

Update the timestamp of the object represented by the descriptor

**Returns:** bool

`true` on success, `false` on error

___

#### write

▸ **write**(`data`: u8[]): void

*Defined in [assembly/as-wasi.ts:291](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L291)*

Write data to a file descriptor

##### Parameters:

Name | Type | Description |
------ | ------ | ------ |
`data` | u8[] | data  |

**Returns:** void

___

#### writeString

▸ **writeString**(`s`: string, `newline?`: bool): void

*Defined in [assembly/as-wasi.ts:309](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L309)*

Write a string to a file descriptor, after encoding it to UTF8

##### Parameters:

Name | Type | Default value | Description |
------ | ------ | ------ | ------ |
`s` | string | - | string |
`newline` | bool | false | `true` to add a newline after the string  |

**Returns:** void

___

#### writeStringLn

▸ **writeStringLn**(`s`: string): void

*Defined in [assembly/as-wasi.ts:328](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L328)*

Write a string to a file descriptor, after encoding it to UTF8, with a newline

##### Parameters:

Name | Type | Description |
------ | ------ | ------ |
`s` | string | string  |

**Returns:** void


<a name="classesenvironmd"></a>

**[as-wasi](#readmemd)**

> [Globals](#readmemd) / Environ

## Class: Environ

### Hierarchy

* **Environ**

### Index

#### Constructors

* [constructor](#constructor)

#### Properties

* [env](#env)

#### Accessors

* [all](#all)

#### Methods

* [all](#all)
* [get](#get)

### Constructors

#### constructor

\+ **new Environ**(): [Environ](#classesenvironmd)

*Defined in [assembly/as-wasi.ts:930](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L930)*

**Returns:** [Environ](#classesenvironmd)

### Properties

#### env

•  **env**: Array\<[EnvironEntry](#classesenvironentrymd)>

*Defined in [assembly/as-wasi.ts:930](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L930)*

### Accessors

#### all

• `Static`get **all**(): Array\<[EnvironEntry](#classesenvironentrymd)>

*Defined in [assembly/as-wasi.ts:960](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L960)*

 Return all environment variables

**Returns:** Array\<[EnvironEntry](#classesenvironentrymd)>

### Methods

#### all

▸ **all**(): Array\<[EnvironEntry](#classesenvironentrymd)>

*Defined in [assembly/as-wasi.ts:968](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L968)*

 Return all environment variables

**Returns:** Array\<[EnvironEntry](#classesenvironentrymd)>

___

#### get

▸ **get**(`key`: string): string \| null

*Defined in [assembly/as-wasi.ts:976](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L976)*

Return the value for an environment variable

##### Parameters:

Name | Type | Description |
------ | ------ | ------ |
`key` | string | environment variable name  |

**Returns:** string \| null


<a name="classesenvironentrymd"></a>

**[as-wasi](#readmemd)**

> [Globals](#readmemd) / EnvironEntry

## Class: EnvironEntry

### Hierarchy

* **EnvironEntry**

### Index

#### Constructors

* [constructor](#constructor)

#### Properties

* [key](#key)
* [value](#value)

### Constructors

#### constructor

\+ **new EnvironEntry**(`key`: string, `value`: string): [EnvironEntry](#classesenvironentrymd)

*Defined in [assembly/as-wasi.ts:925](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L925)*

##### Parameters:

Name | Type |
------ | ------ |
`key` | string |
`value` | string |

**Returns:** [EnvironEntry](#classesenvironentrymd)

### Properties

#### key

• `Readonly` **key**: string

*Defined in [assembly/as-wasi.ts:926](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L926)*

___

#### value

• `Readonly` **value**: string

*Defined in [assembly/as-wasi.ts:926](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L926)*


<a name="classesfilestatmd"></a>

**[as-wasi](#readmemd)**

> [Globals](#readmemd) / FileStat

## Class: FileStat

Portable information about a file

### Hierarchy

* **FileStat**

### Index

#### Constructors

* [constructor](#constructor)

#### Properties

* [access\_time](#access_time)
* [creation\_time](#creation_time)
* [file\_size](#file_size)
* [file\_type](#file_type)
* [modification\_time](#modification_time)

### Constructors

#### constructor

\+ **new FileStat**(`st_buf`: usize): [FileStat](#classesfilestatmd)

*Defined in [assembly/as-wasi.ts:75](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L75)*

##### Parameters:

Name | Type |
------ | ------ |
`st_buf` | usize |

**Returns:** [FileStat](#classesfilestatmd)

### Properties

#### access\_time

•  **access\_time**: f64

*Defined in [assembly/as-wasi.ts:73](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L73)*

___

#### creation\_time

•  **creation\_time**: f64

*Defined in [assembly/as-wasi.ts:75](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L75)*

___

#### file\_size

•  **file\_size**: filesize

*Defined in [assembly/as-wasi.ts:72](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L72)*

___

#### file\_type

•  **file\_type**: filetype

*Defined in [assembly/as-wasi.ts:71](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L71)*

___

#### modification\_time

•  **modification\_time**: f64

*Defined in [assembly/as-wasi.ts:74](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L74)*


<a name="classesfilesystemmd"></a>

**[as-wasi](#readmemd)**

> [Globals](#readmemd) / FileSystem

## Class: FileSystem

A class to access a filesystem

### Hierarchy

* **FileSystem**

### Index

#### Methods

* [dirfdForPath](#dirfdforpath)
* [exists](#exists)
* [link](#link)
* [lstat](#lstat)
* [mkdir](#mkdir)
* [open](#open)
* [readdir](#readdir)
* [rename](#rename)
* [rmdir](#rmdir)
* [stat](#stat)
* [symlink](#symlink)
* [unlink](#unlink)

### Methods

#### dirfdForPath

▸ `Static` `Protected`**dirfdForPath**(`path`: string): fd

*Defined in [assembly/as-wasi.ts:815](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L815)*

##### Parameters:

Name | Type |
------ | ------ |
`path` | string |

**Returns:** fd

___

#### exists

▸ `Static`**exists**(`path`: string): bool

*Defined in [assembly/as-wasi.ts:579](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L579)*

Check if a file exists at a given path

**`path`** path

##### Parameters:

Name | Type |
------ | ------ |
`path` | string |

**Returns:** bool

`true` on success, `false` on failure

___

#### link

▸ `Static`**link**(`old_path`: string, `new_path`: string): bool

*Defined in [assembly/as-wasi.ts:602](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L602)*

Create a hard link

**`old_path`** old path

**`new_path`** new path

##### Parameters:

Name | Type |
------ | ------ |
`old_path` | string |
`new_path` | string |

**Returns:** bool

`true` on success, `false` on failure

___

#### lstat

▸ `Static`**lstat**(`path`: string): [FileStat](#classesfilestatmd)

*Defined in [assembly/as-wasi.ts:718](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L718)*

Retrieve information about a file or a symbolic link

**`path`** path

##### Parameters:

Name | Type |
------ | ------ |
`path` | string |

**Returns:** [FileStat](#classesfilestatmd)

a `FileStat` object

___

#### mkdir

▸ `Static`**mkdir**(`path`: string): bool

*Defined in [assembly/as-wasi.ts:562](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L562)*

Create a new directory

**`path`** path

##### Parameters:

Name | Type |
------ | ------ |
`path` | string |

**Returns:** bool

`true` on success, `false` on failure

___

#### open

▸ `Static`**open**(`path`: string, `flags?`: string): [Descriptor](#classesdescriptormd) \| null

*Defined in [assembly/as-wasi.ts:495](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L495)*

Open a path

**`path`** path

**`flags`** r, r+, w, wx, w+ or xw+

##### Parameters:

Name | Type | Default value |
------ | ------ | ------ |
`path` | string | - |
`flags` | string | "r" |

**Returns:** [Descriptor](#classesdescriptormd) \| null

a descriptor

___

#### readdir

▸ `Static`**readdir**(`path`: string): Array\<string> \| null

*Defined in [assembly/as-wasi.ts:772](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L772)*

Get the content of a directory

##### Parameters:

Name | Type | Description |
------ | ------ | ------ |
`path` | string | the directory path |

**Returns:** Array\<string> \| null

An array of file names

___

#### rename

▸ `Static`**rename**(`old_path`: string, `new_path`: string): bool

*Defined in [assembly/as-wasi.ts:744](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L744)*

Rename a file

**`old_path`** old path

**`new_path`** new path

##### Parameters:

Name | Type |
------ | ------ |
`old_path` | string |
`new_path` | string |

**Returns:** bool

`true` on success, `false` on failure

___

#### rmdir

▸ `Static`**rmdir**(`path`: string): bool

*Defined in [assembly/as-wasi.ts:676](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L676)*

Remove a directory

**`path`** path

##### Parameters:

Name | Type |
------ | ------ |
`path` | string |

**Returns:** bool

`true` on success, `false` on failure

___

#### stat

▸ `Static`**stat**(`path`: string): [FileStat](#classesfilestatmd)

*Defined in [assembly/as-wasi.ts:693](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L693)*

Retrieve information about a file

**`path`** path

##### Parameters:

Name | Type |
------ | ------ |
`path` | string |

**Returns:** [FileStat](#classesfilestatmd)

a `FileStat` object

___

#### symlink

▸ `Static`**symlink**(`old_path`: string, `new_path`: string): bool

*Defined in [assembly/as-wasi.ts:633](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L633)*

Create a symbolic link

**`old_path`** old path

**`new_path`** new path

##### Parameters:

Name | Type |
------ | ------ |
`old_path` | string |
`new_path` | string |

**Returns:** bool

`true` on success, `false` on failure

___

#### unlink

▸ `Static`**unlink**(`path`: string): bool

*Defined in [assembly/as-wasi.ts:659](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L659)*

Unlink a file

**`path`** path

##### Parameters:

Name | Type |
------ | ------ |
`path` | string |

**Returns:** bool

`true` on success, `false` on failure


<a name="classesperformancemd"></a>

**[as-wasi](#readmemd)**

> [Globals](#readmemd) / Performance

## Class: Performance

### Hierarchy

* **Performance**

### Index

#### Methods

* [now](#now)

### Methods

#### now

▸ `Static`**now**(): f64

*Defined in [assembly/as-wasi.ts:905](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L905)*

**Returns:** f64


<a name="classesprocessmd"></a>

**[as-wasi](#readmemd)**

> [Globals](#readmemd) / Process

## Class: Process

### Hierarchy

* **Process**

### Index

#### Methods

* [exit](#exit)

### Methods

#### exit

▸ `Static`**exit**(`status`: u32): void

*Defined in [assembly/as-wasi.ts:920](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L920)*

Cleanly terminate the current process

##### Parameters:

Name | Type | Description |
------ | ------ | ------ |
`status` | u32 | exit code  |

**Returns:** void


<a name="classesrandommd"></a>

**[as-wasi](#readmemd)**

> [Globals](#readmemd) / Random

## Class: Random

### Hierarchy

* **Random**

### Index

#### Methods

* [randomBytes](#randombytes)
* [randomFill](#randomfill)

### Methods

#### randomBytes

▸ `Static`**randomBytes**(`len`: usize): Uint8Array

*Defined in [assembly/as-wasi.ts:884](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L884)*

Return an array of random bytes

##### Parameters:

Name | Type | Description |
------ | ------ | ------ |
`len` | usize | length  |

**Returns:** Uint8Array

___

#### randomFill

▸ `Static`**randomFill**(`buffer`: ArrayBuffer): void

*Defined in [assembly/as-wasi.ts:867](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L867)*

Fill a buffer with random data

##### Parameters:

Name | Type | Description |
------ | ------ | ------ |
`buffer` | ArrayBuffer | An array buffer  |

**Returns:** void


<a name="classesstringutilsmd"></a>

**[as-wasi](#readmemd)**

> [Globals](#readmemd) / StringUtils

## Class: StringUtils

### Hierarchy

* **StringUtils**

### Index

#### Methods

* [fromCString](#fromcstring)

### Methods

#### fromCString

▸ `Static`**fromCString**(`cstring`: usize): string

*Defined in [assembly/as-wasi.ts:1091](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L1091)*

Returns a native string from a zero-terminated C string

##### Parameters:

Name | Type |
------ | ------ |
`cstring` | usize |

**Returns:** string

native string


<a name="classestimemd"></a>

**[as-wasi](#readmemd)**

> [Globals](#readmemd) / Time

## Class: Time

### Hierarchy

* **Time**

### Index

#### Properties

* [MILLISECOND](#millisecond)
* [NANOSECOND](#nanosecond)
* [SECOND](#second)

#### Methods

* [sleep](#sleep)

### Properties

#### MILLISECOND

▪ `Static` **MILLISECOND**: i32 = Time.NANOSECOND * 1000000

*Defined in [assembly/as-wasi.ts:1046](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L1046)*

___

#### NANOSECOND

▪ `Static` **NANOSECOND**: i32 = 1

*Defined in [assembly/as-wasi.ts:1045](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L1045)*

___

#### SECOND

▪ `Static` **SECOND**: i32 = Time.MILLISECOND * 1000

*Defined in [assembly/as-wasi.ts:1047](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L1047)*

### Methods

#### sleep

▸ `Static`**sleep**(`nanoseconds`: i32): void

*Defined in [assembly/as-wasi.ts:1051](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L1051)*

##### Parameters:

Name | Type |
------ | ------ |
`nanoseconds` | i32 |

**Returns:** void


<a name="classeswasierrormd"></a>

**[as-wasi](#readmemd)**

> [Globals](#readmemd) / WASIError

## Class: WASIError

A WASI error

### Hierarchy

* Error

  ↳ **WASIError**

### Index

#### Constructors

* [constructor](#constructor)

#### Properties

* [message](#message)
* [name](#name)
* [stack](#stack)

#### Methods

* [toString](#tostring)

### Constructors

#### constructor

\+ **new WASIError**(`message?`: string): [WASIError](#classeswasierrormd)

*Overrides void*

*Defined in [assembly/as-wasi.ts:60](https://github.com/jedisct1/as-wasi/blob/e1dfc1b/assembly/as-wasi.ts#L60)*

##### Parameters:

Name | Type | Default value |
------ | ------ | ------ |
`message` | string | "" |

**Returns:** [WASIError](#classeswasierrormd)

### Properties

#### message

•  **message**: string

*Inherited from [WASIError](#classeswasierrormd).[message](#message)*

*Defined in node_modules/assemblyscript/std/assembly/index.d.ts:1718*

Message provided on construction.

___

#### name

•  **name**: string

*Inherited from [WASIError](#classeswasierrormd).[name](#name)*

*Defined in node_modules/assemblyscript/std/assembly/index.d.ts:1715*

Error name.

___

#### stack

• `Optional` **stack**: undefined \| string

*Inherited from [WASIError](#classeswasierrormd).[stack](#stack)*

*Defined in node_modules/assemblyscript/std/assembly/index.d.ts:1721*

Stack trace.

### Methods

#### toString

▸ **toString**(): string

*Inherited from [WASIError](#classeswasierrormd).[toString](#tostring)*

*Defined in node_modules/assemblyscript/std/assembly/index.d.ts:1727*

Method returns a string representing the specified Error class.

**Returns:** string
