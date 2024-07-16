# Pallas

An open source Solid State Interpreter exokernel and runtime

## Index

1. [Introduction](#introduction)
2. [Caveats](#caveats)
3. [Installation](#installation)
4. [Getting Started](#getting-started)
5. [Example](#example)
6. [Contributing](#contributing)
7. [Additional Resources](#additional-resources)

## Introduction

The Pallas [SSI](https://wiki.vaporware.network/solid-state%20interpreter) programming environment is written in a purely functional, rune-based language called Sire. Sire is a sort of Lispy-Haskell with a visual resemblance to Hoon.

Pallas provides the following features out of the box, without any special configuration or external libraries:

- Automatic orthogonal persistence
- Extreme portability with zero external dependencies
- Merkleized state and content-addressable memory pages (data, code, running programs)
- Natively networked with public keys as endpoints
- Serializable closures that can be transferred over the network

## Caveats

#TODO current experimental nature of the repo, what's ready, what's not, etc.

## Installation

_COMING SOON_: Installation instructions for MacOS.

### Quick Start (Ubuntu/Debian-based)

The quickest way to run Pallas is by installing a few dependencies and grabbing
a pre-built binary.

_We provide a very simple install script for Ubuntu/Debian at `bin/install.sh` that
does the following for you. Or you can proceed manually:_

1. Install dependencies:

Dependencies:
- libgmp (GNU Multiple Precision Arithmetic Library)
- liblmdb (Lightning Memory-Mapped Database)
- libz (zlib compression library)

On Ubuntu or Debian-based systems, you can install these with:

```console
sudo apt-get update && sudo apt-get install -y \
    libgmp10 \
    liblmdb0 \
    zlib1g
```

_Note: libm and libc are standard system libraries and should already be present on any Linux system._

2. Get a prebuilt binary:

Download the binary from here: [https://pallas-binaries.nyc3.cdn.digitaloceanspaces.com/test/pallas](https://pallas-binaries.nyc3.cdn.digitaloceanspaces.com/test/pallas). Make it executable and move it somewhere on your path.

3. Run it:

If all went well, you should see this:

```console
$ pallas

Run a Pallas machine

Usage: pallas COMMAND

  Pallas

Available options:
  -h,--help                Show this help text

Available commands:
  sire                     Run a standalone Sire repl.
  save                     Load a sire file and save a seed.
  show                     Print a seed file.
  repl                     Interact with a seed file.
  start                    Resume an idle machine.
  boot                     Boot a machine.
```

4. Get a Sire REPL:

Clone this repository and navigate to its root. Then run:

```console
$ pallas sire sire/prelude.sire
...
...
("prelude","LOADED FROM CACHE!")

}
} ==== Sire REPL ====
}
} Since input is multi-line, there is currently no input-prompt.
} Just type away!
}

```

### Get a Development Environment

Using Nix is the most straightfoward way to install Pallas at this time. 
If your system doesn't support Nix or if you need further
instruction (including instructions for Docker), refer to
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


4. Confirm everything is working by dropping into a Sire REPL:

```console
$ stack run pallas sire sire/prelude.sire
...
...
("prelude","LOADED FROM CACHE!")

}
} ==== Sire REPL ====
}
} Since input is multi-line, there is currently no input-prompt.
} Just type away!
}

```

## Getting Started

_COMING SOON_: Quick start instructions for a todo list app with automatic persistence.

## Example

Sire is the programming language of Pallas.

Here is a brief look at Sire. The
[documentation](https://vaporware.gitbook.io/vaporware/sire/intro) covers the
language more fully, but we want you to get a sense of it now.

If you are following along, use the instructions above to get a Sire REPL.

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

_COMING SOON_: An `/examples` filled with more complex Sire procedures.


## Contributing

At this stage in Pallas development, these are the types of contributions that
are most appropriate:

- Bugs in the existing examples
- New examples
- Documentation improvements
- New GitHub issues for parts of the system that are unclear

That said, we encourage you to dive even deeper and submit PRs beyond these
suggestions.

#TODO link to a `contributing.md`

## Additional Resources

- Pallas is developed by [The Operating Function Company](https://vaporware.network)
- [Technical Documentation](https://vaporware.gitbook.io/vaporware)
  - or view the docs source files at the `doc/` git submodule.
- [OPFN Telegram](https://t.me/vaporwareNetwork)
