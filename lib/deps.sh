#!/usr/bin/env bash
# Shared dependency-resolution logic used by both fetch-deps.sh and install.sh.
# Not meant to be run directly - sourced by those two scripts.
#
# Design: for each tool, prefer the latest official upstream build (fetched
# from its GitHub releases) over whatever's in Ubuntu's apt repo, which lags
# behind and varies by Ubuntu version. apt is the fallback when there's no
# official static build (tmux, universal-ctags), or when there's no network
# and nothing cached yet.
#
# TOOLS_TABLE fields, pipe-separated:
#   name    - label used for cache filenames and log output
#   kind    - deb | binary | tarball | aptonly
#             deb:     official .deb asset, installed via apt (resolves deps)
#             binary:  a single raw executable asset, chmod+x and moved into
#                       ~/.local/bin as-is
#             tarball: a .tar.gz asset containing the binary somewhere inside
#             aptonly: no usable official static build; apt is the only path
#   bin     - command name to check for / install as (- if not applicable)
#   apt_pkg - apt package name to fall back to (- if none exists)
#   repo    - GitHub "owner/repo" to fetch releases from (- for aptonly)
#   pattern - for kind=binary: the exact (stable, unversioned) asset filename,
#             fetched via the /releases/latest/download/<name> redirect, so no
#             GitHub API/JSON call is needed.
#             for kind=deb/tarball: a regex matched against release asset
#             names via the GitHub API (versioned filenames, so no stable
#             direct-download URL exists).
#             (- for aptonly)
#
# jq and direnv are both kind=binary with stable filenames, so they never
# need jq itself to resolve their download URL - this is what lets jq
# bootstrap itself before it's needed to parse the deb/tarball tools below.
TOOLS_TABLE="
jq|binary|jq|jq|jqlang/jq|jq-linux-amd64
direnv|binary|direnv|direnv|direnv/direnv|direnv.linux-amd64
ripgrep|deb|rg|ripgrep|BurntSushi/ripgrep|^ripgrep_[0-9.]+-[0-9]+_amd64\.deb$
fd|deb|fd|fd-find|sharkdp/fd|^fd_[0-9.]+_amd64\.deb$
zoxide|deb|zoxide|zoxide|ajeetdsouza/zoxide|^zoxide_[0-9.]+-[0-9]+_amd64\.deb$
dust|deb|dust|du-dust|bootandy/dust|^du-dust_[0-9.]+-[0-9]+_amd64\.deb$
fzf|deb|fzf|fzf|junegunn/fzf|^fzf_[0-9.]+_amd64\.deb$
uv|tarball|uv|-|astral-sh/uv|^uv-x86_64-unknown-linux-musl\.tar\.gz$
ruff|tarball|ruff|-|astral-sh/ruff|^ruff-x86_64-unknown-linux-musl\.tar\.gz$
tmux|aptonly|tmux|tmux|-|-
universal-ctags|aptonly|ctags|universal-ctags|-|-
"
# Not in this table at all: fastmod. Its latest GitHub release ships no
# binary assets (source-only tag) and it's not in apt either - the only
# install path is `cargo install fastmod`, which needs a full Rust toolchain.
# Not worth automating for one optional tool; see REFERENCE.md.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_CACHE="$REPO_ROOT/.vendor-cache"

has_network() {
  curl -fsS --connect-timeout 3 -o /dev/null https://api.github.com 2>/dev/null
}

# Prints the download URL for a tool's latest matching release asset.
# Returns non-zero (prints nothing) if it can't be resolved.
resolve_asset_url() {
  local kind="$1" repo="$2" pattern="$3"

  if [ "$kind" = "binary" ]; then
    # Stable filename - GitHub's /latest/download/ redirect needs no API call
    echo "https://github.com/$repo/releases/latest/download/$pattern"
    return 0
  fi

  # deb/tarball: versioned filename, need the API + jq to find the real one
  command -v jq &>/dev/null || return 1
  local json
  json=$(curl -fsSL --connect-timeout 10 "https://api.github.com/repos/$repo/releases/latest") || return 1
  echo "$json" | jq -r --arg pat "$pattern" \
    '.assets[] | select(.name | test($pat)) | .browser_download_url' | head -1
}

# Ensures a cached artifact exists for this tool (downloading it if there's
# network and none is cached yet). Prints the cache file path on success.
ensure_cached() {
  local name="$1" kind="$2" repo="$3" pattern="$4"
  [ "$kind" = "aptonly" ] && return 1

  local existing
  existing=$(find "$VENDOR_CACHE" -maxdepth 1 -name "${name}--*" 2>/dev/null | head -1)
  if [ -n "$existing" ]; then
    echo "$existing"
    return 0
  fi

  has_network || return 1
  local url
  url=$(resolve_asset_url "$kind" "$repo" "$pattern") || return 1
  [ -n "$url" ] || return 1

  mkdir -p "$VENDOR_CACHE"
  local dest="$VENDOR_CACHE/${name}--$(basename "$url")"
  if curl -fsSL --connect-timeout 20 "$url" -o "$dest"; then
    echo "$dest"
  else
    rm -f "$dest"
    return 1
  fi
}

# Installs an already-downloaded artifact (from cache or a fresh fetch).
install_artifact() {
  local kind="$1" file="$2" bin="$3"
  case "$kind" in
    deb)
      sudo apt-get install -y "$file"
      ;;
    binary)
      mkdir -p ~/.local/bin
      install -m 755 "$file" ~/.local/bin/"$bin"
      ;;
    tarball)
      local tmpdir
      tmpdir=$(mktemp -d)
      tar -xzf "$file" -C "$tmpdir"
      local found
      found=$(find "$tmpdir" -type f -name "$bin" | head -1)
      if [ -z "$found" ]; then
        echo "    could not find '$bin' inside $file" >&2
        rm -rf "$tmpdir"
        return 1
      fi
      mkdir -p ~/.local/bin
      install -m 755 "$found" ~/.local/bin/"$bin"
      rm -rf "$tmpdir"
      ;;
  esac
}

# fd-specific: Ubuntu's own fd-find package (the apt fallback) installs the
# binary as `fdfind`, not `fd` - unlike the official upstream .deb, which
# ships both names. Only needed when the apt fallback path was actually used.
fixup_fd_apt_name() {
  if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
    mkdir -p ~/.local/bin
    ln -sf "$(command -v fdfind)" ~/.local/bin/fd
  fi
}
