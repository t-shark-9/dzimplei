# Providers

A provider is **whose login pays for a run** — orthogonal to the account, which
is whose workspaces the run works in. Any account can run on any provider.

A provider is not code. It is a directory, `providers/<name>/`, and what is
inside it decides how runs on it execute. There are three kinds.

## 1. Anthropic (the plain case)

`providers/<name>/claude/` is a Claude config dir, and the SDK talks to
Anthropic directly. `<account>` and `family` are these.

## 2. Behind the gateway — any model API

`providers/<name>/env.json` points `ANTHROPIC_BASE_URL` at the local gateway
(`server/gateway.ts`, port 8082). The gateway is a stdlib-only Python process
that translates Anthropic to OpenAI and holds the OAuth, so the SDK still
believes it is talking to Anthropic and every run path works unchanged.

Ships sign-ins for **Codex, xAI Grok, Copilot, Kimi and Qwen**. Any other
OpenAI-compatible endpoint is a few lines in `server/gateway/backends.json` (see
`backends.example.json` for Groq, OpenRouter, z.ai, the Qwen coding plan).

## 3. A local CLI — an agent, not a model

`providers/<name>/cli.json` names a binary to run. **Cursor** (`agent`) and
**Antigravity** (`agy`) are these.

```json
{
  "bin": "agent",
  "label": "Cursor",
  "args": ["--print", "--output-format", "text", "--force", "--model", "{model}"],
  "loginHint": "PATH=$HOME/.local/bin:$PATH agent login"
}
```

`{model}` is replaced with the chosen model, or the flag pair is dropped when
the user picked Default. `{prompt}` is replaced with the prompt if present;
otherwise the prompt goes in on stdin. `models.json` fills the model dropdown
exactly as for any other provider.

### Why these cannot go behind the gateway

The gateway is **one shared process on port 8082**, and an HTTP request arriving
there carries no workspace directory. Cursor and Antigravity are not model
endpoints — they are coding agents with their own tool loop, so they must run
*in* the workspace. `runClaude` already receives it as `dir`, so the branch
belongs there (`server/cliProvider.ts`), before the SDK is ever reached.

### What you give up by choosing one

- **dzimplei's own tools.** The CLI brings its own agent loop; the outer
  toolset is not used. That is inherent to nesting one agent in another.
- **Session resume.** The CLI owns its session store, so a run is one
  self-contained shot at the prompt.
- **Live file attachment.** `graph-hook.js` is a *Claude Code* hook — these
  binaries fire nothing. Instead `runCli` takes a before/after mtime snapshot of
  the workspace and links whatever changed, marked `created` so the map's file
  indicator and the node panel treat it as output. The walk is bounded (depth 4,
  3000 entries, skipping `node_modules`, `.git`, `.venv`, dotfiles) because
  `root` is a workspace too, and it is `/root`.

Title generation and memory forks stay on the SDK even when a CLI provider is
selected — they are plumbing, and a CLI has no cheap haiku to answer them.

### Signing in

Neither CLI is signed in by installing it, and a run says so plainly rather than
dumping stderr:

> Cursor is not signed in on this server. Run: `agent login`

```bash
PATH=$HOME/.local/bin:$PATH agent login   # Cursor, or set CURSOR_API_KEY
PATH=$HOME/.local/bin:$PATH agy           # Antigravity: prints a URL + code
```

Antigravity detects SSH and falls back to a paste-the-code flow, so a headless
server works. Once signed in, `agy models` lists the real model ids — put them
in `providers/antigravity/models.json`, which currently offers only "default".
