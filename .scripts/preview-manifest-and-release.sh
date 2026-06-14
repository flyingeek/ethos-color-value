#!/usr/bin/env bash

set -euo pipefail

RELEASE_TAG="${1:-}"
APP="${2:-missingApp}"

# Infer GIT_VER from scriptVersion in main.lua
export GIT_VER=$(grep -m 1 'local scriptVersion' "${APP}/main.lua" | sed 's/.*"\(.*\)".*/\1/')
echo "scriptVersion    : ${GIT_VER}"

# Infer REPO_OWNER and REPO_NAME from git remote
REMOTE_URL=$(git remote get-url origin)
if [[ "${REMOTE_URL}" =~ github\.com[:/]([^/]+)/([^/]+)$ ]]; then
  export REPO_OWNER="${BASH_REMATCH[1]}"
  export REPO_NAME="${BASH_REMATCH[2]%.git}"
else
  echo "Could not parse GitHub remote URL: ${REMOTE_URL}"
  exit 1
fi
echo "Repo             : ${REPO_OWNER}/${REPO_NAME}"

# Set up env vars for update-manifest.py
export RELEASES_MD="Releases.md"
TEMP_MANIFEST=$(mktemp /tmp/ethos_lua_manifest_XXXXXX.json)
trap 'rm -f "${TEMP_MANIFEST}"' EXIT
cp ethos_lua_manifest.json "${TEMP_MANIFEST}"
export MANIFEST_FILE="${TEMP_MANIFEST}"

# Run update-manifest.py against the temp file
python3 .github/scripts/update-manifest.py

# Display the releaseNotes.content
echo ""
echo "=== Preview of manifest releaseNotes.content ==="
echo ""
python3 -c "import json, os; print(json.load(open(os.environ['MANIFEST_FILE']))['releaseNotes']['content'])"
echo "================================================="
echo ""

# Prompt to confirm
read -rp "Continue with release? [y/N] " CONFIRM
if [[ "${CONFIRM}" != "y" && "${CONFIRM}" != "Y" ]]; then
  echo "Aborted."
  exit 0
fi

# Proceed with the actual release
bash .vscode/release-tag-and-push.sh "${RELEASE_TAG}" "${APP}"
