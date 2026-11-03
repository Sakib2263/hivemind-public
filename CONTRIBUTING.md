# Contributing to Hivemind

Thanks for helping. Hivemind is free for noncommercial use (see `LICENSE`), and improvements from the community
are welcome.

## How
1. Fork the repo on GitHub and clone your fork.
2. Make a branch for your change: `git checkout -b my-change`.
3. Keep the change small and focused: one fix or one feature per pull request.
4. Test it on your system (Windows, Mac or Linux) and say which one you tested in the pull request.
5. Open a pull request against the **`dev`** branch, not `main`. Changes are tested on `dev` first and then
   released to `main`.

## Good to know
- Never include keys, passwords, personal data or client work. `secrets/` stays local.
- Skills must be generic: no company names, private contacts or client details.
- Windows launchers live in `windows/`, Mac/Linux launchers in `mac-linux/`. A change to a shared script
  (`scripts/`) must keep working on all three systems; put OS-specific parts behind an OS check.
- Plain language in docs and messages: short sentences, no jargon.
- By opening a pull request you agree that your contribution is shared under the same license (`LICENSE`).

## Reporting a problem
Open an issue with: what you ran, what you expected, what happened, your system, and the last lines of the
log (`logs/verify.log` or the relay window). Remove anything private first.
