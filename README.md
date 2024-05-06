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

### Fetchers

Build input files don't need to come from the file system. The Nix language provides function to fetch files over the network.

- `builtins.fetchurl`
- `builtins.fetchTarball`
- `builtins.fetchGit`
- `builtins.fetchClosure`

The functions evaluate to a file system path in the Nix store.

```nix
builtins.fetchurl "https://github.com/NixOS/nix/archive/7c3ab5751568a0bc63430b33a5169c5e4784a0ff.tar.gz"
# "/nix/store/7dhgs330clj36384akg86140fqkgh8zf-7c3ab5751568a0bc63430b33a5169c5e4784a0ff.tar.gz"
```

Some provide conveniences, like auto unpacking archives.

```nix
builtins.fetchTarball "https://github.com/NixOS/nix/archive/7c3ab5751568a0bc63430b33a5169c5e4784a0ff.tar.gz"
# "/nix/store/d59llm96vgis5fy231x6m7nrijs0ww36-source"
```

## Derivations

Derivations are core to Nix.

- The Nix language is used to describe _derivations_.
- Nix runs _derivations_ to produce build results.
- Build results can be used as input for other _derivations_.

The built-in impure function `derivation` is the primitive to declare a _derivation_. It is ussually wrapped by the Nixpkgs build mechanism `stdenv.mkDerivation`, it hides most of the complexity of build procedures.

> [!note] You will probably never encounter `derivation` in practice.

`mkDerivation` denotes something that Nix will build.

The evaluation result of `derivation` (and `mkDerivation`) is an _attribute set_ with a certain structure and special property. It can be used in _string interpolation_ and in that case evaluates to the Nix store path of its built result.

```nix
let
  pkgs = import <nixpkgs> {};
in "${pkgs.nix}"
# "/nix/store/sv2srrjddrp2isghmrla8s6lazbzmikd-nix-2.11.0"
```

> [!note] Output may differ, a different hash or different version may be produced.
>
> A _derivation's_ output path is fully determined by its inputs, in this case from a Nixpkgs version.
>
> This is why _lookup paths_ (`<...>`) are not recommended to ensure predictable outcomes.

String interpolation on derivations is used to refer to their build results as file system paths when declaring new derivations.

This allows constructing arbitrarily complex compositions of derivations with the Nix language.

## Working Examples

### Shell Environment

```nix
# This expression is a function that takes an attribute set as an argument.

# If the argument has the attribute pkgs, it will be used in the function body. Otherwise, by default, import the Nix expression in the file found on the lookup path <nixpkgs> (which is a function in this case), call the function with an empty attribute set, and use the resulting value.
{ pkgs ? import <nixpkgs> {} }:
let
  # The name message is bound to the string value "hello world".
  message = "hello world";
in
# The attribute mkShellNoCC of the pkgs set is a function that is passed an attribute set as argument. Its return value is also the result of the outer function.
pkgs.mkShellNoCC {
  # The attribute set passed to mkShellNoCC has the attributes buildInputs (set to a list with one element: the cowsay attribute from pkgs) and shellHook (set to an indented string).
  buildInputs = with pkgs; [ cowsay ];
  shellHook = ''
    # The indented string contains an interpolated expression, which will expand the value of message to yield "hello world".
    cowsay ${message}
  '';
}
```

### NixOS Configuration

```nix
# This expression is a function that takes an attribute set as an argument. It returns an attribute set.

# The argument must at least have the attributes config and pkgs, and may have more attributes.
{ config, pkgs, ... }:

# The returned attribute set contains the attributes imports and environment.
{
  # imports is a list with one element: a path to a file next to this Nix file, called hardware-configuration.nix.
  imports = [ ./hardware-configuration.nix ];

  # environment is itself an attribute set with one attribute systemPackages, which will evaluate to a list with one element: the git attribute from the pkgs set.
  environment.systemPackages = with pkgs; [ git ];

  # The config argument is not (shown to be) used.
  # ...

}
```

### Package

```nix
# This expression is a function that takes an attribute set which must have exactly the attributes lib, stdenv, and fetchurl.
{ lib, stdenv, fetchurl }:

# It returns the result of evaluating the function mkDerivation, which is an attribute of stdenv, applied to a recursive set.
stdenv.mkDerivation rec {
  # The recursive set passed to mkDerivation uses its own pname and version attributes in the argument to the function fetchurl. fetchurl itself comes from the outer function’s arguments.
  pname = "hello";

  version = "2.12";

  src = fetchurl {
    url = "mirror://gnu/${pname}/${pname}-${version}.tar.gz";
    sha256 = "1ayhp9v4m4rdhjmnl2bq3cibrbqqkgjbl3s7yk2nhlh8vj3ay16g";
  };

  # The meta attribute is itself an attribute set, where the license attribute has the value that was assigned to the nested attribute lib.licenses.gpl3Plus.
  meta = with lib; {
    license = licenses.gpl3Plus;
  };

}
```
