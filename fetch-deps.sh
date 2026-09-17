#!/usr/bin/env bash
# Run this on any machine WITH internet access to pre-download the latest
# official build of every tool this dotfiles setup wants, into .vendor-cache/
# (gitignored). Copy the whole project directory - repo plus .vendor-cache/ -
# to an offline machine and run install.sh there; it'll install everything
# from the cache with zero network calls.
#
# Safe to re-run: already-cached tools are left alone.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source lib/deps.sh

if ! has_network; then
  echo "No network access right now - nothing to fetch. Run this again when online."
  exit 1
fi

echo "Fetching latest official builds into $VENDOR_CACHE ..."
echo

while IFS='|' read -r name kind bin apt_pkg repo pattern; do
  [ -z "$name" ] && continue

  if [ "$kind" = "aptonly" ]; then
    echo "[$name] no official static build exists - install.sh will use apt for this one"
    continue
  fi

  if f=$(ensure_cached "$name" "$kind" "$repo" "$pattern"); then
    echo "[$name] cached: $(basename "$f")"
  else
    echo "[$name] could not fetch (release asset not found) - install.sh will fall back to apt"
  fi
done <<< "$TOOLS_TABLE"

echo
echo "Done. To deploy on an offline machine:"
echo "  1. Copy this whole project directory (including .vendor-cache/) there"
echo "  2. Run ./install.sh"
