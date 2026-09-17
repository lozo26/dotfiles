# Tool Dependencies

External tools this dotfiles setup expects beyond a standard Linux install (bash, git, vim, coreutils).

## Required by specific aliases/functions

| Tool | Used by | Fallback if missing |
|---|---|---|
| [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) | `g`, `gw`, `gnolog`, `f` search functions (`etc/bashrc`) | Falls back to plain `grep`/`find` |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `z` directory-jump command (`etc/bashrc`) | Skipped entirely (guarded by `type -P`); plain `cd` still works |
| [dust](https://github.com/bootandy/dust) | `ducks`, `bigfilesandfolders` aliases (`etc/bashrc`) | None — alias just fails if missing |
| [fd](https://github.com/sharkdp/fd) | `find_large_files` function (`etc/bashrc`) | None — function just fails if missing |
| [fzf](https://github.com/junegunn/fzf) | Shell integration (Ctrl-R/Ctrl-T/Alt-C) in `etc/bashrc`, and the `sshf()` function | Skipped entirely for shell integration (guarded by `type -P`); `sshf()` errors if called without it (no guard, matches `dust`/`fd` alias convention) |
| [direnv](https://direnv.net/) | Shell hook in `etc/bashrc` | Skipped entirely (guarded by `type -P`) |
| [podman](https://podman.io/) | Completion sourcing in `etc/bashrc` | Skipped entirely (guarded by `type -P`) |

## Referenced by other scripts/config

| Tool | Used by |
|---|---|
| `nmap` | `findhosts()` (`etc/bashrc`) |
| `lsof` | `findportuser()` (`etc/bashrc`) |
| `bash-completion` (system package) | Enables `/etc/bash_completion`, which `etc/bashrc` sources. This is also what makes git tab-completion work — git's own completion script ships as part of this package/framework, no separate dotfile needed |
| [ruff](https://github.com/astral-sh/ruff) | Python `makeprg` in `etc/vim/vimrc` (`:make` runs ruff and populates the quickfix list) |
| `gcc` | C `makeprg` fallback in `etc/vim/vimrc`, used only when no Makefile is present |
| [tmux](https://github.com/tmux/tmux) | `etc/tmux.conf`, symlinked to `~/.tmux.conf` |
| [uv](https://github.com/astral-sh/uv) | `layout_uv` in `etc/direnvrc` (symlinked to `~/.config/direnv/direnvrc`) — creates/activates a `.venv` when a project's `.envrc` calls `layout uv` |

## Recommended standalone tools (not wrapped by any script)

These aren't invoked by anything in this repo, but are the intended way to do things that used to have a bashrc wrapper:

| Tool | Replaces |
|---|---|
| [fastmod](https://github.com/facebookincubator/fastmod) | The old `find_replace_log_changes()` bulk find/replace function (removed) |
