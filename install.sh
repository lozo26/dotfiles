#!/usr/bin/env bash
# Bootstraps this dotfiles project on a fresh machine: installs every
# standalone tool it depends on, then symlinks all the dotfiles into place.
#
# Usage:
#   ./install.sh          install everything, then link dotfiles
#   ./install.sh --list   show what would be installed/linked, change nothing
#
# Safe to re-run - already-installed tools and already-correct symlinks are
# left alone. Works offline if fetch-deps.sh was already run (here or on
# another machine) and .vendor-cache/ was carried over with this directory;
# otherwise it fetches the latest official build of each tool directly, and
# falls back to apt for anything that has no official static build or that
# couldn't be reached.
#
# Ubuntu/Debian only (apt-based) - see TODO.md for other-OS support.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
REPO_ROOT="$(pwd)"
source lib/deps.sh

DRY_RUN=false
[ "${1:-}" = "--list" ] && DRY_RUN=true

if ! command -v apt-get &>/dev/null; then
  echo "This installer is Ubuntu/Debian-only (needs apt-get). Exiting." >&2
  exit 1
fi

echo "== dotfiles bootstrap =="
echo

# --- ~/cl symlink -----------------------------------------------------
# etc/link (and everything it symlinks) assumes the repo lives at ~/cl.
# Point it at wherever this actually is, instead of requiring that by hand.
if [ "$(readlink -f ~/cl 2>/dev/null || true)" != "$REPO_ROOT" ]; then
  if $DRY_RUN; then
    echo "[link] would point ~/cl -> $REPO_ROOT"
  else
    ln -sfn "$REPO_ROOT" ~/cl
    echo "[link] ~/cl -> $REPO_ROOT"
  fi
fi
echo

# --- sudo up front, once -----------------------------------------------
# Almost every run needs apt for at least one tool (deb-kind installs, or
# apt-fallback/aptonly ones) - just ask once now instead of trying to
# predict exactly which tools will need it.
if ! $DRY_RUN; then
  echo "This may need apt (sudo) for some tools. You may be prompted for your password once:"
  sudo -v
  echo
fi

# --- tools ---------------------------------------------------------------
while IFS='|' read -r name kind bin apt_pkg repo pattern; do
  [ -z "$name" ] && continue

  if [ "$bin" != "-" ] && command -v "$bin" &>/dev/null; then
    echo "[$name] already installed ($(command -v "$bin"))"
    continue
  fi

  if $DRY_RUN; then
    if [ "$kind" = "aptonly" ]; then
      echo "[$name] would install via apt: $apt_pkg (no official static build)"
    else
      echo "[$name] would install (prefers: official build from $repo, falls back to apt: $apt_pkg)"
    fi
    continue
  fi

  installed=false
  if [ "$kind" != "aptonly" ]; then
    if f=$(ensure_cached "$name" "$kind" "$repo" "$pattern"); then
      echo "[$name] installing from $(basename "$f")"
      install_artifact "$kind" "$f" "$bin" && installed=true
    fi
  fi

  if ! $installed; then
    if [ "$apt_pkg" != "-" ]; then
      echo "[$name] installing via apt: $apt_pkg"
      sudo apt-get install -y "$apt_pkg"
    else
      echo "[$name] could not install automatically (no cache, no network/release asset, no apt package)"
      echo "         see REFERENCE.md for manual install instructions"
    fi
  fi
done <<< "$TOOLS_TABLE"

$DRY_RUN || { fixup_fd_apt_name; fixup_bat_apt_name; }

echo
echo "fastmod and silicon are not automated (no official binary release, not in apt) -"
echo "see REFERENCE.md if you want either. broot needs a manual 'broot --install' step"
echo "after installing (adds the br shell function) - see REFERENCE.md."
echo

# --- symlink the dotfiles themselves -------------------------------------
if $DRY_RUN; then
  echo "[symlinks] would run etc/link to symlink all dotfiles into place"
else
  echo "== linking dotfiles =="
  DOTFILES_INSTALL=1 bash "$REPO_ROOT/etc/link"
fi

echo
echo "Done."
$DRY_RUN || echo "Open a new shell (or 'source ~/.bashrc') to pick everything up."
