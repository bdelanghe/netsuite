# Development

This repo prefers a repo-defined Ruby toolchain via Devbox.

## Devbox (status & trade-offs)
Devbox is considered a modern, valid way to manage per-project development environments, especially when you want reproducibility and consistent tooling across machines and CI. It’s actively developed and provides a reproducible shell by declaring tools in `devbox.json` (backed by Nix) without requiring contributors to write Nix expressions. ([Jetify][1])

Trade-off: if you need maximum control, native Nix flakes/devshells are more flexible; Devbox is intentionally a simpler layer on top.

References:
- [Jetify (Devbox)][1]
- [DevTools Guide overview][2]

[1]: https://www.jetify.com/devbox
[2]: https://www.devtoolsguide.com/devbox-reproducible-dev-environments/

## Getting started
- Install Devbox.
- Enter the environment:
  - `devbox shell`
  - or (recommended) `direnv allow` if you use direnv.

## Sanity checks
From inside the Devbox environment:
- `which ruby && ruby -v`
- `which gem && gem --version`
- `bundle -v`

## Publishing (RubyGems)
Devbox does not override `HOME` by default, so RubyGems credentials continue to live at `~/.gem/credentials`.

Typical flow:
- `gem build netsuite.gemspec`
- `gem push netsuite-<version>.gem`
