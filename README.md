# Clickswave Homebrew tap

Homebrew formulae for [Crossfyre](https://crossfyre.io), for macOS (Intel and Apple
silicon) and Linux (x86_64 and arm64).

## Install

```sh
brew install clickswave/tap/crossfyre
```

Since Homebrew 6.0, a formula from a tap outside Homebrew loads only once you trust
it. Installing by the full name, as above, trusts that one formula. To install by
the short name, trust the formula first, or the whole tap if you accept everything
it carries now and later:

```sh
brew tap clickswave/tap
brew trust --formula clickswave/tap/crossfyre   # this formula only
brew trust clickswave/tap                       # or every formula in the tap
brew install crossfyre
```

## What it installs

Only the `crossfyre` CLI, from the versioned release on bins.crossfyre.io, for
running crossfyre as your own user. `crossfyre login`, `crossfyre node list`, the
Web Tracer (`crossfyre trace`) and the other commands that need neither root nor
`/opt/crossfyre` work from it.

The CLI fetches the node agent, cfx-script and the engines into
`/opt/crossfyre/bin`, which needs root, so a Homebrew install has none of them.
Without cfx-script, `crossfyre run` cannot run a `.cfx` script.

## Running a node

Not from Homebrew. A node is a root system service, and setting one up runs
crossfyre as root. Root should not run a file that anyone but root can replace,
and Homebrew's prefix, this crossfyre included, belongs to the user who installed
Homebrew.

To run this machine as a node, `brew uninstall crossfyre` and install crossfyre
with the installer or apt instead. Both put a crossfyre that root owns on root's
PATH, and both are described at https://crossfyre.io/docs/install.

## Updating and removing

`brew upgrade crossfyre` updates the CLI. `crossfyre update` leaves it to Homebrew.

`brew uninstall crossfyre` removes the CLI. Your sign-in and the Web Tracer's CA
stay in the CLI's config directory until you delete it: by default
`~/Library/Application Support/crossfyre` on macOS and `~/.config/crossfyre` on
Linux.

## Licence

The CLI is a first-party build. Its open source parts are under the Apache License
2.0 and live at https://github.com/clickswave/crossfyre-toolchain. The binary as a
whole is under `BINARY-LICENCE.txt`, which the formula installs next to `LICENSE`
and `THIRD-PARTY-NOTICES` in `$(brew --prefix crossfyre)`.

The formula files in this repository are under the 0BSD licence in `LICENSE`.
