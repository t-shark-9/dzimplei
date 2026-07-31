# Changelog

Dates are release dates. Early versions moved fast; the data format is not yet
stable between them.

## 0.0.4 — 2026-07-30

The first build that actually starts after packaging. Three separate problems
each produced a package that installed and then failed to run:

- Packaging wrote into the same directory the web build outputs to, so it
  consumed its own input. Output moved to `release/`.
- The base path baked into asset URLs at build time did not match the path the
  desktop shell serves under, so a packaged app loaded nothing.
- The build toolchain was pruned out as a dev dependency, but the shell serves
  the app with it at runtime — the packaged app died looking for it.

Linux AppImage attached. Verified by extracting and running it, not by the build
exiting 0.

## 0.0.3 — 2026-07-30

Desktop packaging works.

## 0.0.2 — 2026-07-30

Desktop packaging fix.

## 0.0.1 — 2026-07-30

First tagged release. Workspaces, chat, mind map, todo board, Jim in the app and
over WhatsApp, multiple accounts and providers.
