# Tools to Investigate

Candidate modern tools flagged during cleanup that haven't been adopted (or rejected) yet. Not dependencies — nothing in this repo relies on these.

| Tool | Would replace / help with | Notes |
|---|---|---|
| [procs](https://github.com/dalance/procs) | Manual `ps`/process searching | Came up when removing `psgrep`/`psaux` |
| [ouch](https://github.com/ouch-org/ouch) | `untar` alias (removed) | Universal archive tool, handles any format |
| [lnav](https://lnav.org/) | `systail` alias (removed) | Searchable/filterable log viewer, only worth it if logs get watched often |
| [btop](https://github.com/aristocratos/btop) or [bottom](https://github.com/ClementTsang/bottom) | `top -o %CPU` alias | Nicer TUI system monitor with graphs |
| [duf](https://github.com/muesli/duf) | `df -h` alias | Colorized/better-formatted disk usage |
| [atuin](https://github.com/atuinsh/atuin) | `hf()` history-grep function | Bigger change — full shell-history replacement (fuzzy search, sync, stats), not a 1-line swap |
| [starship](https://starship.rs/) | Hand-rolled `prompt_func` in `etc/bashrc` | Cross-shell, handles git status/venv natively, no more hand-written PS1 logic |
| [mise](https://mise.jdx.dev/) | RVM (already removed) | If any language version management is needed again in the future |
| [git-extras](https://github.com/tj/git-extras) or [lazygit](https://github.com/jesseduffield/lazygit) | The removed `bin/gt/` bespoke git alias suite | Follow-up to figuring out proper git aliases (see memory note) |
| [shellcheck](https://www.shellcheck.net/) | No current linting on any shell script in this repo | Could wire up as a pre-commit hook or CI check |
| [chezmoi](https://www.chezmoi.io/) or [GNU Stow](https://www.gnu.org/software/stow/) | The hand-rolled `etc/link` symlink script | Deferred modernization workstream |
| Neovim + [lazy.nvim](https://github.com/folke/lazy.nvim) (+ telescope.nvim or fzf.vim) | The whole vendored `etc/vim/` plugin tree (ctrlp, fuf, command-t) | Deferred, larger workstream |
| [termshark](https://termshark.io/) | The removed `monitor_traffic()` (ngrep-based) | Only relevant if packet inspection is ever needed again |
| [mycli](https://www.mycli.net/) | The removed `bin/mq/` MySQL alias suite | Only relevant if local MySQL work comes back |
| [eza](https://github.com/eza-community/eza) | `ls`/`ll`/`la`/`lla` aliases + `etc/dircolors.ansi-dark` | Modern `ls` with good built-in colors and git-status awareness; could retire the hand-maintained dircolors file entirely |
| [tldr](https://tldr.sh/) | The removed `etc/bashrc_help` cheat-sheet aliases | Community-maintained command examples, in-terminal, no file to hand-maintain |
