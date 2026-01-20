#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  vscode_task_make.sh <make-target> <start-dir>

Examples:
  vscode_task_make.sh build /workspaces/computercard-dev-env/Workshop_Computer/releases/22_sheep/src
  vscode_task_make.sh flash /workspaces/computercard-dev-env/XX_newcard

Behavior:
  Walks upward from <start-dir> to find the nearest directory containing CMakeLists.txt,
  then runs: make <make-target> in that directory.
EOF
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
	usage
	exit 0
fi

make_target=${1:-}
start_dir=${2:-}

if [[ -z "${make_target}" || -z "${start_dir}" ]]; then
	usage
	exit 2
fi

if [[ ! -d "${start_dir}" ]]; then
	echo "vscode_task_make.sh: start-dir not found: ${start_dir}" >&2
	exit 2
fi

# Canonicalize path (best-effort; works in the devcontainer)
if command -v realpath >/dev/null 2>&1; then
	start_dir=$(realpath "${start_dir}")
fi

search_dir="${start_dir}"
workspace_dir=${WORKSPACE_DIR:-"/workspaces/computercard-dev-env"}

is_project_root() {
	[[ -f "${1}/CMakeLists.txt" ]]
}

while true; do
	if is_project_root "${search_dir}"; then
		break
	fi

	parent_dir=$(dirname "${search_dir}")
	if [[ "${parent_dir}" == "${search_dir}" ]]; then
		echo "vscode_task_make.sh: could not find a Pico SDK project (no CMakeLists.txt) above: ${start_dir}" >&2
		echo "Tip: open a file inside a card folder (one that contains CMakeLists.txt)." >&2
		exit 2
	fi

	# If the start directory is within the workspace, avoid accidentally traversing out.
	if [[ "${search_dir}" == "${workspace_dir}" ]]; then
		echo "vscode_task_make.sh: reached workspace root without finding CMakeLists.txt: ${workspace_dir}" >&2
		exit 2
	fi

	search_dir="${parent_dir}"
done

echo "[vscode task] make ${make_target} (project: ${search_dir})"
exec make "${make_target}" -C "${search_dir}"
