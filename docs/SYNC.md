# Working on the same workspaces locally and on the VPS

The desktop app keeps its own copy of the workspaces and rsyncs them with the
VPS every 60 seconds, in both directions. Runs happen wherever you started
them — locally on your Mac (your own Claude subscription, and agents can reach
your Mac's files), on the VPS when you use your dzimplei server.

Nothing syncs until `sync.json` exists, which is why the VPS — running this
same code — never tries to sync with itself.

## Setting it up on the Mac

1. **Get the code.** In your local checkout:

   ```bash
   git pull && npm install
   ```

2. **Check the VPS is reachable without a password.** You already have a key on
   it if the Chrome tunnel works. This must print `ok` with no prompt:

   ```bash
   ssh -o BatchMode=yes root@<your-server> echo ok
   ```

   If it asks for anything, copy your key up first: `ssh-copy-id root@<your-server>`.

3. **Write the sync config** into the app's data directory:

   ```bash
   mkdir -p ~/Library/Application\ Support/dzimplei/mindmap
   cat > ~/Library/Application\ Support/dzimplei/mindmap/sync.json <<'EOF'
   {
     "host": "<your-server>",
     "user": "root",
     "remote": "<data-dir>/users",
     "account": "<account>"
   }
   EOF
   ```

4. **Start the app** (`npm run desktop`). The first sync runs immediately, then
   every 60s. Watch it in the terminal: `sync: <account> up to date with …`.

The account is called `<account>` on both sides — the same name, so the same
workspaces appear in the switcher rather than a local `me` and a remote `<account>`.

## What it does and does not do

**Synced:** `graph.json`, `files/`, `CLAUDE.md`, `uploads/`, `.claude-memory.log`
— everything that *is* the work.

**Not synced,** because it is tied to one machine or is a secret:

| | |
|---|---|
| `whatsapp/` | Baileys device session. Two machines on one session breaks the bridge and can log the number out. |
| `auth.json` | credentials. The desktop runs with `DZ_NO_AUTH=1` and needs none. |
| `provider.json`, `*session*.json` | which Claude login pays, and session ids that exist only in one machine's config dir. |
| `archive/`, `*.bak-*`, `.venv`, `node_modules` | bulk with no reason to travel. |

**Conflicts.** Ordinary files are only ever overwritten by a strictly newer one
(`rsync --update`, both directions): edit one in two places between syncs and
the newer edit wins.

`graph.json` is the exception, because it is the file both machines write
constantly — every chat, every finished task — so newest-wins there meant one
side's whole afternoon losing to the other's by a few seconds. It is excluded
from the copy and **merged** instead (`scripts/merge-graph.mjs`): nodes are
unioned by id, so both machines keep what the other added. Only a genuine edit
to the *same node* still resolves by which file is newer. Deletions are not
merged away either — a node missing on one side is "not seen there yet", never
"deleted here", which matches the no-`--delete` rule below.

The residual race is narrow: if the other machine rewrites a graph in the second
between our read and our write-back, that rewrite is overwritten. A minute later
it syncs again.

**Deletions do not propagate.** There is no `--delete`: a fresh or half-synced
side would otherwise wipe the other. Removing a workspace stays a local act,
which is also why the app archives instead of deleting.

**Syncing does not wait for quiet.** It used to skip a round whenever an agent
was running on either side. That was unnecessary — the app writes graphs to a
temp file and renames, which is atomic, so a reader never sees a torn one, and
graphs are merged rather than copied — and it was expensive: on a machine where
agents run most of the day, "skip while busy" means "rarely sync". A large file
copied mid-write can still land truncated, but it heals on the next round, when
the writer's final mtime is newer.

## When something looks wrong

The app logs every attempt. Common messages:

- `sync: cannot reach <host> (is your key on it?)` — step 2 above.
- Nothing at all in the log — `sync.json` is missing or in the wrong directory.

Run it by hand to see the full output:

```bash
DZ_SYNC_DATA=~/Library/Application\ Support/dzimplei/mindmap sh scripts/sync-vps.sh
```

**Symlinked workspaces do not sync.** `--safe-links` skips any symlink pointing
outside the tree. Today only `projects/root` (-> `/root`) is one, and skipping
it is right — you do not want the whole VPS home copied to your Mac.

The trap is the other kind: a workspace adopted from elsewhere on disk (what
`linkProject` creates) is a symlink too, so it is silently absent on the other
machine — it shows in the list and looks empty. `ionway-board-meeting` was
exactly that until 2026-07-30, when it was moved under
`users/<account>/projects/` so it travels like everything else. Do the same
with any adopted folder you want on both machines.

**Transcript links break across machines.** A node's `links.transcript` is an
absolute path inside one machine's Claude config, which is not synced. The node
panel falls back to the session id, then to the prompt plus the saved reply, so
conversations still read correctly — they just aren't re-openable as live
sessions on the other machine.
