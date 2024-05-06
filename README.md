# Nix

## Language Basics

> [!note] Lazy Evaluation
>
> Nix uses lazy evaluation by default values are only computed when needed.

> [!note] Whitespace is insignificant.

## Name & Values

Value can be primitive data types, lists, attribute sets, and functions.

```nix
{
  string = "hello";
  integer = 1;
  float = 3.141;
  bool = true;
  null = null;
  list = [ 1 "two" false ]; # seperated by a space
  attribute-set = {
    a = "hello";
    b = 2;
    c = 2.718;
    d = false;
  }; # comments are supported
}
```

### Recursive Attributes

Allow access to attributes within the set.

```nix
rec {
  one = 1;
  two = one + 1;
  three = two + 1;
}
```

## `let ... in ...`

Assign values for repeated use.

```nix
let 
  x = 20;
in
x + x
```

Names can be assigned in any order, and assignments can refer to other assigned names.

```nix
let 
 x = y + z;
 y = z + 10;
 z = 2;
in
x + y + z
```

> [!warning] No, no! Only expressions within the `let` expression itself can access its variable names.

```nix
{
  a = let x = 1; in x;
  b = x;
}
```

### Attribute access

Attributes in a set can be accessed with a dot (`.`) and the attribute name.

```nix
let
  attrset = { x = 1; };
in
attrset.x
```

Nested attributes

```nix
let
  attrset = { a = { b = { c = 1; }; }; };
in
attrset.a.b.c
```

Assign values with dot (`.`) notation.

```nix
{ a.b.c = 1; }
```

### `with ...; ...`

The `with` expression gives access to attributes without repeatedly referencing their set.

```nix
let
  a = {
    x = 1;
    y = 2;
    z = 3;
  };
in
with a; [ x y z ]
# equal to
# [ a.x a.y a.z ]
```

`with` expression are in scope of the exprssion

```nix
let
  a = {
    x = 1;
    y = 2;
    z = 3;
  };
in
{
  b = with a; [ x y z ];
  c = x; # out of scope
}
```

## `inherit ...`

A shorthand for assigning the value of a name from an existing scope to the same name in a nested scope. Helps avoid repeating the same name multiple times.

```nix
let
  x = 1;
  y = 2;
in
{
  inherit x y;
}
# { x = 1; y = 2; }
```

`inherit` names for an attribute set `inherit (attribute-set) value-name1 value-name2`

```nix
let
  a = { x = 1; y = 2; };
in
{
  inherit (a) x y;
}
# x = a.x; y = a.y;
```

`inherit` also works with `let` expression

```nix
let
  inherit ({ x = 1; y = 2; }) x y;
in [ x y ]
```

## String Interpolation `${...}`

Insert the value of an expression into a string. _(fka "antiquotation")_

```nix
let
  name = "Nix";
in
"hello ${name}"
```

> [!warning]
>
> Only character strings or values that can be represented as character string are allowed.
>
> ```nix
> let
>   x = 1;
> in
> "${x} + ${x} = ${x + x}" # integers are not allowed
> ```

## File System Paths

- `/absolute/path`
- `./relative/path`
- `./.` the current directory
- `../.` current

## Lookup Paths

Single bracket syntax

| name            | path                                                       |
| --------------- | ---------------------------------------------------------- |
| `<nixpkgs>`     | `/nix/var/nix/profiles/per-user/root/channels/nixpkgs`     |
| `<nixpkgs/lib>` | `/nix/var/nix/profiles/per-user/root/channels/nixpkgs/lib` |

## Indent Strings

Multi line strings.

```nix
''
multi
line
string
''
# "multi\nline\nstring\n"
```

```nix
''
  one
   two
    three
''
# "one\n two\n  three\n"
```

## Functions

A function takes one argument. The argument and function body are separated by a colon (`:`).

> [!note] Function arguments are the third way (Attributes-set, `let` expressions) to assign names to values. _Names are not known in advance but are placeholders that are filled when calling a function_

### Function Declarations

#### Single argument

```nix
x: x + 1
```

#### Multi nested arguments

```nix
x: y: x + y
```

#### Attribute Set arguments

```nix
{ a, b }: a + b
```

With a default value

```nix
{ a, b ? 4 }: a + b
```

With additional values

```nix
{ a, b, ... }: a + b + c
```

Name attributes set arguments

```nix
args@{ a, b, ... }: a + b + args.c
```

```nix
{ a, b, ... }@args: a + b + args.c
```

### Lambdas

Functions are anonymous and have no name, they are referred to as `<LAMBDA>`.

```nix
x: x + 1
# <LAMBDA>
```

Functions can be assigned to a name.

```nix
let 
 f = x: x + 1;
in f
```

### Calling Functions

Function applications, writing the argument after the function.

```nix
let 
 f = x: x + 1;
in 
 f 20
```

Passing a literal value

```nix
let
  f = x: x.a;
in 
 f { a = 12 }
```

Pass argument by name

```nix
let
 f = x: x.a;
 v = { a = 12 };
in
 f v
```

Parentheses (`( )`) can be used for a literal functions

```nix
(x: x + 1) 1
```

Beware of functions in lists since they are separated by whitespace.

```nix
# Applies f to a and adds it to the list
let
 f = x: x + 1;
 a = 1;
in [ (f a) ]
# [ 2 ]
```

```nix
# Put f and a as separate items in the list
let
 f = x: x + 1;
 a = 1;
in [ f a ]
# [ <LAMBDA> 1 ]
```

### Multiple Arguments

Curried functions aka nesting functions

```nix
x: y: x + y
# equal to 
# x: (y: x + y)
```

This returns the function with the value of `x` set to the pass argument.

```nix
let
  f = x: y: x + y;
in
f 1
```

Passing all the arguments will return the value of the evaluated function.

```nix
let
  f = x: y: x + y;
in
f 1 2
```

### Attribute Set Argument

AKA _"keyword arguments"_ or _destructuring_. The exact arguments must be passed.

```nix
{a, b}: a + b
```

Good idea!

```nix
let
  f = {a, b}: a + b;
in
f { a = 1; b = 2; }
```

Bad idea.

```nix
let
  f = {a, b}: a + b;
in
f { a = 1; b = 2; c = 3; }
# error: 'f' at (string):2:7 called with unexpected argument 'c'
# 
#        at «string»:4:1:
# 
#             3| in
#             4| f { a = 1; b = 2; c = 3; }
#              | ^
#             5|
```

### Default Values

Default arguments. Denoted by separating the attribute name and default value witha question mark (`?`). These are not required arguments.

```nix
let
  f = {a, b ? 0}: a + b;
in
f { a = 1; }
```

Empty argument

```nix
let
  f = {a ? 0, b ? 0}: a + b;
in
f { } # empty attribute set
```

### Additional Values

Additional arguments are allow with an ellipsis (`...`).

```nix
let
  f = {a, b, ...}: a + b;
in
f { a = 1; b = 2; c = 3; }
```

### Named attribute set argument

Also known as “@ pattern”, “@ syntax”, or “‘at’ syntax”.

```nix
let
  f = {a, b, ...}@args: a + b + args.c;
in
f { a = 1; b = 2; c = 3; }
```

## Function Libraries

Libraries considered standard to the Nix language.

### [`builtins`](https://nix.dev/manual/nix/2.18/language/builtins)

AKA _"primitive operations"_, _"primops"_

Functions built into the language, implemented in `C++` available under `builtins`.

```nix
builtins.toString
# <PRIMOP>
```

### `import`

Takes a path to a Nix file, evaluates it and returns the value. If the path points to a directory the `defaults.nix` in the directory is used.

```nix
# file.nix
1 + 2
```

```nix
import ./file.nix
# 3
```

#### Function Import

```nix
# ./file/defaults.nix
x; x + 1
```

```nix
import ./file 2
# 3
```

### `pkgs.lib`

The `nixpkgs` repo contains `lib`, which provides useful functions. The [functions](https://nixos.org/manual/nixpkgs/stable/#sec-functions-library) are implemented in the Nix language versus `builtins`, that are part of the language

```nix
let
  pkgs = import  <nixpkgs> {};
in
pkgx.lib.strings.toUpper "scream"
# "SCREAM"
```

> [!note] Some functions in `pkgs.lib` are identical to `builtins`.

## Impurities

- _Pure expressions_: declaring data and transforming it with functions.
- _Impurities_: reading files from the file system as build inputs.
- _Build inputs_ are files that derivations refer to in order to derive new files. On run, a derivation will only have access to explicitly declared build inputs.
  - Can only be specified explicitly with _file system paths_ and _dedicated functions_.

> [!note] Nix refers to files by their content hash. If the file contents are unknown, reading files during evaluation is unavoidable.

### Paths

When a file system path is used in _string interpolation_, the file contents are copied to a special location, the Nix store, as a side effect.

The evaluated string contains the Nix store path assigned to the file.

```
# ./data
123
```

```nix
"${./data}"
# "/nix/store/h1qj5h5n05b5dl5q4nldrqq8mdg7dhqk-data"
```

The same occurs for directories: The entire directory and its files is copied to the Nix store, and the evaluated string becomes the Nix store path of the directory.
