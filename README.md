# dotfiles

Personal shell, vim, tmux, direnv, and git configuration. Deliberately minimal — no plugin managers, no bespoke alias suites reinventing existing tools, base Vim rather than a vendored plugin tree. Deployed across multiple machines, including offline environments.

See **[REFERENCE.md](REFERENCE.md)** for full documentation of every feature and workflow. See **[TODO.md](TODO.md)** for what's intentionally not done yet.

## Quick start

```
git clone <this repo> dotfiles
cd dotfiles
./install.sh
```

That's it. `install.sh` installs every tool this setup depends on (preferring the latest official upstream build over Ubuntu's apt version where one exists, falling back to apt otherwise — see below), points `~/cl` at wherever you cloned this, and symlinks every dotfile into place. It's safe to re-run any time.

Run `./install.sh --list` first if you just want to see what it would do without changing anything.

### Offline machines

```
./fetch-deps.sh          # on any machine WITH internet access
# copy this whole project directory (including .vendor-cache/) to the offline machine
./install.sh             # on the offline machine - installs from the cache, zero network calls
```

`fetch-deps.sh` and `install.sh` share the same tool-resolution logic (`lib/deps.sh`) — the only difference is `fetch-deps.sh` just downloads into `.vendor-cache/` (gitignored) without installing anything. This is why: some tools ship official static builds that are far more current than Ubuntu's own package (and Ubuntu 24.04 vs 26.04 vs whatever's next all lag differently), so preferring the upstream build is both fresher and, being mostly static binaries, largely version/distro-independent. `apt` remains the fallback for the couple of tools with no clean official static build, and for anything unreachable when there's no cache yet.

Requires Ubuntu/Debian (apt-based) today — see `TODO.md`.

## What's here, by workflow

- **Navigation & search** — `zoxide` (`z`/`zi`) instead of manual `cd`, `ripgrep`-backed `g`/`gw`/`f` functions, `fzf` wired into Ctrl-R/Ctrl-T/Alt-C.
- **SSH & remote work** — real `~/.ssh/config` (keepalives + connection reuse), `tmux` for sessions that survive disconnects, `sshf` to fuzzy-pick a host once you have named `Host` entries.
- **Python / C dev loop** — `uv` + `ruff`, a `layout_uv` direnv helper so a project's `.envrc` is just `layout uv`, and vim `:make`/quickfix wiring for both languages — no plugins.
- **Git** — a small curated alias set, a working global gitignore (just editor artifacts), `pull.rebase = merges`. Identity (`user.name`/`email`) lives in `~/.gitconfig.local`, not the tracked config.
- **Vim** — just `vimrc`/`gvimrc`, no vendored plugin tree. If you want to know why, see the "vim cleanup" note in `TODO.md`'s history — the short version: plugins stopped earning their keep once "often on someone else's unfamiliar machine" became the common case.

## Structure

```
bin/            a couple of small standalone scripts
etc/            everything that gets symlinked into $HOME (bashrc, vimrc, gitconfig, ...)
etc/vim/        vimrc, gvimrc, and a personal spell-check dictionary (no plugins)
etc/link        the actual symlinking logic, called by install.sh (or run directly: `source etc/link`)
lib/deps.sh     shared tool-resolution logic used by both scripts below
install.sh      bootstraps a new machine: installs tools, then runs etc/link
fetch-deps.sh   pre-downloads tools for later offline install
.vendor-cache/  gitignored - populated by fetch-deps.sh, consumed by install.sh
```

## Warning

Still modified often. Ubuntu/Debian Linux only at this point — no other platforms are tested or supported.
