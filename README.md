# Pallas

#TODO Brief subtext

Pallas is an open source exokernel system built on a new computational model:
the Solid State Interpreter.  

## Index

1. [Introduction](#introduction)
2. [Caveats](#caveats)
3. [Installation](#installation)
4. [Getting Started](#getting-started)
5. [Example](#example)
6. [Contributing](#contributing)
7. [Additional Resources](#additional-resources)

## Introduction

The Pallas [SSI](https://wiki.vaporware.network/solid-state%20interpreter) programming environment is written in a purely functional, rune-based language called Sire. Sire is a sort of Lisp-Haskell with a visual resemblance to Hoon.

Pallas provides the following features out of the box, without any special configuration or external libraries:

- Automatic orthogonal persistence
- Extreme portability with zero external dependencies
- Serialization of _running_ programs
- Content-based addressing of data, code, and running processes
- Functional programming and homoiconicity

#TODO include these?
- macros
- continuations
- content-based addressing

## Caveats

#TODO current experimental nature of the repo, what's ready, what's not, etc.

## Installation

#TODO improve the docs install page. handle other OSes, known gotchas, etc.

Using Nix is the most straightfoward way to install Pallas at this time. 
If your system doesn't support either of these or if you need further
instruction, refer to
[the documentation](https://vaporware.gitbook.io/vaporware/installation/installation).

1. Clone this repo. Navigate to the root of it.

```shell
git clone git@github.com:deathtothecorporation/pallas.git
cd pallas
```

2. Get into a Nix shell

```shell
nix develop
```

3. Build pallas
This will take some time. Perhaps upwards of 15 minutes, depending on your system.

```shell
stack build
```


4. Confirm everything is working

_#TODO: We will provide a simple demo to run_

## Getting Started

#TODO command-line examples for:
- getting a REPL
  - `stack run plunder sire sire/prelude.sire`
- booting the TODO app, updating state, closing, re-launching to see state.
  - #TODO

## Example

#TODO very briefly explain what Sire is.

Here is a brief look at Sire. The
[documentation](https://vaporware.gitbook.io/vaporware/sire/intro) covers the
language more fully, but we want you to get a sense of it now.

#TODO some Sire examples

#TODO reminder about getting into a repl

### Top-level binding

```sire
; This is a comment.

; Top-level binding of 3 to x:
x=3
```

### Function application

```sire
(add 1 3)
; ^ function name (add)
;    ^ first argument (1)
;      ^ second argument (3)

4 ; return value
```

```sire
| add 1 3
4   ; return value
```

```sire
add-1-3
4
```

```sire
; Binding a named function
= (addTwo input)
| add 2 input


; Applying it
(addTwo 4)
6
```

### Rows

```sire
row=[10 64 42]

; idx is a function that returns a particular index in a row

(idx 0 row)
10
; the zeroth item in the row

(idx 2 row)
42
```

### Demo Examples

#TODO create `/examples`, fill it.

Take a look through the `/examples` directory to explore more complex Sire
procedures.

## Contributing

#TODO the contributions we're interested in:
- Bugs in existing demos
- New demos
- Documentation improvements
- New Issue for “How does xyz thing work?” - with the satisfaction of the Issue being a PR to docs, examples, source code, etc.

#TODO link to a `contributing.md`

## Additional Resources

#TODO Write something here.

- Pallas is developed by [The Operating Function Company](https://vaporware.network)
- [Technical Documentation](https://vaporware.gitbook.io/vaporware)
  - or view the docs source files at the `doc/` git submodule.
- [OPFN Telegram](https://t.me/vaporwareNetwork)
