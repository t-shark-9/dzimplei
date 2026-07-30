# dzimplei

Workspaces, a mind map, a kanban board and Claude Code sessions behind one UI —
plus **Jim**, a manager you talk to in the app or on WhatsApp who files and
starts the work for you.

This repository is the public home for **releases and issue reports**. The
source lives in a private repository; nothing here is the code itself.

- **Download:** see [Releases](../../releases).
- **Found a bug or want a feature?** [Open an issue](../../issues/new/choose).

## Status

**0.0.1 — first tagged release.** Early software: expect rough edges, and
expect the data format to move under you between versions.

## What it does

- **Workspaces** — each one a directory with its own history, chats and files.
- **Chat** — Claude Code sessions scoped to a workspace, with the files it
  writes attached to the conversation.
- **Mind map & Todo** — the same work seen as a graph or as a kanban board.
- **Jim** — a manager who takes a request ("draft the board deck"), files it
  into the right workspace, starts the agent, and reports back. Reachable in the
  app or over WhatsApp.
- **Runs where you want it** — a web app on your own server, or a desktop app
  that keeps everything local and uses your own Claude subscription.

## Requirements

- A Claude subscription or API access (the app runs Claude Code; it does not
  bundle a model).
- Node 20+ if you run the server yourself.

## Reporting a problem

Please include the version, where it ran (desktop or self-hosted), and what you
expected instead. Logs help; secrets do not — scrub tokens before pasting.
