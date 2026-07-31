# Settings

Everything configurable in dzimplei is a JSON file on disk. There is no
database and no settings service: the server reads these files when it needs
them, so an edit takes effect on the next read — usually the next request, with
the exceptions marked **restart** below.

Two roots, and the difference matters:

| | |
|---|---|
| `<data-dir>/` | the VPS (`your dzimplei server`) |
| `~/Library/Application Support/dzimplei/mindmap/` | the desktop app on a Mac |

Paths below are relative to whichever root applies.

## Can Jim change these himself?

**No — and this is worth understanding rather than working around.** Jim runs
with `webTools: true`, which is exactly two tools: WebSearch and WebFetch. He
cannot read or write a file. That is deliberate: Jim reads every WhatsApp
message that arrives, including from people who are not you, so anything he
could do, a stranger could talk him into doing.

What he *can* do is dispatch a task to an agent that has tools:

```
TASK[dzimplei]: In <data-dir>/users/<account>/projects/stocks/graph.json set
settings.jimSendFiles to "asked". Change nothing else.
```

So the honest answer to "can Jim change settings": he can arrange it, one
delegation away, and the change is done by an agent that runs in a workspace and
is logged on the mind map. Ask him in plain language — "stop sending me every
file from the stocks workspace" — and that is the TASK he should emit.

**Files an agent must never edit** (say so in the task if there is any doubt):
`auth.json`, `auth/secret`, `auth/setup-token`, anything under `whatsapp/`
except `settings.json`, and any `creds.json`. They are credentials and device
sessions; editing them locks people out or logs the phone number out.

---

## Per workspace — `users/<account>/projects/<workspace>/graph.json`

The `settings` object at the top level of the graph. Absent means default.

| key | values | default | what it does |
|---|---|---|---|
| `deliverableExts` | array of extensions, no dots | `["pptx","key"]` | Writing a file with one of these marks it as the workspace's deliverable — the big gold node on the map. `[]` disables it. |
| `hiddenFileExts` | array of extensions | `["log"]` | Files with these extensions are never linked: no file card, no WhatsApp attachment. `[]` shows everything. |
| `jimSendFiles` | `"all"` \| `"asked"` \| `"none"` | `"all"` | What Jim attaches over WhatsApp when a run finishes. `"asked"` sends only when the request actually asked for a file. Enforced at the send, so turning it down hides attachments without erasing files from the map. |
| `graphShowEdits` | boolean | `false` | Whether a file a run merely *edited* counts as output, like one it created. |

`deliverableExts` and `hiddenFileExts` have fields in the UI: open the
workspace's root node in the node panel.

## Per account — `users/<account>/`

| file | shape | what it does |
|---|---|---|
| `provider.json` | `{"default": "<provider>"}` | Which login pays for this account's runs, when nothing else is named. Falls back to a provider named like the account, then the first one. |
| `fallback.json` | `["<provider>", …]` | Ordered retry list. A **task** (not an attended chat) that fails on a credit or limit error retries on each of these with a fresh session. Empty = no fallback. |
| `auth.json` | `{name, email, salt, hash, owner, created}` | Sign-in. **Never edit by hand** — the password is a scrypt hash, and `owner: true` means "may act for every account". Add accounts in Settings instead. |
| `whatsapp/whatsapp.json` | `{"allowFrom": ["*"], "bossFrom": ["<digits>"]}` | Who Jim answers, and whose messages may start work. `bossFrom` is matched on raw digits because WhatsApp hides numbers behind `@lid` ids. |
| `whatsapp/settings.json` | `{"<jid digits>": {account, workspace, provider?}}` | Per-chat scope lock. A locked chat is sandboxed to one account+workspace+provider, enforced in code, not by asking Jim nicely — prompt injection cannot escape it. |
| `manager-session.json` | `{"id": "<uuid>"}` | Jim's memory: the session both WhatsApp and the app resume. Deleting it makes him forget the conversation and start fresh. |

## Per provider — `providers/<name>/`

A provider is whose login pays. What is in the directory decides how runs
execute — see [PROVIDERS.md](PROVIDERS.md).

| file | shape | what it does |
|---|---|---|
| `claude/` | a Claude config dir | Anthropic directly. |
| `env.json` | `{"ANTHROPIC_BASE_URL": "…", …}` | Environment for runs on this provider. Pointing it at the local gateway is how Codex, Kimi, Copilot, Qwen and xAI work. |
| `cli.json` | `{bin, label, args, env?, loginHint?}` | This provider IS a local agent CLI (Cursor, Antigravity). `{model}` is substituted, `{prompt}` too if present, otherwise the prompt goes in on stdin. |
| `models.json` | `[{value, label}, …]` | The model dropdown for this provider. `value: ""` means "let it choose". |

Creating the directory is all it takes for a provider to appear in the selector.

## Whole installation — `app.json`

| key | values | default | what it does |
|---|---|---|---|
| `lan` | boolean | `false` | Bind to `0.0.0.0` instead of loopback, so other machines on the network can open the app. **restart** — the bind address is chosen once, at listen time. |
| `token` | string | none | Shared access token for LAN sharing. Appended to the shared URL as `?t=`; the server then sets a cookie so only the first link needs it. |

Both have controls in Settings.

## Desktop only — `sync.json`

`{host, user, remote, account}` — see [SYNC.md](SYNC.md). Its presence is what
turns syncing on, which is why the VPS, running the same code, never syncs with
itself.

## Not settings, but often mistaken for them

`sessions.json`, `creds.json`, `auth/secret`, `auth/setup-token` are **state**:
live sessions, OAuth credentials, signing keys. Nothing good comes of editing
them. To sign a CLI provider in, run its login command; to reset a password,
there is no file to poke — create the account again.

---

## Changing things without touching files

Most of what people actually want is in the app:

| want | where |
|---|---|
| add an account | Settings (bottom-left account row) — owner only |
| share on the network | Settings → Share on your network |
| which files Jim sends | the workspace's root node → node panel |
| which files are deliverables / hidden | same panel |
| provider, model, effort for a run | the composer, next to the send button |
| sign a CLI provider in | a terminal: `agent login`, or `agy` |
