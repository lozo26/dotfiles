# TODO

Known gaps and future-improvement candidates — things intentionally left undone, not blockers.

## Known gaps in install.sh / fetch-deps.sh

- **Ubuntu/Debian only.** Hard-requires `apt-get`; exits cleanly on anything else rather than failing confusingly. Making this generic across OSes is low priority — see "Cross-OS" below.
- **`fastmod` and `silicon` aren't automated.** Neither publishes binary release assets, and neither is in apt — only install path for either is `cargo install <name>`, which needs a full Rust toolchain. Not worth automating for two optional tools; install manually if wanted.
- **`broot`'s shell function isn't automated.** Installed via apt (its own release packaging doesn't fit this script's per-platform-asset model safely), but getting the `br` shell function requires a manual one-time `broot --install` — its installer wants to self-modify shell rc files, which would fight with this repo managing them instead.
- **Not yet tested on an actual fully-offline machine or on Ubuntu 24.04 specifically** — verified on Ubuntu 26.04 with live network. The `.vendor-cache/` → offline-install path is exercised (fetch-deps.sh really downloaded everything, install.sh really installed from a couple of those cached files), but the full "no network at all" + "different Ubuntu version" combination hasn't been run for real yet.
- **x86_64 only.** Asset patterns in `lib/deps.sh` are hardcoded to `amd64`/`x86_64`. Would need arch detection (`uname -m`) and per-arch patterns to support aarch64, etc.

## sshf needs real Host entries to be useful

`etc/ssh_config` only has the generic `Host *` block right now — `sshf` (fuzzy SSH-host picker) has nothing to pick from until real `Host <alias>` blocks exist. Low value on a personal machine with few remote hosts; expected to earn its keep more on a work setup with many. Add real entries there when that's relevant.

## Tool candidates not yet adopted

Not dependencies — nothing in this repo relies on these. Each would replace or improve something specific.

| Tool | Would help with |
|---|---|
| [procs](https://github.com/dalance/procs) | Modern `ps`/process searching |
| [lnav](https://lnav.org/) | Searchable/filterable log viewer, if logs get watched often |
| [btop](https://github.com/aristocratos/btop) or [bottom](https://github.com/ClementTsang/bottom) | Nicer `top` replacement, graphs |
| [duf](https://github.com/muesli/duf) | Nicer `df` replacement |
| [atuin](https://github.com/atuinsh/atuin) | Full shell-history upgrade (fuzzy search, sync, stats) — bigger change than a 1-line swap, replaces the `hf()` function |
| [starship](https://starship.rs/) | Replace the hand-rolled `prompt_func` in `bashrc` with a cross-shell prompt framework |
| [mise](https://mise.jdx.dev/) | Language version management, if ever needed beyond `uv` for Python |
| [git-extras](https://github.com/tj/git-extras) or [lazygit](https://github.com/jesseduffield/lazygit) | Beyond the basic `[alias]` set in `etc/gitconfig`, if that ever feels insufficient |
| [shellcheck](https://www.shellcheck.net/) | No linting exists on any shell script in this repo yet — could wire up as a pre-commit hook or CI check |
| [tldr](https://tldr.sh/) | In-terminal command examples (replaces the old hand-maintained cheat-sheet aliases that used to live in `bashrc_help`) |
| [fzf.vim](https://github.com/junegunn/fzf.vim), [NERD Commenter](https://github.com/preservim/nerdcommenter), [surround.vim](https://github.com/tpope/vim-surround) | Specific vim plugins that were removed in the base-vim cleanup, worth reconsidering individually if a real need shows up (not as a return to a vendored plugin tree) |
| [termshark](https://termshark.io/) | Packet inspection, if ever needed again |
| [mycli](https://www.mycli.net/) | Nicer MySQL CLI, if local MySQL work ever comes back |
| [typst](https://typst.app/) | Modern typesetting (LaTeX alternative) — investigate if document/report generation ever comes up |
| [navi](https://github.com/denisidoro/navi) | Interactive cheat-sheet tool (browse/fill-in example commands) — alternative or complement to `tldr` |

## Larger, deferred workstreams

- **Neovim + [lazy.nvim](https://github.com/folke/lazy.nvim)** — a real editor migration, not urgent. If/when this happens, revisit plugin needs from scratch rather than reintroducing the old vendored tree.
- **Cross-OS support for install.sh/fetch-deps.sh** — would need a package-manager abstraction (apt/dnf/pacman/brew) and OS detection. Explicitly low priority; Ubuntu/Debian covers current needs.
- **`git config --file ~/.gitconfig.local`** habit — documented in `etc/gitconfig` itself as a comment, but easy to forget; keep an eye out for whether that's actually sticking or needs a better nudge (e.g. a `gitlocal` shell function wrapper).
