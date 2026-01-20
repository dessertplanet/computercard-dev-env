#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/workspaces/computercard-dev-env"
SUBMODULE_PATH="Workshop_Computer"

if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Skipping Workshop_Computer init: not a git worktree."
  exit 0
fi

if [[ ! -f "$ROOT_DIR/.gitmodules" ]]; then
  echo "Skipping Workshop_Computer init: no .gitmodules present."
  exit 0
fi

submodule_key=$(git -C "$ROOT_DIR" config -f .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null \
  | awk -v path="$SUBMODULE_PATH" '$2 == path {print $1; exit 0}')

if [[ -z "${submodule_key}" ]]; then
  echo "Skipping Workshop_Computer init: no submodule configured at ${SUBMODULE_PATH}."
  exit 0
fi

status_line=$(git -C "$ROOT_DIR" submodule status "$SUBMODULE_PATH" 2>/dev/null || true)

if [[ -z "$status_line" ]]; then
  echo "Skipping Workshop_Computer init: submodule status unavailable for ${SUBMODULE_PATH}."
  exit 0
fi

if [[ "$status_line" == -* ]]; then
  echo "Initializing submodule ${SUBMODULE_PATH}."
  git -C "$ROOT_DIR" submodule update --init --recursive "$SUBMODULE_PATH"
else
  echo "Submodule ${SUBMODULE_PATH} already initialized."
fi