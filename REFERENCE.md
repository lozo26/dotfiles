# Reference

Full documentation of every feature in this repo — what it does, why it's there, and how to use it. For the quick-start and workflow overview, see `README.md`. For what's installed and where it comes from, see `install.sh`/`fetch-deps.sh`.

## Shell startup order

`etc/profile` → sources `etc/bash_profile` → sources `etc/bashrc` (standard bash startup chain — see the comment block at the bottom of `etc/profile` for exactly when each file gets read). `etc/bash_profile` sets up `$PATH` (adds `~/bin` and `~/cl/bin` if present) and exports `$OS`/`$PLATFORM`. `etc/bashrc` holds almost everything else.

Host-specific overrides that shouldn't be tracked in git go in `~/.bashrc_local` (sourced automatically at the end of `bashrc` if it exists) and `~/.vimrc.local` (same idea for vim).

## Navigation

| Command | What it does |
|---|---|
| `z <fragment>` | Jump to a previously-visited directory matching `<fragment>` (zoxide) — tracks directories automatically as you `cd`, ranked by frequency+recency. No setup needed beyond normal `cd` usage. |
| `zi` | Interactive picker (via fzf) when you're not sure of the exact `z` match |
| `..` / `...` | `cd ..` / `cd ../..` |
| `cl <dir>` | `cd` into `<dir>` and `ls -la` it in one step |
| `ls` / `ll` / `la` / `lla` | `eza` / `eza -l --git` / `eza -a` / `eza -la --git` (falls back to plain `ls` variants if `eza` isn't installed) |
| `broot` | Interactive tree-view file navigator/launcher. Run `broot --install` once by hand to get the `br` shell function (not automated — its installer wants to self-modify shell rc files) |

## Search

`g`, `gw`, `gnolog`, and `f` are ripgrep-backed if `rg` is installed, and fall back to plain `grep`/`find` otherwise (checked once at shell startup).

| Command | What it does |
|---|---|
| `g <pattern>` | Recursive smart-case search (ripgrep) |
| `gw <pattern>` | Same, but whole-word only |
| `gnolog <pattern>` | Same as `g`, excluding `log/` directories |
| `f <name>` | Fuzzy-ish filename search (lists all files, filters by `<name>`, case-insensitive) |
| Ctrl-R | Fuzzy search through bash history (fzf shell integration) |
| Ctrl-T | Fuzzy-find a file/dir under the cwd, inserts it at the cursor (fzf) |
| Alt-C | Fuzzy-cd into a subdirectory below the cwd (fzf) |

## SSH / remote work

| Command | What it does |
|---|---|
| `sshf` | Fuzzy-pick a `Host` from `~/.ssh/config` (via fzf) and `ssh` into it. Only useful once real `Host` blocks exist beyond the generic `Host *` — see `etc/ssh_config`. |
| `findportuser <port>` | `lsof -i :<port>` — what's listening on a port |
| `findhosts <subnet>` | `nmap` ping-sweep a `/24`, e.g. `findhosts 192.168.1` |

`etc/ssh_config` (→ `~/.ssh/config`) sets, for every host:
- `ServerAliveInterval`/`ServerAliveCountMax` — keeps long-lived connections (e.g. a `tmux` session on a remote box) alive through NAT/firewall idle timeouts instead of silently dying.
- `ControlMaster`/`ControlPath`/`ControlPersist` — reuses one authenticated connection for repeated `ssh`/`scp`/`rsync` to the same host instead of renegotiating each time. Requires `~/.ssh/sockets` to exist (`install.sh`/`etc/link` create it).

Add real `Host <alias>` blocks below the `Host *` block as you need them (they must come *after* it — ssh uses the first matching value per setting).

## tmux

`etc/tmux.conf` (→ `~/.tmux.conf`) is intentionally minimal — mouse support, vi-style copy-mode keys (to match vim muscle memory), a fixed 10ms escape-time (the default 500ms makes vim's `<Esc>` feel laggy inside tmux), pane splits that open in the current pane's directory (`|`/`-` instead of the default `"`/`%`), and a `prefix + r` binding to reload the config without restarting the session.

Basic usage if you're new to tmux: `tmux` starts a session, `Ctrl-b d` detaches from it (it keeps running), `tmux attach` reattaches. This is the main payoff for remote work — a session on a remote box survives your SSH connection dropping.

## direnv

Per-directory environment loading. Drop a `.envrc` file in a project; the first time, `direnv` refuses to load it until you run `direnv allow` (a deliberate security check, since `.envrc` is arbitrary shell code). After that, `cd` into the directory loads it automatically, `cd` out unloads it — no manual activate/deactivate.

`etc/direnvrc` (→ `~/.config/direnv/direnvrc`) adds one reusable layout function:

| In `.envrc` | What it does |
|---|---|
| `layout uv` | Creates `./.venv` with `uv` if it doesn't exist yet, then activates it. Means every uv-managed Python project's `.envrc` can be this one line instead of repeating the venv setup. |

Other useful commands: `direnv edit .` (opens `.envrc` in `$EDITOR`, re-approves on save), `direnv status` (debugging — shows what's loaded and why something isn't).

## Python / C dev loop (vim)

No plugins — just `makeprg`/`errorformat`, then vim's own `:make` + `:copen`/`:cnext`/`:cprev` quickfix navigation, same as any compiled language vim already supports out of the box.

- **Python**: `:make` runs `ruff check` on the current file and populates the quickfix list with lint errors.
- **C**: if no `Makefile`/`makefile` exists in the directory, `:make` falls back to a quick `gcc -Wall -Wextra` syntax/warning check on the current file. If a `Makefile` does exist, this is skipped entirely and vim's normal `:make` (→ plain `make`) is used — gcc's own error output already matches vim's default `errorformat`.

For actual code navigation in a C codebase: run `ctags -R .` in the project root, then use vim's built-in `Ctrl-]` (jump to definition) / `Ctrl-t` (jump back) / `:tselect` — no plugin needed, just a generated `tags` file.

## Git

`etc/gitconfig` (→ `~/.gitconfig`):

| Alias | Expands to |
|---|---|
| `git st` | `status` |
| `git co` | `checkout` |
| `git br` | `branch` |
| `git ci` | `commit` |
| `git df` | `diff` |
| `git dc` | `diff --cached` |
| `git lg` | `log --oneline --graph --decorate` |
| `git last` | `log -1 HEAD` |
| `git amend` | `commit --amend --no-edit` |
| `git unstage` | `restore --staged --` |
| `git undo` | `reset --soft HEAD~1` |
| `git ui` | Launches `gitui` (a terminal UI for git) |
| `git dt` | Structural diff of working-tree changes via `difftastic`, on demand |

Other settings: `core.excludesfile = ~/.gitignore` (this is what makes the global gitignore below actually work — without it git never reads that file at all), `pull.rebase = merges` (rebases on pull, but preserves local merge commits — plain `rebase = true` would flatten them), `push.autoSetupRemote = true` (no more `--set-upstream` on a new branch's first push), `init.defaultBranch = main`.

**Diff pager**: `core.pager = delta` — every diff-producing command (`diff`, `show`, `log -p`, `blame`) renders through `delta`: syntax-highlighted, side-by-side. `difftastic` (structural/tree-sitter-based diffing — understands that a function moved rather than showing every line as delete+add) is available on demand via `git dt` instead of being the default: better for understanding a refactor, but slower and less scannable for routine small diffs.

**Machine/identity-specific settings** (`user.name`, `user.email`, anything you don't want shared across every machine this repo is deployed to) go in `~/.gitconfig.local`, included via `[include]` at the bottom of `etc/gitconfig` — same pattern as `.bashrc_local`/`.vimrc.local`. Since `~/.gitconfig` is a symlink into this repo, **don't** use `git config --global ...` to set them (that writes through the symlink into the tracked file) — use `git config --file ~/.gitconfig.local <key> <value>` instead.

`etc/gitignore` (→ `~/.gitignore`) only has `*.sw?` and `.netrwhist` — vim's own editor artifacts. Deliberately not a general-purpose ignore list; that belongs in each project's own `.gitignore`, not a global one.

## Prompt

Hand-rolled in `bashrc`'s `prompt_func` (set as `PROMPT_COMMAND`), not a plugin/framework:
- Path color: green locally, purple when `$SSH_CONNECTION` is set (i.e. you're SSH'd in) — a quick visual cue for "am I on a remote box right now."
- Git branch (via `__git_ps1`, from bash-completion): white normally, red if the working tree is dirty (`git status --porcelain` non-empty).
- Active virtualenv name in brackets, if `$VIRTUAL_ENV` is set.
- The prompt character itself (`>`) turns red if the last command exited non-zero.

## Colors / `ls`

`vivid generate alabaster_dark` produces an `LS_COLORS` theme at shell startup, which both `eza` and plain `ls --color` read for per-file-type coloring (directories, symlinks, archives, media, etc.) — this is separate from your terminal's own color theme, which just sets the base 16 ANSI colors. Used to be a hand-maintained `etc/dircolors.ansi-dark` file; `vivid` replaced it entirely.

To try other themes: `vivid themes` lists them all, `LS_COLORS="$(vivid generate <theme>)" eza -la` previews one without changing your session, and changing the theme permanently is just editing the `vivid generate <theme>` line in `etc/bashrc`.

`colorslist` (alias) dumps all the `$COLOR_*` variables `bashrc` defines for use in scripts/prompts.

## CLI toolbox

Standalone tools installed by `install.sh` with no dotfiles wiring beyond being on `$PATH` — reach for them directly:

| Command | What it's for |
|---|---|
| `bat <file>` | `cat` with syntax highlighting, git-diff markers, and paging |
| `hexyl <file>` | Hex viewer |
| `mdcat <file.md>` | Render markdown in the terminal — handy for reading this repo's own `.md` files |
| `jless <file.json>` | Interactive JSON viewer/pager (also reads stdin: `curl ... \| jless`) |
| `choose <fields>` | Simpler `cut`/`awk` alternative for selecting fields from text, e.g. `choose 0 2` |
| `sd <find> <replace> <file>` | Simpler/faster `sed` alternative for find-and-replace |
| `ouch compress`/`ouch decompress` | One command for any archive format (zip/tar/7z/...), instead of remembering per-format flags |
| `just` | Command runner — like `make` but simpler, no `.PHONY`/tab quirks; looks for a `justfile` |
| `erd` | Tree-view disk usage (erdtree) — complements the `dust`-based `ducks`/`bigfilesandfolders` aliases; `erd` is better for a directory-tree shape, `dust` for a flat sorted-by-size view |
| `kondo <dir>` | Finds and optionally cleans build-artifact directories (`node_modules`, `target`, `.venv`, etc.) across projects to reclaim disk space |
| `miniserve <dir>` | Instant HTTP file server for a directory, with upload support — quick alternative to `python -m http.server` |
| `viddy <command>` | Modern `watch` replacement — highlights what changed between runs |

**Not automated** (documented here so the reasoning isn't lost, not because they're unavailable):
- **`fastmod`** and **`silicon`** — neither publishes prebuilt release binaries, and neither is in apt. Only install path is `cargo install <name>`, which needs a full Rust toolchain; not worth automating for one optional tool each. `fastmod` is a interactive find-and-replace-across-files tool (a friendlier `sd` for bulk codemods); `silicon` generates syntax-highlighted code screenshots.
- **`broot`** — see the Navigation section above; installed via apt, but the `br` shell function needs a manual one-time `broot --install`.

## Misc shell utilities

| Command | What it does |
|---|---|
| `hf <pattern>` | Grep `~/.bash_history` |
| `find_large_files` | Files over 50MB under the cwd (via `fd`) |
| `df` | `duf` if installed (colorized filesystem/mount table), else plain `df -h` |
| `ducks` / `bigfilesandfolders` | `dust -d 1` / `dust` — what's using space *inside* a directory, tree view. `duf` (above) is the complementary whole-filesystem view — "how full is each disk" vs "what's taking space in here" |
| `reloadbash` | Re-source `bash_profile` without opening a new shell |
| `profileme` | Your most-used shell commands, from history |
| `cp_folder` | `cp -Rpv` — copy a folder preserving permissions/dates |
| `mirror_website <url>` | `wget` mirror of a site |
| `killhard <pid>` | `kill -9` |
| `xtitle <text>` | Set the terminal window title |

## Vim odds and ends

- `mapleader = ","` — most custom mappings are `,<key>`.
- `jj` in insert mode → `<Esc>` (keeps hands on home row).
- `,v` / `,h` — new vertical/horizontal split, and hop into it.
- `,i` — toggle showing invisible characters (tabs/trailing spaces/EOL).
- `,p` — jump to the previously-edited buffer.
- `,a` — continue a search across all buffers.
- `<F2>` — toggle paste mode.
- `Tabstyle_tabs()` / `Tabstyle_spaces()` — call from `~/.vimrc.local` to switch a project to real tabs vs 2-space indents.
- `packadd! matchit` — enables the `matchit` plugin that ships *inside* Vim itself (since v7): extends `%` to jump between matching `if`/`end`, HTML tags, etc., not just brackets. Not a third-party plugin.
