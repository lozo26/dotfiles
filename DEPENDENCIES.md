# Tool Dependencies

External tools this dotfiles setup expects beyond a standard Linux install (bash, git, vim, coreutils).

## Required by specific aliases/functions

| Tool | Used by | Fallback if missing |
|---|---|---|
| [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) | `g`, `gw`, `gnolog`, `f` search functions (`etc/bashrc`) | Falls back to plain `grep`/`find` |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `z` directory-jump command (`etc/bashrc`) | Skipped entirely (guarded by `type -P`); plain `cd` still works |
| [dust](https://github.com/bootandy/dust) | `ducks`, `bigfilesandfolders` aliases (`etc/bashrc`) | None — alias just fails if missing |
| [fd](https://github.com/sharkdp/fd) | `find_large_files` function (`etc/bashrc`) | None — function just fails if missing |

## Referenced by other scripts/config

| Tool | Used by |
|---|---|
| `nmap` | `findhosts()` (`etc/bashrc`) |
| `lsof` | `findportuser()` (`etc/bashrc`) |
| `bash-completion` (system package) | Enables `/etc/bash_completion`, which `etc/bashrc` sources. This is also what makes git tab-completion work — git's own completion script ships as part of this package/framework, no separate dotfile needed |

## Recommended standalone tools (not wrapped by any script)

These aren't invoked by anything in this repo, but are the intended way to do things that used to have a bashrc wrapper:

| Tool | Replaces |
|---|---|
| [fastmod](https://github.com/facebookincubator/fastmod) | The old `find_replace_log_changes()` bulk find/replace function (removed) |
