# dzimplei

Workspaces, a mind map, a kanban board and Claude Code sessions behind one UI —
plus **Jim**, a manager you talk to in the app or on WhatsApp who files the work
into the right workspace, starts it, and reports back.

This repository is the public home for **releases, documentation and issues**.
The source lives in a private repository; nothing here is the code itself.

## Get started

**macOS (Apple silicon)** — with Homebrew:

```bash
brew tap t-shark-9/dzimplei https://github.com/t-shark-9/dzimplei
brew install --cask dzimplei
```

The app is signed with dzimplei's own certificate rather than an Apple Developer
ID, so macOS would normally refuse the first launch of a downloaded copy; the
cask clears that flag on the copy it installs. It updates itself after that.

**Windows** — with [Scoop](https://scoop.sh):

```powershell
scoop bucket add dzimplei https://github.com/t-shark-9/dzimplei
scoop install dzimplei
```

The installer is not code-signed yet, so SmartScreen may ask once.

**Or download a build** from [Releases](../../releases): `dzimplei-mac-arm64.dmg`
(drag to Applications, then right-click → Open the first time) and
`dzimplei-windows-x64.exe`. Linux ships an AppImage when one is published:

```bash
chmod +x dzimplei-*.AppImage
./dzimplei-*.AppImage
```

The desktop app keeps everything on your machine and uses the Claude login you
already have. Self-hosting serves the same app over the web, behind a sign-in.

## What it does

- **Workspaces** — each one a directory with its own files, history and chats.
- **Chat** — Claude Code sessions scoped to a workspace, with the files a run
  writes attached to the conversation.
- **Mind map & Todo** — the same work as a graph or as a kanban board.
- **Jim** — a manager who takes "draft the board deck", files it into the right
  workspace, starts the agent and reports back. In the app or over WhatsApp.
- **Any provider** — Anthropic directly, or Codex, Grok, Copilot, Kimi and Qwen
  through a local translating gateway, or a local agent CLI like Cursor and
  Antigravity. See [docs/PROVIDERS.md](docs/PROVIDERS.md).

## Documentation

| | |
|---|---|
| [Settings](docs/SETTINGS.md) | every setting, where it lives, what it does — and what Jim can and cannot change |
| [Providers](docs/PROVIDERS.md) | the three kinds of provider, and how to add one |
| [Sync](docs/SYNC.md) | working on the same workspaces from a laptop and a server |

## Requirements

- A Claude subscription or API access. The app runs Claude Code; it does not
  bundle a model.
- Node 20+ if you run the server yourself.

## Status

Early software. Expect rough edges, and expect the data format to move under you
between versions. See [CHANGELOG.md](CHANGELOG.md).

## Reporting bugs

[Open an issue](../../issues/new/choose). Please include the version, whether it
was the desktop app or self-hosted, and what you expected instead. Logs help;
secrets do not — scrub tokens before pasting.

## Security

Please do not open a public issue for a vulnerability. See
[SECURITY.md](SECURITY.md).

## Your data

dzimplei has no servers of its own and collects nothing. Workspaces, chats and
files stay on the machine that runs it — your laptop, or a server you control.
Prompts go to whichever model provider you sign in with, under that provider's
own terms; the app is a client, not an intermediary.
