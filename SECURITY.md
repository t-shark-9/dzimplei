# Security

## Reporting a vulnerability

Please do not open a public issue. Use GitHub's private reporting on this
repository (Security → Report a vulnerability), which reaches the maintainer
without disclosing the problem first.

Useful in a report: what an attacker can do, what access they need to start,
and the smallest reproduction you have. There is no bounty; there is a fix and
credit if you want it.

## What dzimplei assumes

Worth knowing before you deploy it, because these are design decisions rather
than oversights:

- **Agent runs are not sandboxed.** A run executes Claude Code (or another agent
  CLI) with permissions bypassed, in a workspace directory, as the user running
  the server. That is the product: an agent that can actually do the work. Run it
  as a user whose reach you are comfortable with, and prefer a machine you own.
- **The manager reads messages from strangers.** If you connect WhatsApp, Jim
  sees every message in the chats he is in. He is deliberately given only web
  search and fetch — no file access, no shell — and only the paired boss number
  can start work. A chat can also be locked to a single workspace, enforced in
  code rather than by prompt.
- **Self-hosting is public by default.** Sign-in is email and password (scrypt,
  signed HttpOnly session cookie), and there is no open registration: the first
  account is claimed with a code printed to the server log, and later accounts
  are created by the owner. Put it behind a tunnel or an identity proxy as well
  if you can.
- **Files a run writes are served back to the browser** from the workspace, with
  `X-Content-Type-Options: nosniff` and a `sandbox` CSP so an agent-authored HTML
  page cannot run script on the app's origin.

## Scope

In scope: authentication bypass, one account reaching another's data, path
traversal out of a workspace, the WhatsApp bridge acting for someone who is not
the boss, and anything that turns a chat message into code execution the user
did not ask for.

Out of scope: an agent doing something destructive because you told it to.
