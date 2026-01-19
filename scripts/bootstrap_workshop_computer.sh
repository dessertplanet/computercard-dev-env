#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/TomWhitwell/Workshop_Computer.git"
DEST_DIR="/workspaces/computercard-dev-env/Workshop_Computer"
SOURCE_DIR="/opt/Workshop_Computer"

rewrite_github_ssh_submodules_to_https() {
  local repo_dir="$1"
  local gitmodules="$repo_dir/.gitmodules"

  if [[ ! -f "$gitmodules" ]]; then
    return 0
  fi

  local changed=0

  while IFS= read -r line; do
    # Format: <key> <value>
    local key url new_url
    key="${line%% *}"
    url="${line#* }"

    new_url="$url"
    if [[ "$url" == git@github.com:* ]]; then
      new_url="https://github.com/${url#git@github.com:}"
    elif [[ "$url" == ssh://git@github.com/* ]]; then
      new_url="https://github.com/${url#ssh://git@github.com/}"
    fi

    if [[ "$new_url" != "$url" ]]; then
      git -C "$repo_dir" config -f .gitmodules "$key" "$new_url"
      changed=1
    fi
  done < <(git -C "$repo_dir" config -f .gitmodules --get-regexp '^submodule\\..*\\.url$' 2>/dev/null || true)

  if [[ $changed -eq 1 ]]; then
    echo "Rewrote GitHub SSH submodule URLs to HTTPS in .gitmodules"
    # Ensure the rewritten URLs are also reflected in .git/config.
    git -C "$repo_dir" submodule sync --recursive >/dev/null 2>&1 || true
  fi
}

if [[ -d "$DEST_DIR/.git" ]]; then
  echo "Workshop_Computer already present: $DEST_DIR"
  rewrite_github_ssh_submodules_to_https "$DEST_DIR"
  git -C "$DEST_DIR" submodule update --init --recursive >/dev/null 2>&1 || true
  git config --global --add safe.directory "$DEST_DIR" >/dev/null 2>&1 || true
  exit 0
fi

if [[ -e "$DEST_DIR" && ! -d "$DEST_DIR" ]]; then
  echo "Warning: $DEST_DIR exists and is not a directory; skipping clone." >&2
  exit 0
fi

mkdir -p "$(dirname "$DEST_DIR")"

if [[ -d "$SOURCE_DIR/.git" ]]; then
  echo "Copying Workshop_Computer from image into $DEST_DIR"
  cp -a "$SOURCE_DIR" "$DEST_DIR"
else
  echo "Cloning Workshop_Computer into $DEST_DIR"
  echo "  repo: $REPO_URL"

  # Keep provisioning resilient: network can be unavailable during devcontainer build.
  # Shallow clone keeps it fast; users can 'git fetch --unshallow' later if needed.
  # Use recursive clone to pull submodules in one step.
  if ! git clone --depth 1 --recurse-submodules --shallow-submodules "$REPO_URL" "$DEST_DIR"; then
    echo "Warning: failed to clone Workshop_Computer (network unavailable?)." >&2
    echo "You can clone it later with:" >&2
    echo "  git clone $REPO_URL Workshop_Computer" >&2
    exit 0
  fi
fi

rewrite_github_ssh_submodules_to_https "$DEST_DIR"

git -C "$DEST_DIR" submodule update --init --recursive >/dev/null 2>&1 || true

git config --global --add safe.directory "$DEST_DIR" >/dev/null 2>&1 || true

echo "Workshop_Computer clone complete."