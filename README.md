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




